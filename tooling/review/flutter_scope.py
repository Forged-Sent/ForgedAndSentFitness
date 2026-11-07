"""Conservative functional Flutter classification and declared-author routing.

This is policy logic, not proof of review or author identity. The trusted gate
must obtain changed paths and labels from GitHub, never from a PR-supplied report.
"""
from __future__ import annotations
import re

FUNCTIONAL_PREFIXES = ("mobile/", "firebase/", "tooling/firebase/")
GATE_PREFIXES = ("tooling/review/", ".github/rulesets/", ".github/workflows/", ".github/actions/")
FUNCTIONAL_ROOTS = {
    "firebase.json", ".firebaserc", "firestore.rules", "firestore.indexes.json", "storage.rules",
    ".github/workflows/flutter-ai-review.yml",
}
AUTHOR_LABELS = {
    "authorship:codex": ("claude",),
    "authorship:claude": ("codex",),
    "authorship:human": ("codex",),
    "authorship:mixed": ("codex", "claude"),
}


def needs_review(path: str) -> bool:
    """Treat Dart comment-only edits as functional rather than guessing semantics."""
    if not isinstance(path, str) or not path or "\\" in path or path.startswith("/"):
        raise ValueError("Expected a nonempty repository-relative GitHub path")
    if any(part in ("", ".", "..") for part in path.split("/")):
        raise ValueError("Invalid repository-relative path")
    if path in FUNCTIONAL_ROOTS or path.startswith(GATE_PREFIXES):
        return True
    for prefix in FUNCTIONAL_PREFIXES:
        if path.startswith(prefix):
            rest = path[len(prefix):].lower()
            # Markdown in assets or code directories may be bundled app content.
            # Flutter may bundle Markdown from mobile/docs as an app asset.
            documentation = rest in ("readme.md", "changelog.md", "readme.rst") or (
                prefix != "mobile/" and rest.startswith("docs/")
            )
            return not (documentation and rest.endswith((".md", ".rst")))
    if path in ("README.md", "README.rst", "CHANGELOG.md"):
        return False
    if path.startswith("docs/") and path.lower().endswith((".md", ".rst")):
        return False
    # Only the established behavioral prototype files have a lighter policy.
    if path == "index.html" or re.fullmatch(r"versions/app-v\d+\.html", path):
        return False
    if re.fullmatch(r"dev/[^/]+\.html", path) or path == "dev/mock-claude.js":
        return False
    if (re.fullmatch(r"seed/devotionals[^/]*\.json", path) or
            path in ("seed/lifts.json", "seed/esv-verses.json")):
        return False
    return True


def relevant_paths(files: list[dict]) -> list[str]:
    """Include old rename paths so moving functional files cannot evade review."""
    paths = set()
    for item in files:
        for key in ("filename", "previous_filename"):
            if key == "filename" and key not in item:
                raise ValueError("Changed file is missing filename")
            if key in item and needs_review(item[key]):
                paths.add(item[key])
    return sorted(paths)


def reviewers_for(labels: list[str]) -> tuple[str, ...]:
    selected = {label for label in labels if label.startswith("authorship:")}
    if len(selected) != 1 or not selected <= AUTHOR_LABELS.keys():
        raise ValueError("Set exactly one authorship:codex/claude/human/mixed label")
    return AUTHOR_LABELS[selected.pop()]
