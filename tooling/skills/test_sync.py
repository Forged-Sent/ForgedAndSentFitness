"""Tests for shared Codex and Claude skills."""
import tempfile
import unittest
from pathlib import Path

from sync import validate


class SkillSyncTests(unittest.TestCase):
    def test_mirrors_match(self):
        root = Path(__file__).resolve().parents[2]
        self.assertEqual(validate(root), [])

    def test_drift_is_detected_and_repaired(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name in ("flutter-vertical-slice", "flutter-architecture-review",
                         "firebase-security-review", "independent-code-review"):
                source = root / ".agents/skills" / name / "SKILL.md"
                source.parent.mkdir(parents=True)
                source.write_text(f"---\nname: {name}\ndescription: A shared development workflow.\n---\nContent\n")
                mirror = root / ".claude/skills" / name / "SKILL.md"
                mirror.parent.mkdir(parents=True)
                mirror.write_text("outdated")
            self.assertTrue(any("Skill drift" in error for error in validate(root)))
            self.assertEqual(validate(root, fix=True), [])
            self.assertEqual(validate(root), [])


if __name__ == "__main__":
    unittest.main()
