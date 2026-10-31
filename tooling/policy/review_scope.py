"""Single source of truth for risk-based GitHub Required reviewers paths.

The GitHub ruleset uses .gitignore-style matching, evaluated top to bottom.
The catch-all intentionally comes FIRST: future paths require review unless
explicitly named as low-risk prototype content. GitHub enforces the ruleset;
this module keeps tests, CI classification and documentation aligned.
"""
from __future__ import annotations

from pathlib import PurePosixPath

# Paste into GitHub > Rulesets > Require pull request > Required reviewers.
REVIEW_RULESET_PATTERNS = (
    "**",
    "!index.html",
    "!versions/**",
    "!dev/*.html",
    "!dev/mock-claude.js",
    "!seed/devotionals*.json",
    "!seed/lifts.json",
    "!seed/esv-verses.json",
    "!README.md",
)


def is_lightweight_path(path: str) -> bool:
    """Conservative mirror of the explicit negations (not a GitHub glob engine)."""
    if not path or path.startswith("/") or "\\" in path or ".." in PurePosixPath(path).parts:
        return False
    if path in ("index.html", "dev/mock-claude.js", "seed/lifts.json",
                "seed/esv-verses.json", "README.md"):
        return True
    if path.startswith("versions/") and len(PurePosixPath(path).parts) >= 2:
        return True
    if path.startswith("dev/") and len(PurePosixPath(path).parts) == 2 and path.endswith(".html"):
        return True
    if (path.startswith("seed/devotionals") and path.endswith(".json")
            and len(PurePosixPath(path).parts) == 2):
        return True
    return False


def requires_human_review(path: str) -> bool:
    """Unknown/new paths are protected by default."""
    return not is_lightweight_path(path)
