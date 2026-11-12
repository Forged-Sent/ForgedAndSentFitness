#!/usr/bin/env python3
"""Backed-up user installation. Preview is the default; --apply changes files."""
from __future__ import annotations
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import sys
import tempfile

SOURCE = Path(__file__).resolve().parent
START = "# >>> Forge Mac managed loader >>>"
END = "# <<< Forge Mac managed loader <<<"
PATTERN = re.compile(r"(?ms)^" + re.escape(START) + r"\n.*?^" + re.escape(END) + r"\n?")
GSTART = "# >>> Forge Mac managed colors >>>"
GEND = "# <<< Forge Mac managed colors <<<"
GPATTERN = re.compile(r"(?ms)^" + re.escape(GSTART) + r"\n.*?^" + re.escape(GEND) + r"\n?")

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None

def check_markers(text, start, end, pattern):
    if text.count(start) != text.count(end) or text.count(start) > 1:
        raise ValueError("Managed markers are malformed; preserve this file and repair the markers first.")
    if start in text and not pattern.search(text):
        raise ValueError("Managed block could not be identified safely.")

def atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("wb", dir=path.parent, delete=False) as f:
        f.write(data)
        temp = Path(f.name)
    temp.chmod(path.stat().st_mode & 0o777 if path.exists() else 0o600)
    os.replace(temp, path)

def color(hexcode):
    return {**{name + " Component": int(hexcode[i:i+2], 16) / 255
               for name, i in (("Red", 0), ("Green", 2), ("Blue", 4))},
            "Alpha Component": 1.0, "Color Space": "sRGB"}

def terminal_assets():
    palette = ["151719", "F08076", "7EC89A", "E0C46C", "79B8C8", "B89ACB", "7CC5C1", "D6D8DA",
               "929CA5", "FF9A90", "9FE0B4", "F0D998", "A2D1DF", "CFB2DF", "A2DEDA", "F2F0EB"]
    profiles = []
    for label, accent, guid in [
        ("Graphite", "79B8C8", "f317f146-02a9-4f51-99db-830e9240b201"),
        ("Ember", "F17B32", "f317f146-02a9-4f51-99db-830e9240b202")]:
        profile = {"Name": "Forge " + label, "Guid": guid, "Custom Command": "Yes",
                   "Command": "/bin/zsh -l", "Normal Font": "Menlo-Regular 14",
                   "Non Ascii Font": "Menlo-Regular 14", "Transparency": 0.0,
                   "Background Color": color("151719"), "Foreground Color": color("F2F0EB"),
                   "Cursor Color": color(accent), "Cursor Text Color": color("151719"),
                   "Selection Color": color("303538"), "Selected Text Color": color("F2F0EB")}
        profile.update({f"Ansi {i} Color": color(c) for i, c in enumerate(palette)})
        profiles.append(profile)
    ghostty = "\n".join([
        "# Forge Graphite — imported with config-file",
        "font-family = Menlo", "font-size = 14", "background = #151719", "foreground = #F2F0EB",
        "cursor-color = #79B8C8", "cursor-text = #151719", "selection-background = #303538",
        "selection-foreground = #F2F0EB", "window-padding-x = 12", "window-padding-y = 10",
        *[f"palette = {i}=#{c}" for i, c in enumerate(palette)], ""])
    return (json.dumps({"Profiles": profiles}, indent=2) + "\n").encode(), ghostty.encode()

def installation(home, terminal="iterm2", uninstall=False, zdotdir=None, project_root=None):
    home = Path(home).resolve()
    destination = home / ".config/forge-mac"
    state = home / ".local/state/forge-mac"
    rc = (Path(zdotdir).expanduser().resolve() if zdotdir else home) / ".zshrc"
    if rc.is_symlink():
        raise ValueError(".zshrc is a symlink. Add/remove the documented loader manually in its target.")
    old = rc.read_text() if rc.exists() else ""
    check_markers(old, START, END, PATTERN)
    stripped = PATTERN.sub("", old)
    if uninstall:
        writes = {rc: stripped.encode()} if stripped != old else {}
    else:
        loader = "\n".join([START, 'if [[ -r ' + shlex.quote(str(destination / "forge.zsh")) + ' ]]; then',
                           "  source " + shlex.quote(str(destination / "forge.zsh")), "fi", END, ""])
        writes = {rc: (stripped.rstrip("\n") + "\n\n" + loader).lstrip("\n").encode()}
        for path in SOURCE.rglob("*"):
            if not path.is_file() or any(p in ("__pycache__", ".qa") for p in path.relative_to(SOURCE).parts):
                continue
            relative = path.relative_to(SOURCE)
            if relative.as_posix() in (".gitignore", "settings.json"):
                continue
            writes[destination / relative] = path.read_bytes()
        # Seed this clone only for a fresh installation; upgrades keep preferences.
        settings = destination / "settings.json"
        if project_root and not settings.exists():
            project = Path(project_root).expanduser().resolve()
            if not (project / "mobile/pubspec.yaml").is_file():
                raise ValueError("--project-root must point to a Forged & Sent checkout.")
            writes[settings] = (json.dumps({
                "default_project": str(project), "workspace_roots": [str(project.parent)],
                "flutter_sdk": str(home / "develop/flutter")
            }, indent=2) + "\n").encode()
    profiles, ghostty = terminal_assets()
    iterm_path = home / "Library/Application Support/iTerm2/DynamicProfiles/Forge-Mac.json"
    ghost_root = home / "Library/Application Support/com.mitchellh.ghostty"
    ghost_path = ghost_root / ("config.ghostty" if (ghost_root / "config.ghostty").exists()
                              or not (ghost_root / "config").exists() else "config")
    if not uninstall:
        if terminal == "iterm2":
            if iterm_path.exists() and iterm_path.read_bytes() != profiles:
                raise ValueError("Forge-Mac.json already has different contents. Rename it or choose --terminal none.")
            writes[iterm_path] = profiles
        elif terminal == "ghostty":
            text = ghost_path.read_text() if ghost_path.exists() else ""
            check_markers(text, GSTART, GEND, GPATTERN)
            theme_path = destination / "themes/graphite.ghostty"
            writes[theme_path] = ghostty
            block = f"{GSTART}\nconfig-file = {theme_path}\n{GEND}\n"
            writes[ghost_path] = (GPATTERN.sub("", text).rstrip("\n") + "\n\n" + block).lstrip("\n").encode()
    else:
        if ghost_path.exists():
            text = ghost_path.read_text()
            check_markers(text, GSTART, GEND, GPATTERN)
            changed = GPATTERN.sub("", text)
            if changed != text:
                writes[ghost_path] = changed.encode()
        if iterm_path.exists() and iterm_path.read_bytes() == profiles:
            writes[iterm_path] = None
    for target in writes:
        if target.is_symlink() or any(p.is_symlink() for p in target.parents if p != home.parent):
            raise ValueError(f"Symlinked installation path: {target}. Use the manual loader instructions.")
        if target != rc and home not in target.resolve().parents:
            raise ValueError("An installation target escaped your home folder.")
    return writes, state

def apply(writes, state, dry_run=True):
    changed = {p: data for p, data in writes.items()
               if (p.read_bytes() if p.is_file() else None) != data}
    for path in changed:
        print(("Would remove " if changed[path] is None else "Would write ") + str(path))
    if dry_run or not changed:
        return None
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup = Path(state) / "backups" / stamp
    backup.mkdir(parents=True, mode=0o700)
    entries = []
    for index, (path, content) in enumerate(changed.items()):
        original = path.read_bytes() if path.exists() else None
        copy = backup / f"{index:04}.bak"
        if original is not None:
            copy.write_bytes(original)
            copy.chmod(0o600)
        entries.append({"path": str(path), "backup": copy.name, "existed": original is not None,
                        "original_hash": digest(path),
                        "installed_hash": hashlib.sha256(content).hexdigest() if content is not None else None})
    atomic(backup / "manifest.json", json.dumps({"version": 1, "entries": entries}, indent=2).encode())
    completed = []
    try:
        for path, content in changed.items():
            if content is None:
                path.unlink()
            else:
                atomic(path, content)
            completed.append(path)
    except BaseException:
        for entry in entries:
            path = Path(entry["path"])
            if path not in completed:
                continue
            if entry["existed"]:
                atomic(path, (backup / entry["backup"]).read_bytes())
            elif path.exists():
                path.unlink()
        raise
    print(f"Applied. Backup: {backup}\nOpen a new zsh tab.")
    return backup

def restore(backup, home, dry_run=True):
    backup = Path(backup).expanduser().resolve()
    home = Path(home).resolve()
    manifest = json.loads((backup / "manifest.json").read_text())
    if manifest.get("version") != 1:
        raise ValueError("Unsupported manifest.")
    writes = {}
    for entry in manifest["entries"]:
        path = Path(entry["path"])
        if home not in path.resolve().parents or path.is_symlink():
            raise ValueError("Restore target is outside your home or is a symlink.")
        if digest(path) != entry["installed_hash"]:
            raise ValueError(f"Later edits detected: {path}. Use targeted --uninstall to preserve them.")
        copy = backup / entry["backup"]
        if copy.resolve().parent != backup:
            raise ValueError("Backup path escaped its directory.")
        if entry["existed"] and digest(copy) != entry["original_hash"]:
            raise ValueError("Backup integrity check failed.")
        writes[path] = copy.read_bytes() if entry["existed"] else None
    return apply(writes, home / ".local/state/forge-mac", dry_run)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Apply the printed plan; default only previews.")
    parser.add_argument("--terminal", choices=["iterm2", "ghostty", "none"], default="iterm2")
    parser.add_argument("--uninstall", action="store_true", help="Remove managed loader/styling; retain data and package.")
    parser.add_argument("--restore", metavar="BACKUP_DIRECTORY")
    parser.add_argument("--project-root", help="Remember this checkout on first install; preserve existing preferences.")
    opts = parser.parse_args()
    if sys.version_info < (3, 10):
        parser.error("Python 3.10+ is required. Run the Homebrew tools installer or choose FORGE_PYTHON explicitly.")
    if sys.platform != "darwin":
        parser.error("Run this installer on your Mac. Tests can exercise the planning functions on other platforms.")
    if os.geteuid() == 0:
        parser.error("Run as your normal user, without sudo.")
    if opts.restore:
        restore(opts.restore, Path.home(), not opts.apply)
    else:
        writes, state = installation(Path.home(), opts.terminal, opts.uninstall,
                                     os.environ.get("ZDOTDIR") or os.environ.get("FORGE_ZDOTDIR"),
                                     opts.project_root)
        apply(writes, state, not opts.apply)

if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, json.JSONDecodeError) as error:
        sys.exit("Forge installer: " + str(error))
