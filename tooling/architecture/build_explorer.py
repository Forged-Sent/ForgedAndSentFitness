#!/usr/bin/env python3
"""Build an offline, navigable architecture explorer from tracked repo files.

Python 3.11+ stdlib only. Every tracked path is indexed. Symbol extraction and
dependency edges are explicitly lexical/best-effort, not full program analysis.
"""
from __future__ import annotations

import argparse
import ast
import json
import re
import shutil
import subprocess
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[2]
MODEL = "docs/architecture/explorer/model.json"
SOURCE = ROOT / "docs/architecture/explorer"
OUTPUT = ROOT / "build/architecture-explorer"
REPO_URL = "https://github.com/Forged-Sent/ForgedAndSentFitness"
MAX_SOURCE = 180_000
MAX_SYMBOLS = 150
MAX_EXCERPT = 11

DART_CLASS = re.compile(r"^\s*(?:abstract\s+|sealed\s+|final\s+)?class\s+([A-Za-z_]\w*)\b")
DART_FN = re.compile(
    r"^\s*(?:(?:static|external|async)\s+)*(?:Future(?:<[^>]+>)?|"
    r"FutureOr(?:<[^>]+>)?|Widget|String|bool|void|int|double|"
    r"Stream(?:<[^>]+>)?|List(?:<[^>]+>)?|Map(?:<[^>]+>)?)"
    r"\s+(?:(?:get|set)\s+)?([A-Za-z_]\w*)\s*(?:\(|=>|\{)"
)
JS_FN = re.compile(r"^\s*(?:(?:export|async|default)\s+)*function\s+([A-Za-z_$][\w$]*)\s*\(|"
                   r"^\s*(?:const|let)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s*)?\(")
CLASS_JS = re.compile(r"^\s*(?:export\s+)?class\s+([A-Za-z_$][\w$]*)\b")
PS_FN = re.compile(r"^\s*function\s+([A-Za-z_][\w-]*)\s*(?:\(|\{)", re.I)
SH_FN = re.compile(r"^\s*(?:function\s+)?([A-Za-z_]\w*)\(\)\s*\{")
YAML_JOB = re.compile(r"^  ([a-zA-Z][a-zA-Z0-9_-]*):\s*$")
HEADER = re.compile(r"^(#{1,4})\s+(.{1,120})$")
IMPORT_DART = re.compile(r"^\s*(?:import|export|part)\s+['\"]([^'\"]+)['\"]")
IMPORT_JS = re.compile(r"^\s*(?:import|export)\s+.*?from\s+['\"]([^'\"]+)['\"]")
MARKDOWN_LINK = re.compile(r"\]\(([^) #]+)(?:#[^)]+)?\)")
PATH_REF = re.compile(r"(?<![\w.-])(?:[.\w-]+/)+[\w.-]+\.(?:dart|py|js|mjs|md|json|yaml|yml|sh|ps1|cmd|toml|rules|html|command)\b")
SECRET = re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |)PRIVATE KEY-----|github_pat_|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}", re.I)


def tracked(root: Path) -> list[str]:
    proc = subprocess.run(["git", "ls-files", "-z"], cwd=root, capture_output=True, check=True)
    return sorted(p.decode("utf-8", errors="replace") for p in proc.stdout.split(b"\0") if p)


def category(path: str) -> str:
    if path == "index.html" or path.startswith(("versions/", "dev/")):
        return "prototype"
    if path.startswith("mobile/"):
        return "flutter"
    if path.startswith("firebase/") or path in ("firebase.json", ".firebaserc"):
        return "firebase"
    if path.startswith((".agents/", ".claude/", ".codex/", ".github/agents/")) or path in ("AGENTS.md", "CLAUDE.md", "GEMINI.md"):
        return "agents"
    if path.startswith(".github/"):
        return "automation"
    if path.startswith("tooling/"):
        return "tooling"
    if path.startswith(("docs/", "README")):
        return "docs"
    if path.startswith("seed/"):
        return "data"
    return "other"


def language(path: str) -> str:
    name = PurePosixPath(path).name
    if name.startswith("app-v") and path.startswith("versions/"):
        return "html-archive"
    return {
        ".py":"python", ".dart":"dart", ".ps1":"powershell", ".sh":"shell", ".command":"shell",
        ".js":"javascript", ".mjs":"javascript", ".yml":"yaml", ".yaml":"yaml",
        ".md":"markdown", ".json":"json", ".rules":"firebase-rules", ".html":"html",
        ".cmd":"batch", ".toml":"toml"
    }.get(PurePosixPath(path).suffix.lower(), "text")


def purpose(path: str, model: dict) -> str:
    for node in model["systems"]:
        if node["stage"] == "current" and path in node.get("files", []):
            return node["purpose"]
    if path.startswith("versions/"):
        return "Archived prototype snapshot. Searchable by filename; large archived source is not embedded."
    return "No curated summary yet. Inspect the linked source; automated symbol and reference extraction is best effort."


def file_data(root: Path, path: str) -> tuple[list[str], bool]:
    file = root / path
    try:
        if file.stat().st_size > MAX_SOURCE:
            return [], True
        return file.read_text(encoding="utf-8").splitlines(), False
    except (UnicodeError, OSError):
        return [], True


def make_symbol(path: str, name: str, kind: str, line: int, lines: list[str],
                notes: dict, summary: str = "") -> dict:
    key = f"{path}::{name}"
    short = name.split(".")[-1]
    doc = notes.get(key, notes.get(f"{path}::{short}", ""))
    excerpt = "\n".join(lines[line-1:min(len(lines), line+MAX_EXCERPT-1)])[:1000]
    if SECRET.search(excerpt):
        excerpt = "[Source excerpt suppressed; inspect repository file directly.]"
    return {
        "id":f"{path}:{line}:{name}", "name":name, "kind":kind, "line":line,
        "signature":lines[line-1].strip()[:190], "description":doc or summary or
        "No vetted behavior summary yet. Read the implementation and tests.",
        "curated":bool(doc), "excerpt":excerpt
    }


def symbols_for(path: str, lines: list[str], notes: dict) -> list[dict]:
    out: list[dict] = []
    lang = language(path)
    if lang == "python":
        try:
            tree = ast.parse("\n".join(lines), filename=path)
        except (SyntaxError, ValueError):
            return []
        def visit(nodes, prefix=""):
            for node in nodes:
                if isinstance(node, ast.ClassDef):
                    name = prefix + node.name
                    summary = (ast.get_docstring(node) or "").split("\n")[0][:200]
                    out.append(make_symbol(path, name, "class", node.lineno, lines, notes, summary))
                    visit(node.body, name+".")
                elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    name = prefix + node.name
                    summary = (ast.get_docstring(node) or "").split("\n")[0][:200]
                    out.append(make_symbol(path, name, "function", node.lineno, lines, notes, summary))
                    visit(node.body, name+".")
        visit(tree.body)
    elif lang in ("dart", "javascript"):
        current_class = ""
        for idx, line in enumerate(lines, 1):
            c = (DART_CLASS if lang == "dart" else CLASS_JS).search(line)
            if c:
                current_class = c.group(1)
                out.append(make_symbol(path, current_class, "class", idx, lines, notes))
            else:
                f = (DART_FN if lang == "dart" else JS_FN).search(line)
                if f:
                    name = next((g for g in f.groups() if g), "")
                    # Dart methods have their owning class as a readable prefix.
                    name = (current_class + "." + name) if current_class and name not in ("main",) else name
                    out.append(make_symbol(path, name, "function", idx, lines, notes))
    elif lang in ("powershell", "shell"):
        expression = PS_FN if lang == "powershell" else SH_FN
        for idx, line in enumerate(lines, 1):
            m = expression.search(line)
            if m:
                out.append(make_symbol(path, m.group(1), "function", idx, lines, notes))
    elif lang == "yaml" and path.startswith(".github/workflows/"):
        for idx, line in enumerate(lines, 1):
            m = YAML_JOB.match(line)
            if m and m.group(1) not in ("on", "permissions", "concurrency"):
                out.append(make_symbol(path, m.group(1), "CI job", idx, lines, notes))
    elif lang == "markdown":
        for idx, line in enumerate(lines, 1):
            m = HEADER.match(line)
            if m:
                out.append(make_symbol(path, m.group(2).strip(), "section", idx, lines, notes))
    elif lang == "json" and path in ("firebase.json", "tooling/versions.json", "mobile/pubspec.yaml"):
        try:
            for key in json.loads("\n".join(lines)):
                out.append(make_symbol(path, key, "config key", 1, lines, notes))
        except (ValueError, TypeError):
            pass
    return out[:MAX_SYMBOLS]


def resolve_relative(path: str, target: str, known: set[str]) -> str | None:
    if target.startswith(("http:", "https:", "#", "mailto:", "data:")):
        return None
    # Repo-relative names as well as relative to current file.
    possibilities = [target, str(PurePosixPath(path).parent / target)]
    for candidate in possibilities:
        parts = []
        for piece in candidate.split("/"):
            if piece in ("", "."):
                continue
            if piece == "..":
                if parts:
                    parts.pop()
                else:
                    return None
            else:
                parts.append(piece)
        name = "/".join(parts)
        for value in (name, name+"/README.md", name+"/index.html"):
            if value in known and value != path:
                return value
    return None


def dependencies(path: str, lines: list[str], known: set[str], modules: dict) -> tuple[list[dict], list[str]]:
    found: dict[str, dict] = {}
    external: set[str] = set()
    lang = language(path)
    def add(target: str, kind: str, line: int, confidence: str):
        if target != path and target in known:
            rank = {"import": 4, "documentation link": 3, "mentions path": 1}
            existing = found.get(target)
            if existing is None or rank[kind] > rank[existing["kind"]]:
                found[target] = {"target":target,"kind":kind,"line":line,"confidence":confidence}
    for ix, line in enumerate(lines, 1):
        if lang in ("dart", "javascript"):
            m = (IMPORT_DART if lang == "dart" else IMPORT_JS).match(line)
            if m:
                value = m.group(1)
                if value.startswith(("package:", "dart:")):
                    external.add(value.split("/")[0] if value.startswith("package:") else value)
                else:
                    target = resolve_relative(path, value, known)
                    if target:
                        add(target, "import", ix, "explicit")
        if lang == "python":
            m = re.match(r"^\s*(?:from\s+([\w.]+)\s+import|import\s+([\w.]+))", line)
            if m:
                module = next((v for v in m.groups() if v), "")
                target = modules.get(module) or modules.get(module.split(".")[-1])
                if target:
                    add(target, "import", ix, "inferred-module")
        if lang == "markdown":
            for ref in MARKDOWN_LINK.findall(line):
                target = resolve_relative(path, ref, known)
                if target:
                    add(target, "documentation link", ix, "explicit")
        if len(line) < 500:
            for ref in PATH_REF.findall(line):
                target = resolve_relative(path, ref, known)
                if target:
                    add(target, "mentions path", ix, "lexical")
    return sorted(found.values(), key=lambda e:(e["target"],e["kind"])), sorted(external)


def build_catalog(root: Path, paths: list[str], model: dict, ref: str) -> dict:
    paths = sorted(dict.fromkeys(paths))
    known = set(paths)
    modules = {PurePosixPath(p).stem:p for p in paths if p.endswith(".py")}
    for p in paths:
        if p.endswith(".py"):
            modules[p[:-3].replace("/",".")] = p
    catalog = []
    for p in paths:
        lines, omitted = file_data(root,p)
        edges, external = dependencies(p,lines,known,modules)
        symbol_list = symbols_for(p,lines,model["symbolNotes"])
        catalog.append({
            "path":p,"category":category(p),"language":language(p),
            "largeOrBinary":omitted,"symbols":symbol_list,"deps":edges,
            "externals":external,"description":purpose(p,model)
        })
    back: dict[str,set[str]] = {p:set() for p in paths}
    for f in catalog:
        for dep in f["deps"]:
            back[dep["target"]].add(f["path"])
    for f in catalog:
        f["usedBy"] = sorted(back[f["path"]])
    errors = []
    for node in model["systems"]:
        if node.get("stage") != "planned":
            for owned in node.get("files", []):
                if owned not in known:
                    errors.append(f"Model {node['id']} references absent file {owned}")
    if errors:
        raise ValueError("\n".join(errors))
    documents = []
    for p in paths:
        if p.endswith(".md"):
            try:
                body = (root/p).read_text(encoding="utf-8")
                if len(body) <= 120_000:
                    title = next((line.lstrip("# ").strip() for line in body.splitlines()
                                  if line.startswith("# ")), PurePosixPath(p).name)
                    documents.append({"path":p,"title":title,"markdown":body})
            except (OSError, UnicodeError):
                continue
    return {
        "schema":1, "repository":REPO_URL,"ref":ref,
        "model":model, "documents":documents,
        "stats":{
            "files":len(catalog),
            "documents":len(documents),
            "symbols":sum(len(f["symbols"]) for f in catalog),
            "links":sum(len(f["deps"]) for f in catalog),
            "archived":sum(f["path"].startswith("versions/") for f in catalog),
            "largeOmitted":sum(f["largeOrBinary"] for f in catalog)
        },
        "files":catalog
    }


def produce_data_js(catalog: dict) -> str:
    raw = json.dumps(catalog, ensure_ascii=False, separators=(",",":"),sort_keys=True)
    safe = raw.replace("<","\\u003c").replace(">","\\u003e").replace("&","\\u0026")
    return "/* Generated from tracked repository sources. Do not edit. */\nwindow.FS_ATLAS_DATA = " + safe + ";\n"


def write(root: Path, output: Path, catalog: dict) -> None:
    output.mkdir(parents=True,exist_ok=True)
    source = root / "docs/architecture/explorer"
    for name in ("index.html","site.css","site.js"):
        shutil.copyfile(source/name,output/name)
    (output/"data.js").write_text(produce_data_js(catalog),encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Generate an offline browser-ready site (default)")
    parser.add_argument("--check", action="store_true", help="Validate model references and source index without writing")
    parser.add_argument("--output", type=Path, default=OUTPUT)
    args=parser.parse_args()
    try:
        model=json.loads((ROOT/MODEL).read_text(encoding="utf-8"))
        paths=tracked(ROOT)
        head=subprocess.run(["git","rev-parse","HEAD"],cwd=ROOT,check=True,capture_output=True,text=True).stdout.strip()
        catalog=build_catalog(ROOT,paths,model,head)
        if not args.check:
            write(ROOT,args.output,catalog)
    except (OSError,ValueError,subprocess.CalledProcessError) as exc:
        print(f"Architecture Explorer ERROR: {exc}")
        return 1
    stats=catalog["stats"]
    print(f"Architecture index: {stats['files']} files, {stats['symbols']} symbols, {stats['links']} traceable links; {stats['archived']} archived snapshots.")
    if not args.check:
        print(f"Open: {(args.output/'index.html').resolve()}")
    return 0


if __name__=="__main__":
    raise SystemExit(main())
