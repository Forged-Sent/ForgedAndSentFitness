#!/usr/bin/env python3
"""Copy project skills (fs-*) from .agents/skills (canonical, read by Codex) to .claude/skills (read by Claude Code).
Copy, not symlink: developers use Windows, where git symlinks need Developer Mode."""
import pathlib, shutil
R = pathlib.Path(__file__).resolve().parent.parent
src, dst = R / ".agents/skills", R / ".claude/skills"
dst.mkdir(parents=True, exist_ok=True)
for d in sorted(src.glob("fs-*")):
    t = dst / d.name
    if t.exists(): shutil.rmtree(t)
    shutil.copytree(d, t); print("synced", d.name)
