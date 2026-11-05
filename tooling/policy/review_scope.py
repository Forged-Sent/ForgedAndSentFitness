"""Advisory risk-based path classification, not a required-review policy.

The legacy constant name is retained for CI/documentation compatibility.
GitHub's current live branch rules require ci-gate and ZERO outside approvals.
The patterns distinguish lightweight prototype changes from other code so
CI can select proportionate checks; no path imposes human approval.
"""
from __future__ import annotations

from pathlib import PurePosixPath

# Advisory reference only. Do not configure mandatory external approvers for solo work.
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
    """Legacy function name: risk-sensitive path, NOT an approval requirement."""
    return not is_lightweight_path(path)
