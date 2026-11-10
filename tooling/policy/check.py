#!/usr/bin/env python3
"""Fail-closed, always-run repository policy validation. Python 3.11+ stdlib only."""
import json
import re
import sys
import tomllib
from pathlib import Path

from review_scope import REVIEW_RULESET_PATTERNS

LOCAL = {"dart", "playwright", "maestro"}
REMOTE = {"github", "context7", "figma", "google-developer-knowledge"}
APPROVED = LOCAL | REMOTE
DEFAULT_SERVERS = {"dart", "playwright", "context7"}
OPTIONAL_VSCODE = {"github", "figma", "maestro", "google-developer-knowledge"}
OPTIONAL_CLI = {"github", "figma", "maestro"}
REMOTE_URLS = {
    "github": "https://api.githubcopilot.com/mcp/readonly",
    "context7": "https://mcp.context7.com/mcp",
    "figma": "https://mcp.figma.com/mcp",
    "google-developer-knowledge": "https://developerknowledge.googleapis.com/mcp",
}

def evaluate(root: Path) -> list[str]:
    errors: list[str] = []

    def fail(label: str, why: str) -> None:
        errors.append(f"{label}: {why}")

    def get_json(path: str):
        try:
            return json.loads((root / path).read_text(encoding="utf-8"))
        except (OSError, ValueError) as e:
            fail(path, f"cannot parse JSON ({type(e).__name__})")
            return None

    v = get_json(".vscode/mcp.json")
    c = get_json(".mcp.json")
    v_optional = get_json(".vscode/mcp-optional.example.json")
    c_optional = get_json(".mcp.optional.example.json")
    versions = get_json("tooling/versions.json")
    try:
        codex = tomllib.loads((root / ".codex/config.toml").read_text(encoding="utf-8"))
    except (OSError, ValueError) as e:
        fail(".codex/config.toml", f"cannot parse TOML ({type(e).__name__})")
        codex = None

    try:
        codex_optional = tomllib.loads((root / ".codex/config.optional.example.toml").read_text(encoding="utf-8"))
    except (OSError, ValueError) as e:
        fail(".codex/config.optional.example.toml", f"cannot parse TOML ({type(e).__name__})")
        codex_optional = None
    configs = (
        (".vscode/mcp.json", v.get("servers") if isinstance(v, dict) else None, DEFAULT_SERVERS),
        (".mcp.json", c.get("mcpServers") if isinstance(c, dict) else None, DEFAULT_SERVERS),
        (".codex/config.toml", codex.get("mcp_servers") if isinstance(codex, dict) else None, DEFAULT_SERVERS),
        (".vscode/mcp-optional.example.json", v_optional.get("servers") if isinstance(v_optional, dict) else None, OPTIONAL_VSCODE),
        (".mcp.optional.example.json", c_optional.get("mcpServers") if isinstance(c_optional, dict) else None, OPTIONAL_CLI),
        (".codex/config.optional.example.toml", codex_optional.get("mcp_servers") if isinstance(codex_optional, dict) else None, OPTIONAL_CLI),
    )
    for filename, servers, expected in configs:
        if not isinstance(servers, dict):
            fail(filename, "MCP server map is missing")
            continue
        if set(servers) != expected:
            fail(filename, f"MCP names differ from approved set: missing={sorted(expected-set(servers))}, extra={sorted(set(servers)-expected)}")
        for name, server in servers.items():
            if not isinstance(server, dict):
                fail(filename, f"{name} must be an object")
                continue
            serialized = json.dumps(server).lower()
            if re.search(r"firebase(?:-tools)?", serialized):
                fail(filename, f"{name} references forbidden Firebase cloud MCP")
            if name in LOCAL:
                # MCP names are not security boundaries; disallow extra executable
                # fields even if a trusted name and launcher are still present.
                expected_keys = {"command", "args"}
                if filename.startswith(".vscode/"):
                    expected_keys.add("type")
                    if server.get("type") != "stdio":
                        fail(filename, f"{name} local MCP must use stdio")
                elif filename.startswith(".codex/"):
                    expected_keys.add("startup_timeout_sec")
                if set(server) != expected_keys:
                    fail(filename, f"{name} local MCP has unapproved fields")
                if server.get("command") != "node":
                    fail(filename, f"{name} must use the approved Node launcher")
                args = server.get("args", [])
                if (not isinstance(args, list) or len(args) != 2
                        or not isinstance(args[0], str)
                        or not (args[0].endswith("/tooling/mcp/launch.mjs")
                                or args[0] == "tooling/mcp/launch.mjs")
                        or args[1] != name):
                    fail(filename, f"{name} must invoke tooling/mcp/launch.mjs using its exact allowlisted tool name")
            elif name in REMOTE:
                expected_keys = {"url"} if filename.startswith(".codex/") else {"type", "url"}
                if name == "google-developer-knowledge":
                    expected_keys.add("headers")
                if set(server) != expected_keys:
                    fail(filename, f"{name} remote MCP has unapproved fields")
                if not filename.startswith(".codex/") and server.get("type") != "http":
                    fail(filename, f"{name} remote MCP must use HTTP")
                if server.get("url") != REMOTE_URLS[name]:
                    fail(filename, f"{name} must use approved URL")

    # Gemini CLI loads project MCP servers from .gemini/settings.json and starts
    # stdio servers at launch, so it gets the same allowlist as the configs above.
    # It may declare a subset; every entry must be an approved, untrusted server.
    gemini_path = root / ".gemini/settings.json"
    if gemini_path.exists():
        g = get_json(".gemini/settings.json")
        if isinstance(g, dict):
            if set(g) - {"mcpServers"}:
                fail(".gemini/settings.json", f"unreviewed Gemini settings keys: {sorted(set(g) - {'mcpServers'})}")
            gservers = g.get("mcpServers", {})
            if not isinstance(gservers, dict):
                fail(".gemini/settings.json", "mcpServers must be an object")
                gservers = {}
            extra = set(gservers) - (APPROVED - {"google-developer-knowledge"})
            if extra:
                fail(".gemini/settings.json", f"MCP names outside approved set: {sorted(extra)}")
            for name, server in gservers.items():
                if not isinstance(server, dict):
                    fail(".gemini/settings.json", f"{name} must be an object")
                    continue
                if server.get("trust") is not False:
                    fail(".gemini/settings.json", f"{name} must set trust: false")
                if re.search(r"firebase(?:-tools)?", json.dumps(server).lower()):
                    fail(".gemini/settings.json", f"{name} references forbidden Firebase cloud MCP")
                if name in LOCAL:
                    if set(server) != {"command", "args", "trust"}:
                        fail(".gemini/settings.json", f"{name} local MCP has unapproved fields")
                    if server.get("command") != "node" or server.get("args") != ["tooling/mcp/launch.mjs", name]:
                        fail(".gemini/settings.json", f"{name} must invoke tooling/mcp/launch.mjs using its exact allowlisted tool name")
                elif name in REMOTE:
                    if set(server) != {"httpUrl", "trust"}:
                        fail(".gemini/settings.json", f"{name} remote MCP has unapproved fields")
                    if server.get("httpUrl") != REMOTE_URLS[name]:
                        fail(".gemini/settings.json", f"{name} must use approved URL")

    expected_key = "$" + "{input:forgedGoogleKnowledgeApiKey}"
    if isinstance(v, dict) and (v.get("inputs") or []):
        fail(".vscode/mcp.json", "Default MCP must not prompt for cloud API keys")
    if isinstance(v_optional, dict):
        inp = v_optional.get("inputs")
        if not isinstance(inp, list) or len(inp) != 1 or not isinstance(inp[0], dict) or inp[0].get("id") != "forgedGoogleKnowledgeApiKey" or inp[0].get("password") is not True:
            fail(".vscode/mcp-optional.example.json", "Google Knowledge input must use the single masked password prompt")
        google = (v_optional.get("servers") or {}).get("google-developer-knowledge", {})
        if google.get("headers", {}).get("X-Goog-Api-Key") != expected_key:
            fail(".vscode/mcp-optional.example.json", "Google API key must be the runtime input placeholder, never a literal")

    for settings in (root / ".claude").glob("settings*.json"):
        obj = get_json(str(settings.relative_to(root)))
        if isinstance(obj, dict) and ("mcpServers" in obj or "servers" in obj):
            fail(str(settings.relative_to(root)), "MCP declarations belong in audited config files")
        if isinstance(obj, dict) and "hooks" in obj:
            fail(str(settings.relative_to(root)), "Claude project hooks are forbidden until separately reviewed")
        if isinstance(obj, dict) and isinstance(obj.get("permissions"), dict) and obj["permissions"].get("allow"):
            fail(str(settings.relative_to(root)), "Claude project permissions.allow is forbidden until separately reviewed")
        if obj is not None and re.search(r"firebase(?:-tools)?\W+(?:mcp|server)", json.dumps(obj), flags=re.I):
            fail(str(settings.relative_to(root)), "Firebase cloud MCP config forbidden")

    # GitHub Copilot reviewer tools default to full access when omitted.
    reviewers = (
        ".github/agents/architecture-reviewer.agent.md",
        ".github/agents/firebase-security.agent.md",
    )
    for rel in reviewers:
        try:
            body = (root / rel).read_text(encoding="utf-8")
        except OSError:
            fail(rel, "review agent missing")
            continue
        header = body.split("---", 2)[1] if body.startswith("---") and body.count("---") >= 2 else ""
        if not re.search(r"(?m)^tools:\s*\[['\"]read['\"],\s*['\"]search['\"]\]\s*$", header):
            fail(rel, "reviewer must explicitly allow only tools: ['read', 'search']")
    for rel in (".claude/agents/architecture-reviewer.md", ".claude/agents/firebase-security.md"):
        try:
            body = (root / rel).read_text(encoding="utf-8")
            header = body.split("---", 2)[1]
            tools = next((s.split(":", 1)[1].strip() for s in header.splitlines() if s.startswith("tools:")), "")
            if not tools or set(x.strip() for x in tools.split(",")) - {"Read", "Glob", "Grep"}:
                fail(rel, "reviewer must have read-only tool list")
        except (OSError, IndexError):
            fail(rel, "reviewer YAML frontmatter missing")

    try:
        owners = (root / ".github/CODEOWNERS").read_text(encoding="utf-8")
        entries = [line.split() for line in owners.splitlines()
                   if line.strip() and not line.lstrip().startswith("#")]
        mapped = {entry[0]: entry[1:] for entry in entries if len(entry) > 1}
        expected_owners = ["@Chadillac12"]
        required_paths = (
            "/mobile/", "/tooling/", "/.github/", "/.codex/", "/.claude/",
            "/.agents/", "/.gemini/", "/.vscode/", "/docs/architecture/", "/docs/knowledge/", "/firebase/",
            "/.mcp.json", "/.mcp.optional.example.json", "/.gitignore", "/.gitattributes", "/AGENTS.md",
            "/CLAUDE.md", "/GEMINI.md", "/*.cmd", "/*.command", "/launchers/", "*.rules",
            "/seed/db-rules.json", "/seed/weekly-challenges.json",
            "/seed/movement-standards.json", "/seed/tasks.json",
            "/dev/*.py", "/dev/patches/", "/dev/firebase/",
            "/docs/development/", "/functions/", "/firebase.json",
            "/.firebaserc", "/firestore.indexes.json",
        )
        if "*" in mapped or "/*" in mapped:
            fail(".github/CODEOWNERS", "prototype must not have a repository-wide mandatory owner")
        for pattern in required_paths:
            if mapped.get(pattern) != expected_owners:
                fail(".github/CODEOWNERS", f"protected path is unowned: {pattern}")
    except OSError:
        fail(".github/CODEOWNERS", "file missing")

    # The review publisher receives model-derived text but needs only a PR
    # comment write and a commit-status write. Pin the exact hosted token scope.
    workflow = ".github/workflows/flutter-ai-review.yml"
    try:
        lines = (root / workflow).read_text(encoding="utf-8").splitlines()
        start = lines.index("  publish:")
        permission_start = lines.index("    permissions:", start + 1)
        if any(re.fullmatch(r"  [a-zA-Z0-9_-]+:", line) for line in lines[start + 1:permission_start]):
            raise ValueError("publisher permissions block missing")
        permissions: dict[str, str] = {}
        for line in lines[permission_start + 1:]:
            if line.strip() and not line.startswith("      "):
                break
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            match = re.fullmatch(r"      ([a-z-]+): (read|write|none)", line)
            if not match or match.group(1) in permissions:
                raise ValueError("publisher permissions block malformed")
            permissions[match.group(1)] = match.group(2)
        if permissions != {"contents": "read", "pull-requests": "write", "statuses": "write"}:
            fail(workflow, f"publisher permissions differ from the minimal approved set: {permissions}")
    except (OSError, ValueError):
        fail(workflow, "publisher permissions must declare the exact approved set")

    # The ruleset is defined on GitHub; verify the documented patterns use
    # the default-protected model so an administrator can copy them faithfully.
    # Checking docs is not checking the live ruleset: validate it after setup.
    try:
        doc = (root / "docs/development/REPOSITORY-SECURITY.md").read_text(encoding="utf-8")
        block = re.search(
            r"<!-- BEGIN REQUIRED_REVIEW_RULESET_PATTERNS -->\s*`{3}gitignore\s*"
            r"(.*?)\s*`{3}\s*<!-- END REQUIRED_REVIEW_RULESET_PATTERNS -->",
            doc, re.S)
        actual = tuple(line.strip() for line in block.group(1).splitlines()) if block else ()
        if actual != REVIEW_RULESET_PATTERNS:
            fail("docs/development/REPOSITORY-SECURITY.md",
                 "Required reviewers patterns must match the default-protected source of truth")
    except OSError:
        fail("docs/development/REPOSITORY-SECURITY.md", "required reviewer ruleset guide missing")

    # Launchers must pass compile-time defines the app actually reads; a
    # misspelled key silently drops the app into preview mode.
    app_keys: set[str] = set()
    for dart in (root / "mobile/lib").rglob("*.dart"):
        try:
            app_keys |= set(re.findall(r"fromEnvironment\(\s*'([A-Z][A-Z0-9_]*)'",
                                       dart.read_text(encoding="utf-8")))
        except OSError:
            continue
    launch_globs = ("tooling/**/*.ps1", "tooling/**/*.sh", "tooling/**/*.mjs",
                    "*.cmd", "*.command", "launchers/**/*.cmd", "launchers/**/*.command",
                    ".github/workflows/*.yml",
                    "docs/**/*.md", "mobile/README.md")
    for pattern in launch_globs:
        for script in root.glob(pattern):
            try:
                text = script.read_text(encoding="utf-8")
            except (OSError, UnicodeError):
                continue
            for key in re.findall(r"--dart-define=([A-Z][A-Z0-9_]*)=", text):
                if key not in app_keys:
                    fail(str(script.relative_to(root)),
                         f"--dart-define={key} is never read by mobile/lib (known: {sorted(app_keys)})")

    # Solo-maintainer policy: no instruction may mandate a second human or a
    # second AI reviewer. Catch wording drift mechanically.
    mandates = re.compile(r"plus another human|two independent provider reviews|"
                          r"default two-reviewer|require[sd]? (?:the other person's|a second (?:human|person)'?s?) approv|"
                          r"second human (?:review|approval) (?:is )?(?:required|mandatory)", re.I)
    for pattern in ("*.md", ".github/**/*.md", ".claude/**/*.md", ".agents/**/*.md",
                    "docs/**/*.md", "mobile/*.md"):
        for doc in root.glob(pattern):
            if "/versions/" in doc.as_posix():
                continue
            try:
                hit = mandates.search(doc.read_text(encoding="utf-8"))
            except (OSError, UnicodeError):
                continue
            if hit:
                fail(str(doc.relative_to(root)), f"mandates an extra reviewer, contradicting solo-maintainer policy: '{hit.group(0)}'")

    if not (root / 'mobile/pubspec.lock').is_file():
        fail('mobile/pubspec.lock', 'reproducible app dependency lockfile must be committed')
    if not isinstance(versions, dict):
        fail("tooling/versions.json", "missing versions")
    else:
        # Verify cross-file pins rather than treating a never-read manifest as truth.
        for rel, needle in (
            (".github/workflows/ci-gate.yml", "flutter-version: '"+versions.get("flutter", "")+"'"),
            ("tooling/mcp/launch.mjs", "@playwright/mcp@"+versions.get("playwrightMcp", "")),
            ("tooling/macos/common.sh", "FS_FIREBASE_VERSION="+versions.get("firebaseCLI", "")),
            ("tooling/windows/setup-developer.ps1", "firebasePin=[string]$pins.firebaseCLI"),
            (".vscode/settings.json", '"dart.flutterSdkPath": "~/develop/flutter"'),
            ("tooling/windows/install-maestro.ps1", "cli-"+versions.get("maestroCLI", "")),
        ):
            try:
                if needle not in (root / rel).read_text(encoding="utf-8"):
                    fail(rel, f"version drift from tooling/versions.json ({needle})")
            except OSError:
                fail(rel, "required versioned file missing")
        # A single matching pin is insufficient when the same tool is pinned
        # in several jobs or install scripts. Validate EVERY occurrence.
        checks = (
            (".github/workflows/ci-gate.yml",
             r"flutter-version:\s*'([^']+)'", versions.get("flutter", "")),
            ("tooling/windows/setup.ps1",
             r"\b(3\.\d+\.\d+)\b", versions.get("flutter", "")),
            ("tooling/macos/common.sh",
             r"\b(3\.\d+\.\d+)\b", versions.get("flutter", "")),
            ("tooling/windows/install-maestro.ps1",
             r"cli-(\d+\.\d+\.\d+)", versions.get("maestroCLI", "")),
            ("tooling/windows/install-maestro.ps1",
             r"(?i)(?<![0-9a-f])[0-9a-f]{64}(?![0-9a-f])",
             versions.get("maestroZipSha256", "")),
        )
        for rel, pattern, expected in checks:
            try:
                raw = (root / rel).read_text(encoding="utf-8")
                found = re.findall(pattern, raw)
                if rel == "tooling/windows/setup.ps1":
                    # The same script also specifies the independent Dart MCP
                    # minimum, which must NOT be compared to Flutter's pin.
                    dart_floor = str(versions.get("dartMinimum", ""))
                    if dart_floor not in found:
                        fail(rel, "Dart minimum from versions.json is missing")
                    found = [pin for pin in found if pin != dart_floor]
                if not found or any(item.lower() != str(expected).lower() for item in found):
                    fail(rel, f"all pinned version/hash occurrences must match tooling/versions.json ({expected}); found {found}")
            except OSError:
                fail(rel, "required versioned file missing")
    return errors

if __name__ == "__main__":
    base = Path(__file__).resolve().parents[2]
    issues = evaluate(base)
    if issues:
        for issue in issues:
            print(f"::error::{issue}")
        print(f"Repository policy FAILED: {len(issues)} issue(s)")
        sys.exit(1)
    print("Repository policy passed, including MCP, reviewer, key and version controls.")
