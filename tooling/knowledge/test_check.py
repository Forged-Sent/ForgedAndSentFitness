"""Regression tests for opt-in knowledge checks."""
import os
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest import mock

from check import BASE_REF_ENV, BOARD, board_branch_problems, current_branch, doc_rule_problems, validate


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


class DocRuleTest(unittest.TestCase):
    def test_app_code_without_board_update_fails(self):
        problems = doc_rule_problems(["mobile/lib/src/features/today/today_screen.dart"])
        self.assertEqual(len(problems), 1)
        self.assertIn("docs/knowledge/WORK.md", problems[0])

    def test_app_code_with_board_update_passes(self):
        self.assertEqual(doc_rule_problems(
            ["mobile/lib/src/features/today/today_screen.dart", "docs/knowledge/WORK.md"]), [])

    def test_rules_change_needs_board_update(self):
        self.assertTrue(doc_rule_problems(["firebase/firestore.rules"]))

    def test_design_change_needs_design_page_and_board(self):
        problems = doc_rule_problems(["mobile/lib/src/design/tokens.dart", "docs/knowledge/WORK.md"])
        self.assertEqual(len(problems), 1)
        self.assertIn("docs/design/DESIGN-SYSTEM.md", problems[0])

    def test_docs_tooling_and_dependency_changes_are_exempt(self):
        self.assertEqual(doc_rule_problems(
            ["docs/HOME.md", "tooling/knowledge/check.py", "mobile/pubspec.lock", "mobile/test/widget_test.dart"]), [])


class BoardBranchTest(unittest.TestCase):
    ROWS = ("| Native hosts | Builds | **In progress** | local branch `codex/native-host`, no PR yet | Run P03 |\n"
            "| S0 Design | Opens | **Next** | \u2014 | Run P04 |\n")

    def test_branch_named_on_the_board_must_change_the_board(self):
        problems = board_branch_problems(["docs/HOME.md", "tooling/x.py"], "codex/native-host", self.ROWS)
        self.assertEqual(len(problems), 1)
        self.assertIn("codex/native-host is named on the work board", problems[0])
        self.assertIn(BOARD, problems[0])

    def test_branch_named_on_the_board_passes_once_the_board_changes(self):
        self.assertEqual(board_branch_problems(["tooling/x.py", BOARD], "codex/native-host", self.ROWS), [])

    def test_branch_the_board_does_not_name_is_left_to_the_path_rules(self):
        self.assertEqual(board_branch_problems(["tooling/x.py"], "fix/typo", self.ROWS), [])
        # A longer or shorter name is a different branch.
        self.assertEqual(board_branch_problems(["tooling/x.py"], "codex/native", self.ROWS), [])
        self.assertEqual(board_branch_problems(["tooling/x.py"], "codex/native-host-2", self.ROWS), [])

    def test_main_no_branch_and_no_changes_are_never_flagged(self):
        board = self.ROWS + "| Old | Done | **Done** | branch `main` | \u2014 |\n"
        self.assertEqual(board_branch_problems(["tooling/x.py"], "main", board), [])
        self.assertEqual(board_branch_problems(["tooling/x.py"], None, board), [])
        self.assertEqual(board_branch_problems([], "codex/native-host", board), [])

    def test_pull_request_head_is_read_from_the_ci_environment(self):
        with TemporaryDirectory() as tmp:
            with mock.patch.dict(os.environ, {"GITHUB_HEAD_REF": "feat/from-ci"}):
                self.assertEqual(current_branch(Path(tmp)), "feat/from-ci")
            with mock.patch.dict(os.environ, {"GITHUB_HEAD_REF": ""}):
                self.assertIsNone(current_branch(Path(tmp)))        # not a repository
            subprocess.run(["git", "init", "-q", "-b", "feat/local", tmp], check=True)
            with mock.patch.dict(os.environ, {"GITHUB_HEAD_REF": ""}):
                self.assertEqual(current_branch(Path(tmp)), "feat/local")


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

    def test_duplicate_yaml_key_is_rejected(self):
        self.spec(extra="status: approved\n")
        self.assertTrue(any("duplicate metadata key status" in e for e in validate(self.root)))

    def test_malformed_yaml_frontmatter_is_rejected(self):
        path = self.spec()
        path.write_text("not frontmatter\n", encoding="utf-8")
        self.assertTrue(any("missing opening YAML frontmatter" in e for e in validate(self.root)))

    def test_invalid_source_sha_and_missing_metadata(self):
        self.spec(extra="source_sha: bad\n")
        self.assertTrue(any("source_sha must be" in e for e in validate(self.root)))

    def test_home_and_feature_links_checked(self):
        self.spec()
        (self.root / "docs" / "HOME.md").write_text("[broken](missing.md)", encoding="utf-8")
        self.assertTrue(any("broken relative link" in e for e in validate(self.root)))


class FeatureSourceShaGitTest(unittest.TestCase):
    """Exercise the real Git path: existence AND ancestry of the canonical base."""

    def git(self, *args: str) -> str:
        return subprocess.run(
            ["git", "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
             "-c", "commit.gpgsign=false", *args],
            cwd=self.root, check=True, capture_output=True, text=True).stdout.strip()

    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        env = mock.patch.dict(os.environ, {}, clear=False)
        env.start()
        self.addCleanup(env.stop)
        os.environ.pop(BASE_REF_ENV, None)
        for var in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"):
            os.environ.pop(var, None)
        self.git("init", "-q", "-b", "main")
        (self.root / "docs" / "knowledge").mkdir(parents=True)
        (self.root / "docs" / "knowledge" / "INDEX.md").write_text("# Index\n", encoding="utf-8")
        self.git("add", "-A")
        self.git("commit", "-qm", "baseline")
        self.main_sha = self.git("rev-parse", "HEAD")
        self.git("switch", "-q", "-c", "feature/pr-branch")
        (self.root / "draft.txt").write_text("unmerged", encoding="utf-8")
        self.git("add", "-A")
        self.git("commit", "-qm", "pr-only commit")
        self.branch_sha = self.git("rev-parse", "HEAD")

    def spec(self, sha: str) -> None:
        folder = self.root / "docs" / "features" / "first"
        folder.mkdir(parents=True, exist_ok=True)
        (folder / "feature.md").write_text(
            "---\nkind: feature-spec\nfeature_id: FNS-042\nstatus: proposed\nrisk: low\n"
            f"owner: maintainer\nsource_ref: PR-30\nsource_sha: {sha}\n---\n# Feature\n",
            encoding="utf-8")

    def test_baseline_commit_on_main_is_accepted(self):
        self.spec(self.main_sha)
        self.assertEqual(validate(self.root), [])

    def test_nonexistent_commit_is_rejected(self):
        self.spec("2" * 40)
        self.assertTrue(any("not an available Git commit" in e for e in validate(self.root)))

    def test_pr_branch_commit_not_on_main_is_rejected(self):
        # Exists today, but would vanish after a squash merge and branch deletion.
        self.spec(self.branch_sha)
        errors = validate(self.root)
        self.assertTrue(any("must already be on main" in e for e in errors), errors)

    def test_explicit_base_override_is_honored(self):
        self.spec(self.branch_sha)
        with mock.patch.dict(os.environ, {BASE_REF_ENV: "feature/pr-branch"}):
            self.assertEqual(validate(self.root), [])

    def test_missing_base_ref_is_an_explicit_error(self):
        self.spec(self.main_sha)
        with mock.patch.dict(os.environ, {BASE_REF_ENV: "no-such-branch"}):
            self.assertTrue(any("cannot verify source_sha" in e for e in validate(self.root)))


if __name__ == "__main__":
    unittest.main()
