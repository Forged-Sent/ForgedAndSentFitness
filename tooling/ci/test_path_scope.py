"""CI must keep prototype fast while failing safe for mixed/unknown changes."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from path_scope import classify


class ClassificationTests(unittest.TestCase):
    def test_prototype_only_skips_expensive_build_lanes(self):
        self.assertEqual(classify(["index.html", "versions/app-v183.html", "seed/lifts.json", "dev/mock-claude.js"]),
                         {"windows": False, "mobile": False, "mac": False, "prototype": True})

    def test_prototype_docs_do_not_trigger_builds(self):
        self.assertEqual(classify(["README.md", "docs/architecture-notes.md"]),
                         {"windows": False, "mobile": False, "mac": False, "prototype": False})

    def test_flutter_changes_run_app_and_mac(self):
        v = classify(["mobile/lib/main.dart"])
        self.assertTrue(v["mobile"] and v["mac"])
        self.assertFalse(v["windows"] or v["prototype"])

    def test_mixed_pr_runs_both_prototype_and_flutter(self):
        v = classify(["index.html", "mobile/lib/main.dart"])
        self.assertTrue(v["prototype"] and v["mobile"] and v["mac"])

    def test_agent_instructions_rely_on_mandatory_policy(self):
        v = classify(["AGENTS.md", "CLAUDE.md", ".claude/rules/prototype.md", ".github/instructions/flutter.instructions.md"])
        self.assertFalse(any(v.values()))

    def test_changed_workflow_runs_every_lane(self):
        self.assertTrue(all(classify([".github/workflows/ci-gate.yml"]).values()))

    def test_unrecognized_code_fails_safe(self):
        self.assertTrue(all(classify(["backend/new-service.py"]).values()))

    def test_empty_change_list_fails_safe(self):
        self.assertTrue(all(classify([]).values()))

    def test_changing_classifier_fails_safe(self):
        self.assertTrue(all(classify(["tooling/ci/path_scope.py"]).values()))

    def test_protected_seed_rule_is_still_preview_code(self):
        self.assertTrue(classify(["seed/db-rules.json"])["prototype"])


if __name__ == "__main__":
    unittest.main()
