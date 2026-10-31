#!/usr/bin/env python3
"""Fail-closed, always-run repository policy validation. Python 3.11+ stdlib only."""
import json
import re
import sys
import tomllib
from pathlib import Path

LOCAL = {"dart", "playwright", "maestro"}
REMOTE = {"github", "context7", "figma", "google-developer-knowledge"}
APPROVED = LOCAL | REMOTE
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
    versions = get_json("tooling/versions.json")
    try:
        codex = tomllib.loads((root / ".codex/config.toml").read_text(encoding="utf-8"))
    except (OSError, ValueError) as e:
        fail(".codex/config.toml", f"cannot parse TOML ({type(e).__name__})")
        codex = None

    configs = (
        (".vscode/mcp.json", v.get("servers") if isinstance(v, dict) else None),
        (".mcp.json", c.get("mcpServers") if isinstance(c, dict) else None),
        (".codex/config.toml", codex.get("mcp_servers") if isinstance(codex, dict) else None),
    )
    for filename, servers in configs:
        if not isinstance(servers, dict):
            fail(filename, "MCP server map is missing")
            continue
        expected = APPROVED if filename.endswith(".vscode/mcp.json") else (APPROVED - {"google-developer-knowledge"})
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
                if filename == ".vscode/mcp.json":
                    expected_keys.add("type")
                    if server.get("type") != "stdio":
                        fail(filename, f"{name} local MCP must use stdio")
                elif filename == ".codex/config.toml":
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
                expected_keys = {"url"} if filename == ".codex/config.toml" else {"type", "url"}
                if name == "google-developer-knowledge":
                    expected_keys.add("headers")
                if set(server) != expected_keys:
                    fail(filename, f"{name} remote MCP has unapproved fields")
                if filename != ".codex/config.toml" and server.get("type") != "http":
                    fail(filename, f"{name} remote MCP must use HTTP")
                if server.get("url") != REMOTE_URLS[name]:
                    fail(filename, f"{name} must use approved URL")

    expected_key = "$" + "{input:forgedGoogleKnowledgeApiKey}"
    if isinstance(v, dict):
        inp = v.get("inputs")
        if not isinstance(inp, list) or len(inp) != 1 or not isinstance(inp[0], dict) or inp[0].get("id") != "forgedGoogleKnowledgeApiKey" or inp[0].get("password") is not True:
            fail(".vscode/mcp.json", "Google Knowledge input must use the single masked password prompt")
        google = (v.get("servers") or {}).get("google-developer-knowledge", {})
        if google.get("headers", {}).get("X-Goog-Api-Key") != expected_key:
            fail(".vscode/mcp.json", "Google API key must be the runtime input placeholder, never a literal")

    for settings in (root / ".claude").glob("settings*.json"):
        obj = get_json(str(settings.relative_to(root)))
        if isinstance(obj, dict) and ("mcpServers" in obj or "servers" in obj):
            fail(str(settings.relative_to(root)), "MCP declarations belong in audited config files")
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
        expected_owners = ["@Chadillac12", "@sfcsmithc-afk"]
        required_paths = (
            "/mobile/", "/tooling/", "/.github/", "/.codex/", "/.claude/",
            "/.agents/", "/.vscode/", "/docs/architecture/", "/firebase/",
            "/.mcp.json", "/.gitignore", "/.gitattributes", "/AGENTS.md",
            "/CLAUDE.md", "/*.cmd", "/*.command", "*.rules",
            "/seed/db-rules.json", "/seed/weekly-challenges.json",
            "/seed/movement-standards.json", "/seed/tasks.json",
        )
        if "*" in mapped or "/*" in mapped:
            fail(".github/CODEOWNERS", "prototype must not have a repository-wide mandatory owner")
        for pattern in required_paths:
            if mapped.get(pattern) != expected_owners:
                fail(".github/CODEOWNERS", f"protected path is unowned: {pattern}")
    except OSError:
        fail(".github/CODEOWNERS", "file missing")

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
