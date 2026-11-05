#!/usr/bin/env python3
"""Validate the Markdown knowledge index and metadata without external dependencies."""
from __future__ import annotations

import json
import re
from datetime import date
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[2]
LINK = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
SHA = re.compile(r"^[0-9a-f]{40}$")
STATES = {"active", "completed", "superseded"}
REQUIRED = {"status", "updated", "owner", "source_ref", "source_sha"}


def metadata(text: str) -> dict[str, str]:
    if not text.startswith("---\n"):
        return {}
    parts = text.split("\n---\n", 1)
    if len(parts) != 2:
        return {}
    result: dict[str, str] = {}
    for line in parts[0].splitlines()[1:]:
        if ":" in line:
            key, value = line.split(":", 1)
            result[key.strip()] = value.strip()
    return result


def validate(root: Path) -> list[str]:
    errors: list[str] = []
    notes = root / "docs" / "knowledge"
    if not (notes / "INDEX.md").is_file():
        return ["Missing docs/knowledge/INDEX.md"]
    for file in sorted(notes.rglob("*.md")):
        body = file.read_text(encoding="utf-8")
        for match in LINK.finditer(body):
            raw = match.group(1).strip().split()[0].strip("<>")
            if raw.startswith(("https://", "http://", "mailto:", "#")):
                continue
            path = unquote(raw.split("#", 1)[0].split("?", 1)[0])
            if not path:
                continue
            target = (file.parent / path).resolve()
            if not target.exists():
                errors.append(f"{file.relative_to(root)}: broken relative link {raw}")
            if file == notes / "INDEX.md" and (notes / "archive") in target.parents:
                errors.append("INDEX.md must not link directly to archived content")
    handoffs = notes / "handoffs"
    for file in sorted(handoffs.glob("*.md")):
        if file.name == "TEMPLATE.md":
            continue
        values = metadata(file.read_text(encoding="utf-8"))
        missing = REQUIRED - values.keys()
        if missing:
            errors.append(f"{file.relative_to(root)}: missing metadata {sorted(missing)}")
            continue
        if values["status"] not in STATES:
            errors.append(f"{file.relative_to(root)}: invalid status")
        try:
            date.fromisoformat(values["updated"])
        except ValueError:
            errors.append(f"{file.relative_to(root)}: invalid updated date")
        if not SHA.fullmatch(values["source_sha"]):
            errors.append(f"{file.relative_to(root)}: source_sha must be 40 hex digits")
        if not values["owner"] or not values["source_ref"]:
            errors.append(f"{file.relative_to(root)}: empty owner or source_ref")
    for file in sorted((notes / "archive").rglob("*.md")) if (notes / "archive").exists() else []:
        values = metadata(file.read_text(encoding="utf-8"))
        if values.get("status") != "archived" or not values.get("superseded_by"):
            errors.append(f"{file.relative_to(root)}: archived note needs status and superseded_by")
    gemini = root / ".gemini" / "settings.json"
    if gemini.is_file():
        try:
            settings = json.loads(gemini.read_text(encoding="utf-8"))
            servers = settings.get("mcpServers", {})
            if set(servers) != {"dart", "context7"}:
                errors.append("Gemini project MCP allowlist must contain only dart and context7")
            if any(server.get("trust", False) for server in servers.values()):
                errors.append("Gemini MCP must not auto-trust tools")
            if servers.get("context7", {}).get("httpUrl") != "https://mcp.context7.com/mcp":
                errors.append("Gemini Context7 must use reviewed HTTP endpoint")
            dart = servers.get("dart", {})
            if dart.get("command") != "node" or dart.get("args") != ["tooling/mcp/launch.mjs", "dart"]:
                errors.append("Gemini Dart MCP must use existing allowlisted launcher")
        except (json.JSONDecodeError, AttributeError, TypeError):
            errors.append("Invalid Gemini MCP settings JSON")
    return errors


def main() -> int:
    issues = validate(ROOT)
    for issue in issues:
        print("ERROR: " + issue)
    if not issues:
        print("Knowledge links and handoff metadata valid.")
    return int(bool(issues))


if __name__ == "__main__":
    raise SystemExit(main())
