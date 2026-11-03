#!/usr/bin/env python3
"""Validate the Markdown knowledge index and metadata without external dependencies."""
from __future__ import annotations

import json
import re
import subprocess
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
    pages = set(notes.rglob("*.md")) | set((root / "docs" / "features").rglob("*.md"))
    if (root / "docs" / "HOME.md").is_file():
        pages.add(root / "docs" / "HOME.md")
    for file in sorted(pages):
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
    validate_feature_contracts(root, errors)
    return errors


FEATURE_STATES = {"proposed", "approved", "implemented", "superseded"}
FEATURE_RISKS = {"low", "medium", "high", "security-critical"}
FEATURE_REQUIRED = {"kind", "feature_id", "status", "risk", "owner", "source_sha"}
FEATURE_ID = re.compile(r"^FNS-[0-9]{3,}$")


def _paths(value: str) -> list[str]:
    return [part.strip() for part in value.split(",") if part.strip() and part.strip() != "none"]


def _repo_file(root: Path, value: str) -> Path | None:
    """Reject absolute and escaping paths before checking existence."""
    candidate = Path(value)
    if candidate.is_absolute():
        return None
    target = (root / candidate).resolve()
    return target if target.is_relative_to(root.resolve()) and target.is_file() else None


def validate_feature_contracts(root: Path, errors: list[str]) -> None:
    """Validate declared intent and evidence paths, not approval or test success."""
    folder = root / "docs" / "features"
    if not folder.is_dir():
        return
    active: dict[str, str] = {}
    for feature_dir in sorted(p for p in folder.iterdir() if p.is_dir()):
        candidates = [feature_dir / "feature.md", feature_dir / "requirements.md"]
        found = [p for p in candidates if p.is_file()]
        if len(found) != 1:
            errors.append(f"{feature_dir.relative_to(root)}: expected exactly one canonical feature.md or requirements.md")
            continue
        file = found[0]
        name = file.relative_to(root).as_posix()
        values = metadata(file.read_text(encoding="utf-8"))
        missing = FEATURE_REQUIRED - values.keys()
        if missing:
            errors.append(f"{name}: missing feature metadata {sorted(missing)}")
            continue
        if values["kind"] != "feature-spec":
            errors.append(f"{name}: kind must be feature-spec")
        if not FEATURE_ID.fullmatch(values["feature_id"]):
            errors.append(f"{name}: feature_id must look like FNS-042")
        if values["status"] not in FEATURE_STATES:
            errors.append(f"{name}: invalid feature status")
        if values["risk"] not in FEATURE_RISKS:
            errors.append(f"{name}: invalid feature risk")
        if not values["owner"]:
            errors.append(f"{name}: owner cannot be empty")
        sha = values["source_sha"]
        if not SHA.fullmatch(sha):
            errors.append(f"{name}: source_sha must be a full 40-character lowercase commit SHA")
        elif (root / ".git").exists():
            result = subprocess.run(["git", "cat-file", "-e", f"{sha}^{{commit}}"],
                                    cwd=root, capture_output=True, check=False)
            if result.returncode:
                errors.append(f"{name}: source_sha is not an available Git commit")
        if values["status"] != "superseded":
            other = active.get(values["feature_id"])
            if other:
                errors.append(f"{name}: duplicate active feature_id also in {other}")
            active[values["feature_id"]] = name
        if values["status"] in ("approved", "implemented"):
            if values.get("approved_by", "none") in ("", "none"):
                errors.append(f"{name}: approved behavior requires an explicit maintainer approved_by")
        if values["risk"] in ("high", "security-critical") and values["status"] in ("approved", "implemented"):
            if file.name != "requirements.md" or not all((feature_dir / n).is_file()
                                                         for n in ("design.md", "tasks.md")):
                errors.append(f"{name}: approved high-risk feature needs requirements.md, design.md and tasks.md")
            if values.get("test_plan", "none") in ("", "none"):
                errors.append(f"{name}: approved high-risk feature needs a test_plan")
        if values["status"] == "implemented":
            if values.get("verification", "none") in ("", "none"):
                errors.append(f"{name}: implemented feature needs verification evidence")
            for key in ("verified_tests", "implementation_paths"):
                paths = _paths(values.get(key, "none"))
                if not paths:
                    errors.append(f"{name}: implemented feature needs {key}")
                for path in paths:
                    if _repo_file(root, path) is None:
                        errors.append(f"{name}: missing or escaping {key} path {path}")
        if values["status"] == "superseded":
            successor = values.get("superseded_by", "")
            target = _repo_file(root, successor) if successor else None
            if target is None or not target.is_relative_to(folder):
                errors.append(f"{name}: superseded feature needs a valid superseded_by path")
            elif metadata(target.read_text(encoding="utf-8")).get("supersedes") != name:
                errors.append(f"{name}: successor must reciprocally declare supersedes: {name}")


def main() -> int:
    issues = validate(ROOT)
    for issue in issues:
        print("ERROR: " + issue)
    if not issues:
        print("Knowledge links and handoff metadata valid.")
    return int(bool(issues))


if __name__ == "__main__":
    raise SystemExit(main())
