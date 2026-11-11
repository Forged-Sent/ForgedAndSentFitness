#!/usr/bin/env python3
"""Validate the Markdown knowledge index and metadata without external dependencies."""
from __future__ import annotations

import json
import os
import re
import subprocess
from datetime import date
from pathlib import Path
from urllib.parse import unquote

import work_board  # sibling module: the generated work views must match WORK.md

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
    errors.extend(work_board.problems(root))
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


# source_sha is the stable BASELINE commit a spec was derived from, so it must
# already be on the canonical base branch. A PR-branch commit could vanish after
# a squash merge and branch deletion; PR provenance belongs in source_ref (and an
# optional decision_ref), and Git history already records which commit added the spec.
BASE_REF_ENV = "FNS_KNOWLEDGE_BASE"
DEFAULT_BASE_REFS = ("origin/main", "main")


def _git(root: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", *args], cwd=root, capture_output=True, text=True, check=False)


def canonical_base(root: Path) -> str | None:
    """First resolvable base ref: $FNS_KNOWLEDGE_BASE if set, else origin/main, else main."""
    override = os.environ.get(BASE_REF_ENV, "").strip()
    for ref in ((override,) if override else DEFAULT_BASE_REFS):
        if _git(root, "rev-parse", "--verify", "--quiet", f"{ref}^{{commit}}").returncode == 0:
            return ref
    return None


def _source_sha_problem(root: Path, sha: str, cache: dict[str, str | None]) -> str | None:
    try:
        if _git(root, "cat-file", "-e", f"{sha}^{{commit}}").returncode:
            return "source_sha is not an available Git commit"
        if "base" not in cache:
            cache["base"] = canonical_base(root)
        base = cache["base"]
        if base is None:
            return (f"cannot verify source_sha: no origin/main or main ref here "
                    f"(fetch main, or set {BASE_REF_ENV} to the canonical base ref)")
        if _git(root, "merge-base", "--is-ancestor", sha, base).returncode:
            return (f"source_sha must already be on {base}: use the stable baseline commit the spec "
                    f"was derived from (for example the PR's merge-base with main), not a PR-branch "
                    f"commit; record PR provenance in source_ref")
    except FileNotFoundError:
        return "git executable not found; cannot verify source_sha"
    return None


# Docs are part of done. A pull request that changes one of these areas must also
# change the page that describes it, written as it will be true once it merges.
# Only areas a machine can judge are listed; the rest is in the PR template.
DOC_RULES = (
    (("mobile/lib/", "firebase/", "functions/"), "docs/knowledge/WORK.md",
     "update your row on the work board to its after-merge state in the same pull request"),
    (("mobile/lib/src/design/",), "docs/design/DESIGN-SYSTEM.md",
     "record the tokens or components you changed on the design system page in the same pull request"),
)


def doc_rule_problems(changed: list[str]) -> list[str]:
    """Problems for a set of changed paths; pure, so it is easy to test."""
    problems = []
    for prefixes, page, action in DOC_RULES:
        touched = [path for path in changed if path.startswith(prefixes)]
        if touched and page not in changed:
            problems.append(f"{touched[0]} changed but {page} did not: {action}")
    return problems


def changed_since_base(root: Path) -> list[str] | None:
    """Paths this branch changed relative to main, or None when that cannot be known here."""
    try:
        base = canonical_base(root)
        if base is None:
            return None
        merge_base = _git(root, "merge-base", base, "HEAD")
        if merge_base.returncode:
            return None
        diff = _git(root, "diff", "--name-only", f"{merge_base.stdout.strip()}..HEAD")
    except FileNotFoundError:
        return None
    return None if diff.returncode else [line for line in diff.stdout.splitlines() if line]


def strict_feature_metadata(text: str) -> tuple[dict[str, str], list[str]]:
    """Parse the deliberately simple one-line YAML subset without ambiguity."""
    if not text.startswith("---\n"):
        return {}, ["missing opening YAML frontmatter"]
    header, separator, _ = text[4:].partition("\n---\n")
    if not separator:
        return {}, ["missing closing YAML frontmatter"]
    values: dict[str, str] = {}
    issues: list[str] = []
    for line in header.splitlines():
        if not line.strip():
            continue
        if not re.fullmatch(r"[a-z_][a-z0-9_]*: .+", line):
            issues.append("invalid one-line YAML metadata syntax")
            continue
        key, value = line.split(":", 1)
        if key in values:
            issues.append(f"duplicate metadata key {key}")
        values[key] = value.strip()
    return values, issues


def validate_feature_contracts(root: Path, errors: list[str]) -> None:
    """Validate declared intent and evidence paths, not approval or test success."""
    folder = root / "docs" / "features"
    if not folder.is_dir():
        return
    active: dict[str, str] = {}
    base_cache: dict[str, str | None] = {}
    for feature_dir in sorted(p for p in folder.iterdir() if p.is_dir()):
        candidates = [feature_dir / "feature.md", feature_dir / "requirements.md"]
        found = [p for p in candidates if p.is_file()]
        if len(found) != 1:
            errors.append(f"{feature_dir.relative_to(root)}: expected exactly one canonical feature.md or requirements.md")
            continue
        file = found[0]
        name = file.relative_to(root).as_posix()
        values, syntax_issues = strict_feature_metadata(file.read_text(encoding="utf-8"))
        errors.extend(f"{name}: {issue}" for issue in syntax_issues)
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
            problem = _source_sha_problem(root, sha, base_cache)
            if problem:
                errors.append(f"{name}: {problem}")
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
    issues += doc_rule_problems(changed_since_base(ROOT) or [])
    for issue in issues:
        print("ERROR: " + issue)
    if not issues:
        print("Knowledge links and handoff metadata valid.")
    return int(bool(issues))


if __name__ == "__main__":
    raise SystemExit(main())
