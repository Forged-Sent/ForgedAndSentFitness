"""Conservative functional Flutter classification and declared-author routing.

This is policy logic, not proof of review or author identity. The trusted gate
must obtain changed paths and labels from GitHub, never from a PR-supplied report.
"""
from __future__ import annotations

FUNCTIONAL_PREFIXES = ("mobile/", "firebase/", "tooling/firebase/")
GATE_PREFIXES = ("tooling/review/", ".github/rulesets/")
FUNCTIONAL_ROOTS = {
    "firebase.json", "firestore.rules", "firestore.indexes.json", "storage.rules",
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
    return path.startswith(FUNCTIONAL_PREFIXES) and not path.lower().endswith((".md", ".rst"))


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
    selected = set(labels) & AUTHOR_LABELS.keys()
    if len(selected) != 1:
        raise ValueError("Set exactly one authorship:codex/claude/human/mixed label")
    return AUTHOR_LABELS[selected.pop()]
