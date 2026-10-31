#!/usr/bin/env python3
"""Fail safe CI path classification. Required policy and ci-gate always run.

Prototype changes stay inexpensive. New/unrecognized file families trigger all
build lanes rather than silently skipping validation.
"""
from __future__ import annotations

import sys
from pathlib import Path


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
        if path == "index.html" or path.startswith(("versions/", "seed/", "dev/")):
            enable("prototype")
        elif path.startswith("mobile/"):
            enable("mobile", "mac")
        elif path.startswith((".github/workflows/", "tooling/ci/", "tooling/policy/")):
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
        elif path.startswith("firebase/") or path in (".gitignore", ".gitattributes"):
            enable(*result)
        elif (path in ("AGENTS.md", "CLAUDE.md", "README.md")
              or path.startswith((".github/", ".claude/", ".agents/"))
              or (path.startswith(("docs/", "planning/")) and path.endswith(".md"))):
            # These are reviewed or documented through the always-run policy
            # lane, without expensive application builds for text-only PRs.
            pass
        else:
            enable(*result)
    return result


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: path_scope.py CHANGED_PATHS_FILE")
    changed = Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()
    for key, value in classify(changed).items():
        print(f"{key}={str(value).lower()}")
