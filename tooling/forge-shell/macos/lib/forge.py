#!/usr/bin/env python3
"""Forge Mac: explicit commands, local SQLite data, no shell-string execution."""
from __future__ import annotations

import base64
import contextlib
import datetime as dt
import fnmatch
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import socket
import sqlite3
import subprocess
import sys
import tempfile
import time
import urllib.parse
import uuid
import zipfile

PACKAGE = Path(__file__).resolve().parents[1]
STATE = Path(os.environ.get("FORGE_STATE_HOME", str(Path.home() / ".local/state/forge-mac")))
CONFIG = Path(os.environ.get("FORGE_CONFIG_HOME", str(Path.home() / ".config/forge-mac")))
DEFAULTS = {
    "theme": "auto", "prompt": "rich", "git_status": True, "fzf": True,
    "directory_history": True, "editing": True, "shortcuts": True, "plugins": True,
    "git_cache_seconds": 5, "default_project": "",
    "workspace_roots": [str(Path.home() / "Developer"), str(Path.home() / "Projects")],
    "flutter_sdk": str(Path.home() / "develop/flutter"),
}
SKIP = {".git", "node_modules", ".dart_tool", "build", ".venv", "venv", "__pycache__", ".gradle"}
SECRET = re.compile(r"(?i)(?:api[_-]?key|password|secret|token)\s*[:=]\s*\S+|-----BEGIN .*PRIVATE KEY")
CATALOG = [
    ("dash", "Discover", "Choose a task from the command center", "dash"),
    ("helpme", "Discover", "Find commands by intent", "helpme files"),
    ("keys", "Discover", "Show keyboard shortcuts", "keys"),
    ("forge", "Settings", "Settings, theme, prompt, reload and diagnostics", "forge config"),
    ("ph", "Settings", "Check installed tools and local state", "ph"),
    ("ptest", "Settings", "Run the isolated package tests", "ptest"),
    ("reloadforge", "Settings", "Reload this shell configuration", "reloadforge"),
    ("jump", "Folders", "Pick a bookmark or recent folder", "jump"),
    ("z", "Folders", "Short form of jump", "z mobile"),
    ("qa", "Folders", "Managed quick folders", "qa downloads"),
    ("mark", "Folders", "Save a named folder", "mark vault ~/Documents/Vault"),
    ("marks", "Folders", "List bookmarks", "marks"),
    ("unmark", "Folders", "Remove a saved bookmark", "unmark old"),
    ("projects", "Folders", "Find a local repository", "projects --list"),
    ("back", "Folders", "Previous folder in this shell", "back"),
    ("up", "Folders", "Go up one or more levels", "up 2"),
    ("mkcd", "Folders", "Create a folder and enter it", "mkcd 'scratch idea'"),
    ("ll", "Files", "Readable folder listing", "ll"),
    ("ff", "Files", "Find filenames", "ff '*.swift' ."),
    ("ftext", "Files", "Search text using a regular expression", "ftext 'TODO|FIXME' ."),
    ("hashfile", "Files", "SHA-256 of a file", "hashfile file.zip"),
    ("comparefile", "Files", "Compare two files by SHA-256", "comparefile a.json b.json"),
    ("tempwork", "Files", "Create and enter a persistent scratch folder", "tempwork"),
    ("trash", "Files", "Move to Finder Trash after confirmation", "trash old.txt --dry-run"),
    ("bigfiles", "Files", "Largest files below a folder", "bigfiles . 15"),
    ("dirsize", "Files", "Size of each immediate child folder", "dirsize ."),
    ("zipto", "Files", "Create a new ZIP without overwriting", "zipto backup.zip src README.md"),
    ("unzipto", "Files", "Extract a ZIP into a new folder safely", "unzipto backup.zip restored"),
    ("todo", "Capture", "Capture a local task", "todo 'Check reconnect'"),
    ("todos", "Capture", "Show tasks", "todos --project"),
    ("tdone", "Capture", "Complete task IDs; done is a zsh keyword", "tdone 1 3"),
    ("note", "Capture", "Save an engineering observation", "note 'Fails after sleep'"),
    ("notes", "Capture", "Search saved notes", "notes reconnect"),
    ("recent-notes", "Capture", "Show the newest notes", "recent-notes 5"),
    ("session", "Focus", "Save or resume the next useful action", "session save 'Next: test retry'"),
    ("focus", "Focus", "Quiet in-shell countdown", "focus 15"),
    ("recent-command", "Focus", "Recall commands in this shell", "recent-command flutter"),
    ("port", "System", "Who is listening on this TCP port?", "port 8080"),
    ("netcheck", "System", "Test a TCP endpoint", "netcheck localhost 8080"),
    ("pathcheck", "System", "Show PATH order and missing/duplicate entries", "pathcheck"),
    ("envshow", "System", "List environment names, hiding their values", "envshow flutter"),
    ("sshgo", "System", "Pick an SSH host or connect by name", "sshgo"),
    ("sysinfo", "System", "Show Mac hardware and operating system", "sysinfo"),
    ("serialports", "System", "List serial device paths", "serialports"),
    ("usbinfo", "System", "Show connected USB devices", "usbinfo"),
    ("procfind", "System", "Find running processes", "procfind python"),
    ("jview", "Data", "Format JSON from a file or standard input", "jview config.json"),
    ("cliptools", "Data", "Copy path, read, or set clipboard text", "cliptools path"),
    ("b64", "Data", "Encode UTF-8 text as Base64", "b64 'hello'"),
    ("unb64", "Data", "Decode Base64 as UTF-8", "unb64 aGVsbG8="),
    ("urlencode", "Data", "Encode a URL component", "urlencode 'a b/c'"),
    ("urldecode", "Data", "Decode a URL component", "urldecode 'a%20b'"),
    ("uuidgenx", "Data", "Generate a UUID", "uuidgenx"),
    ("serve", "Python", "Serve a folder on loopback only", "serve 8000 ."),
    ("venv", "Python", "Create and activate a Python virtual environment", "venv .venv"),
    ("gst", "Git", "Git status in this repository", "gst"),
    ("gad", "Git", "Stage explicit paths on a feature branch", "gad src/example.py --dry-run"),
    ("gmsg", "Git", "Commit staged changes with confirmation", "gmsg 'fix: retry'"),
    ("gpsh", "Git", "Show guidance without pushing", "gpsh"),
    ("fs", "Forged & Sent", "Optional project workflows", "fs help"),
]
FS_ACTIONS = ["go", "mobile", "status", "doctor", "run", "ios", "test", "analyze", "format",
              "firebase", "preview", "docs", "architecture", "open", "diff", "branch", "pr", "ci", "help", "menu"]


def clean(value):
    return re.sub(r"[\x00-\x1f\x7f-\x9f]", " ", str(value))


def need(condition, message):
    if not condition:
        raise ValueError(message)


def capture(text):
    need(bool(text.strip()), "Supply some text.")
    need(len(text) <= 4000 and not SECRET.search(text), "Capture refused: too long or looks like a credential.")
    return clean(text.strip())


def run(argv, cwd=None, timeout=None, output=False):
    need(bool(argv[0]) and (Path(argv[0]).is_file() or shutil.which(str(argv[0]))),
         f"Tool unavailable: {argv[0]}. Run ph.")
    env = {**os.environ, "GIT_OPTIONAL_LOCKS": "0"}
    result = subprocess.run([str(x) for x in argv], cwd=cwd, env=env, timeout=timeout,
                            text=True, capture_output=output, check=False)
    if result.returncode:
        raise RuntimeError(clean(result.stderr.strip()) if output and result.stderr else
                           f"{Path(str(argv[0])).name} exited {result.returncode}.")
    return result.stdout.strip() if output else None


def settings():
    path = CONFIG / "settings.json"
    values = dict(DEFAULTS)
    if path.exists():
        extra = json.loads(path.read_text())
        need(isinstance(extra, dict), "settings.json must contain an object.")
        for key, value in extra.items():
            validate_setting(key, value)
        values.update(extra)
    return values


def validate_setting(key, value):
    need(key in DEFAULTS, f"Unknown setting: {key}")
    if key in ("theme", "prompt"):
        need(value in (["auto", "normal", "forged"] if key == "theme" else ["minimal", "rich", "off"]),
             f"Invalid {key}.")
    elif isinstance(DEFAULTS[key], bool):
        need(isinstance(value, bool), f"{key} requires true or false.")
    elif key == "git_cache_seconds":
        need(type(value) is int and 2 <= value <= 120, "Cache interval must be 2–120 seconds.")
    elif key == "workspace_roots":
        need(isinstance(value, list) and all(isinstance(x, str) and x for x in value),
             "workspace_roots requires a JSON array of paths.")
    else:
        need(isinstance(value, str) and not re.search(r"[\r\n\x00]", value), f"Invalid {key}.")


def atomic_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as f:
        json.dump(value, f, indent=2)
        f.write("\n")
        tmp = Path(f.name)
    tmp.chmod(0o600)
    os.replace(tmp, path)


@contextlib.contextmanager
def database():
    STATE.mkdir(parents=True, exist_ok=True, mode=0o700)
    db = sqlite3.connect(STATE / "brain.sqlite3", timeout=5)
    db.execute("PRAGMA journal_mode=WAL")
    db.executescript("""
      CREATE TABLE IF NOT EXISTS bookmarks(name TEXT PRIMARY KEY, path TEXT NOT NULL);
      CREATE TABLE IF NOT EXISTS visits(path TEXT PRIMARY KEY, repo TEXT, count INTEGER, seen REAL);
      CREATE TABLE IF NOT EXISTS tasks(id INTEGER PRIMARY KEY, text TEXT, project TEXT, created TEXT, done INTEGER DEFAULT 0);
      CREATE TABLE IF NOT EXISTS notes(id INTEGER PRIMARY KEY, text TEXT, project TEXT, created TEXT);
      CREATE TABLE IF NOT EXISTS sessions(id INTEGER PRIMARY KEY, path TEXT, branch TEXT, text TEXT, created TEXT);
    """)
    try:
        with db:
            yield db
    finally:
        db.close()


def repo(path=None):
    try:
        return run(["git", "-C", str(path or Path.cwd()), "rev-parse", "--show-toplevel"], timeout=1, output=True)
    except (ValueError, RuntimeError, subprocess.TimeoutExpired):
        return ""


def is_forged(path):
    pub = Path(path) / "mobile/pubspec.yaml"
    return pub.is_file() and re.search(r"(?m)^name:\s*forged_and_sent\s*$", pub.read_text(errors="replace")) is not None


def project():
    current = repo()
    root = current if current and is_forged(current) else settings()["default_project"]
    need(root and Path(root).is_dir() and is_forged(root),
         "Enter your Forged & Sent checkout and run forge project first.")
    return Path(root)


def branch(path=None):
    return run(["git", "-C", str(path or Path.cwd()), "symbolic-ref", "--quiet", "--short", "HEAD"],
               timeout=1, output=True)


def feature_branch():
    current = branch()
    need(current.lower() not in ("main", "master", "production", "prod"),
         "Use your feature branch before staging, committing, or applying formatting.")


def confirm(question):
    need(sys.stdin.isatty(), "Confirmation needs an interactive terminal; use --dry-run to inspect.")
    return input(question + " [y/N] ").strip().lower() in ("y", "yes")


def pick(rows, query="", title="Choose"):
    rows = [(clean(label), value) for label, value in rows]
    if query:
        pattern = ".*?".join(re.escape(c) for c in query.lower())
        rows = [(label, value) for label, value in rows if re.search(pattern, label.lower())]
    need(rows, "No matches.")
    if query and len(rows) == 1:
        return rows[0][1]
    need(sys.stdin.isatty(), "A picker needs an interactive terminal. Supply an exact name/path or use --list.")
    if settings()["fzf"] and shutil.which("fzf"):
        result = subprocess.run(["fzf", "--height=60%", "--layout=reverse", "--border=rounded",
                                 "--delimiter=\t", "--with-nth=2..", "--prompt", title + " > "],
                                input="\n".join(f"{i}\t{x[0]}" for i, x in enumerate(rows)),
                                text=True, stdout=subprocess.PIPE, check=False)
        if result.returncode:
            raise KeyboardInterrupt
        return rows[int(result.stdout.split("\t", 1)[0])][1]
    for i, (label, _) in enumerate(rows[:30], 1):
        print(f"{i:2}. {label}", file=sys.stderr)
    print(f"{title} — number, or Enter to cancel: ", end="", file=sys.stderr, flush=True)
    choice = input().strip()
    if not choice:
        raise KeyboardInterrupt
    need(choice.isdigit() and 1 <= int(choice) <= min(30, len(rows)), "Choose a listed number.")
    return rows[int(choice) - 1][1]


def bookmarks():
    home = Path.home()
    values = {k: str(home / p) for k, p in
              [("home", ""), ("desktop", "Desktop"), ("documents", "Documents"), ("downloads", "Downloads")]}
    if settings()["default_project"]:
        values["fs"] = settings()["default_project"]
    with database() as db:
        values.update(dict(db.execute("SELECT name,path FROM bookmarks")))
    return values


def project_paths():
    found = set()
    for root in settings()["workspace_roots"]:
        root = Path(root).expanduser()
        if root.is_dir():
            for p in [root, *(p for p in root.iterdir() if p.is_dir() and not p.is_symlink())]:
                if (p / ".git").exists():
                    found.add(str(p.resolve()))
    with database() as db:
        found.update(r[0] for r in db.execute("SELECT DISTINCT repo FROM visits WHERE repo != ''")
                     if Path(r[0]).is_dir())
    return sorted(found)


def resolve_cd(args):
    name, *args = args
    if name in ("jump", "z", "qa"):
        query = " ".join(args)
        if query and Path(query).expanduser().is_dir():
            result = Path(query).expanduser()
        else:
            marks = bookmarks()
            if query in marks:
                result = Path(marks[query])
            else:
                rows = [(f"{k}  {v}", v) for k, v in marks.items() if Path(v).is_dir()]
                with database() as db:
                    rows += [(p, p) for p, in db.execute("SELECT path FROM visits ORDER BY seen DESC LIMIT 100")
                             if Path(p).is_dir() and p not in marks.values()]
                result = Path(pick(rows, query, "JUMP"))
    elif name == "projects":
        result = Path(pick([(Path(p).name + "  " + p, p) for p in project_paths()], " ".join(args), "PROJECTS"))
    elif name == "mkcd":
        need(len(args) == 1, "mkcd 'folder'")
        result = Path(args[0]).expanduser()
        result.mkdir(parents=True, exist_ok=True)
    elif name == "tempwork":
        root = STATE / "scratch"
        root.mkdir(parents=True, exist_ok=True, mode=0o700)
        result = Path(tempfile.mkdtemp(prefix="scratch-", dir=root))
    elif name == "session":
        with database() as db:
            rows = [(f"{at}  {text}  {path}", (path, br, text)) for path, br, text, at in
                    db.execute("SELECT path,branch,text,created FROM sessions ORDER BY id DESC LIMIT 50")]
        path, br, text = pick(rows, " ".join(args[1:]), "RESUME")
        print(clean(f"Next: {text}\nSaved branch: {br}; the branch is unchanged."), file=sys.stderr)
        result = Path(path)
    elif name == "fs":
        result = project() / ("mobile" if args[0] == "mobile" else "")
    else:
        raise ValueError("Unknown navigation action.")
    need(result.is_dir(), "Folder no longer exists.")
    resolved = str(result.resolve())
    need("\n" not in resolved and "\r" not in resolved, "Paths containing line breaks are unsupported.")
    print(resolved)


def files(root, limit=20000):
    root = Path(root).expanduser()
    need(root.exists(), f"Path unavailable: {root}")
    if root.is_file():
        yield root
        return
    count = 0
    for parent, dirs, names in os.walk(root, followlinks=False):
        dirs[:] = [d for d in dirs if d not in SKIP and not (Path(parent) / d).is_symlink()]
        for name in names:
            p = Path(parent) / name
            if p.is_symlink():
                continue
            yield p
            count += 1
            if count >= limit:
                print("Search reached 20,000 files; narrow the folder.", file=sys.stderr)
                return


def file_hash(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for data in iter(lambda: f.read(1024 * 1024), b""):
            h.update(data)
    return h.hexdigest()


def archives(name, args):
    need(len(args) >= 2, "zipto archive.zip paths… / unzipto archive.zip new-folder")
    archive = Path(args[0]).expanduser().resolve()
    if name == "zipto":
        need(not archive.exists(), "Archive exists; choose a new filename.")
        inputs = [Path(x).expanduser().resolve() for x in args[1:]]
        need(all(p.exists() and not p.is_symlink() for p in inputs), "Every input must exist and be a regular path.")
        members = []
        for p in inputs:
            for entry in (files(p) if p.is_dir() else [p]):
                need(entry.resolve() != archive, "Archive cannot include itself.")
                members.append((entry, str(Path(p.name) / entry.relative_to(p)) if p.is_dir() else p.name))
        need(len({n for _, n in members}) == len(members), "Duplicate archive paths; choose distinct input names.")
        with zipfile.ZipFile(archive, "x", compression=zipfile.ZIP_DEFLATED) as z:
            for entry, member in members:
                z.write(entry, member)
        print(archive)
    else:
        destination = Path(args[1]).expanduser().resolve()
        need(not destination.exists(), "Extraction destination must be a new folder.")
        with zipfile.ZipFile(archive) as z:
            total = 0
            for info in z.infolist():
                p = Path(info.filename.replace("\\", "/"))
                need(not p.is_absolute() and ".." not in p.parts and not re.match(r"^[A-Za-z]:", info.filename),
                     "Unsafe archive path.")
                need((info.external_attr >> 16) & 0o170000 != 0o120000, "Archive symlinks are refused.")
                total += info.file_size
            need(len(z.infolist()) <= 20000 and total <= 2 * 1024**3, "Archive exceeds the 20,000-file / 2 GiB limit.")
            destination.mkdir(parents=True)
            z.extractall(destination)
        print(destination)


def search(name, args):
    query = args[0] if args else "*"
    root = args[1] if len(args) > 1 else "."
    if name == "ftext" and shutil.which("rg"):
        result = subprocess.run(["rg", "--line-number", "--smart-case", "--glob", "!.env*",
                                 "--glob", "!*.pem", "--glob", "!*.key", "--", query, root])
        need(result.returncode <= 1, "ripgrep failed.")
        return
    pattern = query if any(x in query for x in "*?[") else "*" + query + "*"
    regex = re.compile(query, 0 if any(c.isupper() for c in query) else re.I) if name == "ftext" else None
    for p in files(root):
        if name == "ff":
            if fnmatch.fnmatch(p.name.lower(), pattern.lower()):
                print(clean(p))
        elif p.stat().st_size <= 2 * 1024**2 and not (
            p.name.startswith((".env", "id_rsa", "id_ed25519")) or p.suffix in (".pem", ".key")):
            try:
                text = p.read_text(encoding="utf-8")
                if "\0" in text:
                    continue
                for i, line in enumerate(text.splitlines(), 1):
                    if regex.search(line):
                        print(clean(f"{p}:{i}:{line}"))
            except (UnicodeError, PermissionError):
                continue


def captures(name, args):
    tag = repo() or str(Path.cwd())
    now = dt.datetime.now().astimezone().isoformat(timespec="seconds")
    with database() as db:
        if name in ("todo", "note"):
            text = capture(" ".join(args))
            table = "tasks" if name == "todo" else "notes"
            cur = db.execute(f"INSERT INTO {table}(text,project,created) VALUES (?,?,?)", (text, tag, now))
            print(f"Saved #{cur.lastrowid}: {text}")
        elif name == "tdone":
            ids = [int(v) for a in args for v in a.split(",")]
            need(ids, "tdone ID [ID…]")
            for i in ids:
                cursor = db.execute("UPDATE tasks SET done=1 WHERE id=?", (i,))
                print(f"#{i}: {'done' if cursor.rowcount else 'not found'}")
        elif name in ("todos", "notes", "recent-notes"):
            table = "tasks" if name == "todos" else "notes"
            where, values = [], []
            if "--project" in args:
                where.append("project=?")
                values.append(tag)
            if name == "todos" and "--all" not in args:
                where.append("done=0")
            query = " ".join(x for x in args if not x.startswith("--")) if name == "notes" else ""
            if query:
                where.append("instr(lower(text),lower(?)) > 0")
                values.append(query)
            sql = f"SELECT id,text,project,created{',done' if table == 'tasks' else ''} FROM {table}"
            if where:
                sql += " WHERE " + " AND ".join(where)
            sql += " ORDER BY id DESC"
            if name == "recent-notes":
                count = int(args[0]) if args else 10
                need(1 <= count <= 100, "Count must be 1–100.")
                sql += " LIMIT ?"
                values.append(count)
            for row in db.execute(sql, values):
                state = ("DONE" if row[4] else "OPEN") if table == "tasks" else row[3]
                print(f"#{row[0]} [{clean(state)}] {clean(row[1])}\n  {clean(row[2])}")
        elif name == "session":
            action = args[0] if args else "summary"
            if action == "save":
                text = capture(" ".join(args[1:]))
                try:
                    br = branch()
                except (ValueError, RuntimeError):
                    br = ""
                db.execute("INSERT INTO sessions(path,branch,text,created) VALUES (?,?,?,?)",
                           (str(Path.cwd()), br, text, now))
                db.execute("DELETE FROM sessions WHERE id NOT IN (SELECT id FROM sessions ORDER BY id DESC LIMIT 50)")
                print("Checkpoint saved.")
            elif action == "list":
                for row in db.execute("SELECT id,created,text,path FROM sessions ORDER BY id DESC"):
                    print(clean(" | ".join(map(str, row))))
            elif action == "summary":
                count = db.execute("SELECT count(*) FROM tasks WHERE done=0 AND project=?", (tag,)).fetchone()[0]
                print(f"Folder: {clean(Path.cwd())}\nProject: {clean(tag)}\nOpen tasks: {count}\nNext: session save 'next action'")
            else:
                raise ValueError("session [summary|save TEXT|list|resume QUERY]")


def prompt_cache(folder, target):
    root = repo(folder)
    label = "FORGED & SENT" if root and is_forged(root) else Path(root).name if root else ""
    br, detail = "", ""
    if root:
        try:
            result = run(["git", "-C", root, "status", "--porcelain=v1", "--branch"],
                         timeout=0.8, output=True)
            rows = result.splitlines()
            br = re.sub(r"^## (?:No commits yet on |Initial commit on )?", "", rows[0]).split("...")[0]
            changed = [x for x in rows[1:] if x]
            staged = sum(x[0] not in (" ", "?") for x in changed)
            unstaged = sum(len(x) > 1 and x[1] not in (" ", "?") for x in changed)
            untracked = sum(x.startswith("??") for x in changed)
            conflict = any(x[:2] in ("DD", "AU", "UD", "UA", "DU", "AA", "UU") for x in changed)
            detail = "CONFLICT" if conflict else f"~{unstaged} +{staged} ?{untracked}" if changed else "clean"
        except (RuntimeError, ValueError, subprocess.TimeoutExpired):
            detail = "status unavailable"
    target = Path(target)
    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    with tempfile.NamedTemporaryFile("w", dir=target.parent, delete=False) as f:
        f.write("\n".join(clean(x) for x in (folder, label, br, detail)) + "\n")
        tmp = f.name
    os.replace(tmp, target)


def fs(args):
    action = args[0] if args else "help"
    args = args[1:]
    if action in ("help", "menu"):
        print("fs " + " / ".join(FS_ACTIONS))
        print("Use fs run --emulator for local Firebase. Add --dry-run to inspect launch/write commands.")
        return
    need(action in FS_ACTIONS, "Unknown fs action. Use fs help.")
    root = project()
    mobile = root / "mobile"
    flutter = Path(settings()["flutter_sdk"]).expanduser() / "bin/flutter"
    launcher_sdk = Path.home() / "develop/flutter/bin/flutter"
    dry = "--dry-run" in args
    args = [x for x in args if x != "--dry-run"]
    if action == "doctor":
        print(f"Checkout: {root}\nConfigured SDK: {flutter}\nPATH Flutter: {shutil.which('flutter')}")
        version = flutter.parent / "cache/flutter.version.json"
        print("Flutter version: " + (str(json.loads(version.read_text()).get("flutterVersion", "unknown")) if version.exists() else "unknown"))
        ci = root / ".github/workflows/ci-gate.yml"
        pin = re.search(r"flutter-version:\s*'([^']+)'", ci.read_text()) if ci.exists() else None
        print("CI pin: " + (pin[1] if pin else "unknown"))
        print(f"Web host: {(mobile / 'web/index.html').is_file()}\niOS host: {(mobile / 'ios').is_dir()}")
        for p in (9099, 8080, 9199):
            netcheck("127.0.0.1", p)
        return
    plans = {
        "status": (["git", "status", "--short", "--branch"], root),
        "diff": (["git", "--no-pager", "diff", "--"], root),
        "test": ([flutter, "test"], mobile),
        "analyze": ([flutter, "analyze"], mobile),
        "format": ([flutter.parent / "dart", "format",
                    *([] if "--apply" in args else ["--output=none", "--set-exit-if-changed"]), "lib", "test"], mobile),
        "run": (["/bin/bash", root / "tooling/macos" / ("run-emulator-app.sh" if "--emulator" in args else "run-app.sh")], root),
        "ios": (["/bin/bash", root / "tooling/macos/run-ios.sh"], root),
        "firebase": (["/bin/bash", root / "tooling/macos/start-emulators.sh"], root),
        "preview": ([sys.executable, root / "dev/make_preview.py"], root),
        "architecture": ([sys.executable, root / "tooling/architecture/build_explorer.py", "--write"], root),
        "pr": (["gh", "pr", "list", "--repo", "Forged-Sent/ForgedAndSentFitness", "--limit", "10"], root),
        "ci": (["gh", "run", "list", "--repo", "Forged-Sent/ForgedAndSentFitness", "--limit", "10"], root),
        "open": (["code", str(root)], root),
    }
    if action == "docs":
        if args:
            search("ftext", [" ".join(args), str(root / "docs")])
        else:
            paths = sorted((root / "docs").rglob("*.md"))
            selected = pick([(str(p.relative_to(root)), p) for p in paths], title="DOCS")
            run(["open", selected])
        return
    if action == "branch":
        branches = run(["git", "for-each-ref", "--format=%(refname:short)", "refs/heads"], cwd=root, output=True).splitlines()
        selected = args[0] if args else pick([(b, b) for b in branches], title="EXISTING BRANCH")
        need(selected in branches, "Choose an existing local branch.")
        need(not run(["git", "status", "--porcelain"], cwd=root, output=True), "Working tree has changes.")
        if dry:
            print(f"Would switch {root} to {clean(selected)}")
        elif confirm(f"Switch to {clean(selected)}?"):
            run(["git", "switch", "--", selected], cwd=root)
        return
    need(action in plans, "Run navigation through the shell function.")
    argv, cwd = plans[action]
    if dry:
        print(f"In {cwd}\n{shlex.join([str(x) for x in argv])}")
        return
    if action == "format" and "--apply" in args:
        need(branch(root).lower() not in ("main", "master", "production", "prod"), "Use a feature branch.")
    if action in ("run", "ios"):
        need(flutter.resolve() == launcher_sdk.resolve(), "Align flutter_sdk with ~/develop/flutter for repository launchers.")
        need((mobile / ("ios" if action == "ios" else "web/index.html")).exists(),
             "Platform host missing. Follow the repository setup instructions first.")
    if action == "firebase":
        config = json.loads((root / "firebase.json").read_text())
        need(all(config.get("emulators", {}).get(s, {}).get("host") in ("127.0.0.1", "localhost", "::1")
                 for s in ("auth", "firestore", "storage", "ui")), "Emulators must bind to loopback.")
    run(argv, cwd=cwd)
    if action == "preview":
        run(["open", root / "dev/preview.html"])
    elif action == "architecture":
        run(["open", root / "build/architecture-explorer/Architecture-Atlas.html"])


def netcheck(host, port):
    need(1 <= int(port) <= 65535, "Port must be 1–65535.")
    try:
        with socket.create_connection((host, int(port)), timeout=1.5):
            print(f"{clean(host)}:{port} reachable")
            return True
    except OSError:
        print(f"{clean(host)}:{port} unavailable")
        return False


def main(argv=None):
    args = list(sys.argv[1:] if argv is None else argv)
    name = args.pop(0) if args else "helpme"
    if name == "_resolve":
        return resolve_cd(args)
    if name == "_settings":
        for key, value in settings().items():
            if not isinstance(value, list):
                print(f"{key}\t{str(value).lower() if isinstance(value, bool) else clean(value)}")
        return
    if name == "_prompt":
        return prompt_cache(*args)
    if name == "_visit":
        with database() as db:
            db.execute("INSERT INTO visits VALUES(?,?,1,?) ON CONFLICT(path) DO UPDATE SET count=count+1,seen=excluded.seen,repo=excluded.repo",
                       (args[0], repo(args[0]), time.time()))
        return
    if name == "_menu":
        menu = [("Jump to a folder", "jump"), ("Choose a project", "projects"), ("Resume a checkpoint", "session resume"),
                ("Open tasks", "todos"), ("Recent notes", "recent-notes"), ("Git status", "gst"),
                ("Forged & Sent", "fs help"), ("Shell health", "ph"), ("All commands", "helpme")]
        print(pick(menu, title="NEXT USEFUL ACTION"))
        return
    if name == "_catalog":
        print(json.dumps([dict(zip(("name", "category", "description", "example"), row)) for row in CATALOG]))
        return
    if name in ("todo", "todos", "tdone", "note", "notes", "recent-notes", "session"):
        return captures(name, args)
    if name == "helpme":
        query = " ".join(args).lower()
        for row in CATALOG:
            if query in " ".join(row).lower():
                print(f"{row[0]:16} {row[2]}\n  {row[3]}")
    elif name == "keys":
        print("Tab: completion | Up/Down: prefix history | Ctrl+R: history search\n"
              "Ctrl+X H: insert helpme | Ctrl+X D: insert dash\n"
              "Picker: type/arrows/Enter with fzf; numbered choices otherwise.\n"
              "Leading space: skip saved history. Mac command keys stay with the terminal.")
    elif name in ("config", "theme", "prompt", "project"):
        values = settings()
        if name == "project":
            root = repo()
            need(root and is_forged(root), "Enter the Forged & Sent checkout first.")
            key, value = "default_project", root
        elif name in ("theme", "prompt") and args:
            key, value = name, args[0]
        elif name == "config" and len(args) >= 2:
            key = args[0]
            try:
                value = json.loads(" ".join(args[1:]))
            except json.JSONDecodeError:
                value = " ".join(args[1:])
        else:
            print(json.dumps(values if name == "config" else {name: values[name]}, indent=2))
            return
        validate_setting(key, value)
        values[key] = value
        atomic_json(CONFIG / "settings.json", values)
        print("Saved.")
    elif name == "context":
        root = repo()
        print(json.dumps({"folder": str(Path.cwd()), "repository": root, "forged": bool(root and is_forged(root))}, indent=2))
    elif name == "docs":
        run(["open", PACKAGE / "README.md"])
    elif name in ("ph", "doctor"):
        print(f"Forge Mac 1.0.0 | Python {sys.version.split()[0]}\nPackage: {PACKAGE}\nState: {STATE}")
        settings()
        for tool in ("git", "python3", "rg", "fzf", "flutter", "firebase", "gh", "code", "lsof", "pbcopy", "osascript"):
            print(f"{tool:12} {shutil.which(tool) or 'optional / unavailable'}")
        print("Configuration: valid")
    elif name in ("ptest", "test"):
        run([sys.executable, "-m", "unittest", "discover", "-s", PACKAGE / "tests", "-v"])
    elif name in ("ff", "ftext"):
        need(name != "ftext" or args, "ftext 'pattern' [folder]")
        search(name, args)
    elif name == "mark":
        need(args and re.fullmatch(r"[a-zA-Z][a-zA-Z0-9_-]{0,39}", args[0]), "mark name [folder]")
        p = Path(args[1] if len(args) > 1 else ".").expanduser().resolve()
        need(p.is_dir(), "Bookmark must point to a folder.")
        with database() as db:
            db.execute("INSERT OR REPLACE INTO bookmarks VALUES(?,?)", (args[0].lower(), str(p)))
        print(f"{args[0].lower()} → {p}")
    elif name == "marks":
        query = " ".join(args).lower()
        for k, p in sorted(bookmarks().items()):
            if query in (k + " " + p).lower():
                print(f"{k:16} {clean(p)}")
    elif name == "unmark":
        need(len(args) == 1, "unmark name")
        if confirm(f"Forget bookmark {clean(args[0])}?"):
            with database() as db:
                db.execute("DELETE FROM bookmarks WHERE name=?", (args[0].lower(),))
    elif name == "projects":
        print("\n".join(map(clean, project_paths())))
    elif name == "ll":
        for p in sorted(Path(args[0] if args else ".").expanduser().iterdir(), key=lambda p: (not p.is_dir(), p.name.lower())):
            print(f"{'DIR ' if p.is_dir() else 'FILE'} {p.stat().st_size:>12,}  {clean(p.name)}")
    elif name in ("hashfile", "comparefile"):
        need(len(args) == (2 if name == "comparefile" else 1), "Supply the file path(s).")
        hashes = [file_hash(p) for p in args]
        print(f"Identical: {hashes[0] == hashes[1]}" if name == "comparefile" else hashes[0])
    elif name in ("bigfiles", "dirsize"):
        root = Path(args[0] if args else ".").expanduser()
        entries = [(p.stat().st_size, p) for p in files(root)] if name == "bigfiles" else [
            (sum(f.stat().st_size for f in files(p)), p) for p in root.iterdir() if p.is_dir() and not p.is_symlink()]
        count = int(args[1]) if len(args) > 1 else 15
        need(1 <= count <= 100, "Count must be 1–100.")
        for size, p in sorted(entries, reverse=True)[:count]:
            print(f"{size / 1024**2:10.2f} MiB  {clean(p)}")
    elif name in ("zipto", "unzipto"):
        archives(name, args)
    elif name == "trash":
        need(args, "trash path [--dry-run]")
        original = Path(args[0]).expanduser()
        p = original.resolve()
        root = repo()
        need(original.exists() and not original.is_symlink(), "Use an existing regular file/folder.")
        need(p not in (Path("/"), Path.home(), Path.cwd()) and p not in Path.cwd().parents
             and ".git" not in p.parts and not (p / ".git").exists() and str(p) != root, "Protected location.")
        if "--dry-run" in args:
            print(f"Would move to Finder Trash: {p}")
        elif confirm(f"Move {clean(p)} to Finder Trash?"):
            script = 'on run argv\n tell application "Finder" to delete (POSIX file (item 1 of argv))\nend run'
            run(["osascript", "-e", script, str(p)])
    elif name == "port":
        target = f"-iTCP:{int(args[0])}" if args else "-iTCP"
        run(["lsof", "-nP", target, "-sTCP:LISTEN"])
    elif name == "netcheck":
        netcheck(args[0] if args else "127.0.0.1", int(args[1]) if len(args) > 1 else 8080)
    elif name == "pathcheck":
        seen = set()
        for i, p in enumerate(os.environ.get("PATH", "").split(os.pathsep), 1):
            print(f"{i:2} {'missing' if not Path(p).is_dir() else 'exists ':7} {'duplicate' if p in seen else '':9} {clean(p)}")
            seen.add(p)
    elif name == "envshow":
        query = " ".join(args).lower()
        for k, v in sorted(os.environ.items()):
            if query in k.lower():
                print(f"{k:40} length={len(v)} [hidden]")
    elif name == "sshgo":
        host = args[0] if args else ""
        if not host:
            config = Path.home() / ".ssh/config"
            need(config.exists(), "No SSH config; use sshgo user@host.")
            names = [n for line in config.read_text().splitlines() if re.match(r"^\s*Host\s", line, re.I)
                     for n in line.split()[1:] if not re.search(r"[*?!]", n)]
            host = pick([(n, n) for n in names], title="SSH HOST")
        need(re.fullmatch(r"[A-Za-z0-9_][A-Za-z0-9_.@:-]*", host), "Use a configured alias or user@hostname.")
        run(["ssh", host])
    elif name == "sysinfo":
        run(["sw_vers"])
        run(["system_profiler", "SPHardwareDataType", "-detailLevel", "mini"])
    elif name == "serialports":
        print("\n".join(str(p) for p in sorted(Path("/dev").glob("cu.*"))))
    elif name == "usbinfo":
        run(["system_profiler", "SPUSBDataType", "-detailLevel", "mini"])
    elif name == "procfind":
        query = " ".join(args).lower()
        for line in run(["ps", "-axo", "pid,ppid,%cpu,%mem,comm"], output=True).splitlines():
            if query in line.lower():
                print(clean(line))
    elif name == "jview":
        pathargs = [x for x in args if x != "--minify"]
        need(pathargs or not sys.stdin.isatty(), "jview file.json or pipe JSON into jview.")
        data = Path(pathargs[0]).expanduser().read_text() if pathargs else sys.stdin.read()
        print(json.dumps(json.loads(data), indent=None if "--minify" in args else 2, ensure_ascii=False))
    elif name == "cliptools":
        action = args[0] if args else "path"
        need(action in ("path", "get", "set"), "cliptools [path|get|set TEXT]")
        if action == "get":
            run(["pbpaste"])
        else:
            need(shutil.which("pbcopy"), "pbcopy is available on macOS.")
            subprocess.run(["pbcopy"], input=str(Path.cwd()) if action == "path" else " ".join(args[1:]), text=True, check=True)
    elif name in ("b64", "unb64", "urlencode", "urldecode"):
        text = " ".join(args)
        operations = {"b64": lambda s: base64.b64encode(s.encode()).decode(),
                      "unb64": lambda s: base64.b64decode(s, validate=True).decode(),
                      "urlencode": lambda s: urllib.parse.quote(s, safe=""), "urldecode": urllib.parse.unquote}
        print(operations[name](text))
    elif name == "uuidgenx":
        print(uuid.uuid4())
    elif name == "serve":
        port = int(args[0]) if args else 8000
        need(1 <= port <= 65535, "Port must be 1–65535.")
        directory = str(Path(args[1] if len(args) > 1 else ".").expanduser().resolve())
        print(f"Serving {directory} at http://127.0.0.1:{port}; Ctrl+C stops it.", flush=True)
        run([sys.executable, "-m", "http.server", str(port), "--bind", "127.0.0.1", "--directory", directory])
    elif name == "gst":
        run(["git", "status", "--short", "--branch"])
    elif name in ("gad", "gmsg"):
        feature_branch()
        dry = "--dry-run" in args
        args = [a for a in args if a != "--dry-run"]
        need(args, "Supply explicit paths or a commit message.")
        if name == "gad":
            need(all(x not in (".", "*", ":/") and not any(c in x for c in "*?[") for x in args),
                 "Choose explicit paths; broad pathspecs are refused.")
            argv = ["git", "add", "--", *args]
        else:
            argv = ["git", "commit", "-m", capture(" ".join(args))]
        if dry:
            print(shlex.join(argv))
        elif name == "gad" or confirm("Commit the already-staged changes?"):
            run(argv)
    elif name == "gpsh":
        print("No push executed. Review status, changes, PR reviews, and CI. Use your repository's authorized sharing workflow.")
    elif name == "fs":
        fs(args)
    else:
        raise ValueError(f"Unknown command: {name}. Use helpme.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)
    except (ValueError, RuntimeError, OSError, sqlite3.Error, subprocess.SubprocessError) as error:
        print("Forge: " + clean(error), file=sys.stderr)
        sys.exit(1)
