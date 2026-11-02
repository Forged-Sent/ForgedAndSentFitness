"""Regression tests for opt-in knowledge checks."""
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from check import validate


VALID_SHA = "1" * 40


class KnowledgeValidationTest(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.notes = self.root / "docs" / "knowledge"
        (self.notes / "handoffs").mkdir(parents=True)
        (self.notes / "INDEX.md").write_text("# Index\n[Handoff](handoffs/task.md)\n", encoding="utf-8")
        (self.notes / "handoffs" / "task.md").write_text(
            "---\nstatus: active\nupdated: 2026-11-02\nowner: qa\n"
            f"source_ref: feature/test\nsource_sha: {VALID_SHA}\n---\n# Task\n",
            encoding="utf-8",
        )

    def test_valid(self):
        self.assertEqual(validate(self.root), [])

    def test_broken_link(self):
        (self.notes / "INDEX.md").write_text("[Missing](missing.md)", encoding="utf-8")
        self.assertTrue(any("broken relative link" in error for error in validate(self.root)))

    def test_invalid_handoff(self):
        (self.notes / "handoffs" / "task.md").write_text("# Missing metadata", encoding="utf-8")
        self.assertTrue(any("missing metadata" in error for error in validate(self.root)))

    def test_gemini_mcp_disallows_privileged_server(self):
        import json
        gemini = self.root / ".gemini"
        gemini.mkdir()
        (gemini / "settings.json").write_text(json.dumps({"mcpServers": {
            "dart": {"command": "node", "args": ["tooling/mcp/launch.mjs", "dart"]},
            "context7": {"httpUrl": "https://mcp.context7.com/mcp", "trust": False},
            "firebase": {"command": "firebase"}
        }}), encoding="utf-8")
        self.assertTrue(any("allowlist" in error for error in validate(self.root)))

    def test_archive_not_in_current_index(self):
        archive = self.notes / "archive"
        archive.mkdir()
        (archive / "old.md").write_text(
            "---\nstatus: archived\nsuperseded_by: ../INDEX.md\n---\n", encoding="utf-8"
        )
        (self.notes / "INDEX.md").write_text("[Archived](archive/old.md)", encoding="utf-8")
        self.assertTrue(any("must not link directly" in error for error in validate(self.root)))


if __name__ == "__main__":
    unittest.main()
