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


class FeatureContractTest(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.notes = self.root / "docs" / "knowledge"
        self.notes.mkdir(parents=True)
        (self.notes / "INDEX.md").write_text("# Index\n", encoding="utf-8")
        self.features = self.root / "docs" / "features"
        self.features.mkdir(parents=True)

    def spec(self, slug="first", *, status="proposed", risk="low", feature_id="FNS-042",
             extra="", name="feature.md"):
        folder = self.features / slug
        folder.mkdir(exist_ok=True)
        path = folder / name
        path.write_text(
            "---\nkind: feature-spec\n"
            f"feature_id: {feature_id}\nstatus: {status}\nrisk: {risk}\n"
            f"owner: maintainer\nsource_sha: {VALID_SHA}\n{extra}---\n# Feature\n",
            encoding="utf-8",
        )
        return path

    def test_proposed_lightweight_contract(self):
        self.spec()
        self.assertEqual(validate(self.root), [])

    def test_duplicate_active_feature_id(self):
        self.spec()
        self.spec("second")
        self.assertTrue(any("duplicate active feature_id" in e for e in validate(self.root)))

    def test_high_risk_approval_needs_design_and_test_plan(self):
        self.spec(status="approved", risk="security-critical", extra="approved_by: maintainer\n")
        errors = validate(self.root)
        self.assertTrue(any("needs requirements.md" in e for e in errors))
        self.assertTrue(any("needs a test_plan" in e for e in errors))

    def test_implemented_requires_real_test_and_code_paths(self):
        self.spec(status="implemented", extra="approved_by: maintainer\nverification: CI run\n"
                  "verified_tests: ../outside.py\nimplementation_paths: none\n")
        errors = validate(self.root)
        self.assertTrue(any("missing or escaping verified_tests" in e for e in errors))
        self.assertTrue(any("needs implementation_paths" in e for e in errors))

    def test_supersession_requires_reciprocal_successor(self):
        self.spec(status="superseded", extra="superseded_by: docs/features/second/feature.md\n")
        self.spec("second", feature_id="FNS-043")
        self.assertTrue(any("reciprocally declare" in e for e in validate(self.root)))

    def test_invalid_source_sha_and_missing_metadata(self):
        self.spec(extra="source_sha: bad\n")
        self.assertTrue(any("source_sha must be" in e for e in validate(self.root)))

    def test_home_and_feature_links_checked(self):
        self.spec()
        (self.root / "docs" / "HOME.md").write_text("[broken](missing.md)", encoding="utf-8")
        self.assertTrue(any("broken relative link" in e for e in validate(self.root)))


if __name__ == "__main__":
    unittest.main()
