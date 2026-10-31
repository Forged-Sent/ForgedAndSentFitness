#!/usr/bin/env python3
"""Keep checked-in Codex and Claude skills byte-for-byte synchronized."""
from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CANONICAL = ".agents/skills"
MIRROR = ".claude/skills"
REQUIRED = {
    "flutter-vertical-slice",
    "flutter-architecture-review",
    "firebase-security-review",
    "independent-code-review",
}


def validate(root: Path, fix: bool = False) -> list[str]:
    errors = []
    a, b = root / CANONICAL, root / MIRROR
    names = {p.parent.name for p in a.glob("*/SKILL.md")} | {p.parent.name for p in b.glob("*/SKILL.md")} | REQUIRED
    for name in sorted(names):
        source, dest = a / name / "SKILL.md", b / name / "SKILL.md"
        if not source.is_file():
            errors.append(f"Missing canonical skill: {source.relative_to(root)}")
            continue
        body = source.read_text(encoding="utf-8")
        if not re.match(r"(?s)^---\nname:\s*" + re.escape(name) +
                        r"\ndescription:\s*\S.+?\n---\n", body):
            errors.append(f"Invalid skill metadata: {source.relative_to(root)}")
        if fix:
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(body, encoding="utf-8")
        if not dest.is_file() or dest.read_text(encoding="utf-8") != body:
            errors.append(f"Skill drift: {dest.relative_to(root)} (run python tooling/skills/sync.py --fix)")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Validate checked-in skills (default)")
    parser.add_argument("--fix", action="store_true", help="Copy canonical Codex skills into Claude mirror")
    args = parser.parse_args()
    issues = validate(ROOT, fix=args.fix)
    if issues:
        print("\n".join("ERROR: " + issue for issue in issues))
        return 1
    print("Codex and Claude skills are synchronized.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
