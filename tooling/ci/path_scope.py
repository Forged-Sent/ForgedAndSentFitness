#!/usr/bin/env python3
"""Fail-safe CI classification. Unknown paths trigger all CI jobs.

Review enforcement is separate: every unlisted file requires approval under
GitHub Required reviewers, even if its tests are inexpensive.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "policy"))
from review_scope import is_lightweight_path


def classify(paths: list[str]) -> dict[str, bool]:
    result = {"windows": False, "mobile": False, "mac": False, "prototype": False}

    def enable(*names: str) -> None:
        for name in names:
            result[name] = True

    files = [p.strip() for p in paths if p.strip()]
    if not files:
        enable(*result)
        return result

    for path in files:
        if is_lightweight_path(path):
            if path != "README.md":
                enable("prototype")
        elif path in ("dev/make_preview.py",) or (
                path.startswith("dev/patches/") and path.endswith(".py")):
            # Executable preview code: human review required, but the
            # prototype job runs it and Python syntax checks, not Flutter.
            enable("prototype")
        elif path.startswith("seed/") and path.endswith(".json"):
            # Protected scoring/authorization seed files still get JSON
            # verification; novel non-JSON content is unknown/full matrix.
            enable("prototype")
        elif path.startswith("dev/firebase/"):
            enable(*result)
        elif path.startswith("mobile/"):
            enable("mobile", "mac")
        elif path.startswith((".github/workflows/", ".github/actions/",
                             "tooling/ci/", "tooling/policy/")):
            enable(*result)
        elif path.startswith("tooling/windows/") or ("/" not in path and path.endswith(".cmd")):
            enable("windows")
        elif path.startswith("tooling/macos/") or ("/" not in path and path.endswith(".command")):
            enable("mac")
        elif path.startswith("tooling/mcp/"):
            enable("windows", "mac")
        elif path == "tooling/versions.json":
            enable("windows", "mobile", "mac")
        elif path.startswith("tooling/"):
            enable(*result)
        elif path.startswith((".vscode/", ".codex/")) or path == ".mcp.json":
            enable("windows", "mac")
        elif (path.startswith(("firebase/", "functions/"))
              or path in ("firebase.json", ".firebaserc", "firestore.indexes.json",
                          ".gitignore", ".gitattributes")):
            enable(*result)
        elif path.startswith(".claude/settings") and path.endswith(".json"):
            enable(*result)
        elif (path in ("AGENTS.md", "CLAUDE.md")
              or path.startswith((".github/", ".claude/", ".agents/"))
              or (path.startswith(("docs/", "planning/")) and path.endswith(".md"))):
            # Changes to known instructions and documentation get the always-on
            # policy job and human review, not expensive Flutter compilation.
            pass
        else:
            # Per-file evaluation matters: any unknown file in a mixed PR
            # must broaden CI regardless of previously recognized paths.
            enable(*result)
    return result


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: path_scope.py CHANGED_PATHS_FILE")
    changed = Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()
    for key, value in classify(changed).items():
        print(f"{key}={str(value).lower()}")
