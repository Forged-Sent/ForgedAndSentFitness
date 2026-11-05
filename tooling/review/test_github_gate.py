"""Adversarial validation and trusted prepare/publish tests. No paid API calls."""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import github_gate as gate

PASS = {"verdict": "PASS", "slice_complete": True, "findings": [],
        "unverified": ["Runtime tests were not executed by the reviewer"]}


def sample():
    payload = {"identity": {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                           "base_ref": "main", "draft": False, "labels": ["authorship:codex"]},
               "paths": ["mobile/lib/main.dart"], "providers": ["claude"],
               "policy_sha": "b" * 40, "run_url": "https://github.com/o/r/actions/runs/1",
               "chunks": [{"prompt": "a diff", "sha256": gate.digest("a diff")} ]}
    payload["binding"] = gate.digest(payload)
    result = {"provider": "claude", "binding": payload["binding"],
              "results": [{"sha256": payload["chunks"][0]["sha256"], "review": copy.deepcopy(PASS)}]}
    return payload, result


class FakeGitHub:
    token = "test-placeholder"
    run_url = "https://github.com/o/r/actions/runs/1"

    def __init__(self, snapshot):
        self.pr = {"number": snapshot["pr"], "head": {"sha": snapshot["head"]},
                   "base": {"sha": snapshot["base"], "ref": snapshot["base_ref"]},
                   "draft": snapshot["draft"], "labels": [{"name": x} for x in snapshot["labels"]],
                   "state": "open", "changed_files": 1, "user": {"login": "builder"}}
        self.permission = "write"
        self.owns = True
        self.posted = []
        self.changed = [{"filename": "mobile/lib/main.dart"}]
        self.open_prs = [snapshot["pr"]]
        self.permission_calls = 0
        self.last_permission_actor = None

    def api(self, path):
        if "/timeline?" in path:
            return getattr(self, "timeline", [])
        if "/reviews/" in path and "/comments" in path:
            if hasattr(self, "native_comments_by_review"):
                return self.native_comments_by_review.get(int(path.split("/reviews/")[1].split("/")[0]), [])
            return getattr(self, "native_comments", [])
        if "/reviews?" in path:
            return getattr(self, "native_reviews", [])
        if path.startswith("collaborators/"):
            self.permission_calls += 1
            self.last_permission_actor = path.split("/")[1]
            return {"permission": self.permission}
        return self.pr

    def files(self, pr):
        return self.changed

    def status(self, head, state, description):
        self.posted.append((head, state, description))

    def owns_status(self, head):
        return self.owns

    def assert_unique_open_pr(self, head, number):
        if self.open_prs != [number]:
            raise gate.GateError("Commit is shared by multiple open PRs or PR association is unavailable")


class GateTests(unittest.TestCase):
    def test_commit_status_requires_one_open_pr_for_head(self):
        api = object.__new__(gate.GitHub)
        with patch.object(api, "api", return_value=[{"number": 7, "state": "open", "head": {"sha": "a" * 40}},
                                                     {"number": 6, "state": "open", "head": {"sha": "b" * 40}}]):
            api.assert_unique_open_pr("a" * 40, 7)
        with patch.object(api, "api", return_value=[{"number": 7, "state": "open", "head": {"sha": "a" * 40}},
                                                     {"number": 8, "state": "open", "head": {"sha": "a" * 40}}]):
            with self.assertRaises(gate.GateError):
                api.assert_unique_open_pr("a" * 40, 7)
        with patch.object(api, "api", return_value=[]):
            with self.assertRaises(gate.GateError):
                api.assert_unique_open_pr("a" * 40, 7)

    def test_valid_complete_result(self):
        payload, result = sample()
        self.assertTrue(gate.validate_results(payload, [result]))

    def test_missing_duplicate_wrong_provider_and_stale_evidence_fail(self):
        payload, result = sample()
        cases = [[], [result, result]]
        for field, value in (("provider", "codex"), ("binding", "old"), ("error", "timeout"), ("results", [])):
            changed = copy.deepcopy(result)
            changed[field] = value
            cases.append([changed])
        for rows in cases:
            with self.subTest(rows=rows), self.assertRaises(gate.GateError):
                gate.validate_results(payload, rows)

    def test_requested_changes_and_incomplete_coverage_do_not_pass(self):
        payload, result = sample()
        result["results"][0]["review"]["verdict"] = "CHANGES_REQUIRED"
        self.assertFalse(gate.validate_results(payload, [result]))
        result["results"][0]["review"] = {**PASS, "slice_complete": False}
        with self.assertRaises(ValueError):
            gate.validate_results(payload, [result])

    def test_pass_cannot_contain_high_finding(self):
        payload, result = sample()
        result["results"][0]["review"]["findings"] = [{"severity": "high", "path": "mobile/lib/main.dart",
            "line": 1, "explanation": "Cross-group read", "fix": "Enforce group ownership"}]
        with self.assertRaises(ValueError):
            gate.validate_results(payload, [result])

    def test_prompt_tampering_and_wrong_slice_are_rejected(self):
        payload, result = sample()
        result["results"][0]["sha256"] = "wrong"
        with self.assertRaises(gate.GateError):
            gate.validate_results(payload, [result])
        payload["chunks"][0]["prompt"] = "different code"
        with self.assertRaises(gate.GateError):
            gate.check_payload(payload)

    def test_model_environment_excludes_github_and_other_provider_secrets(self):
        with patch.dict(os.environ, {"OPENAI_API_KEY": "openai-placeholder",
                                    "ANTHROPIC_API_KEY": "anthropic-placeholder",
                                    "GH_TOKEN": "github-placeholder", "GITHUB_TOKEN": "also-private",
                                    "FS_REVIEW_ENV_PASSTHROUGH": "GH_TOKEN", "ACTIONS_RUNTIME_TOKEN": "private"}):
            env = gate.model_env("claude", Path("isolated"))
            self.assertIn("ANTHROPIC_API_KEY", env)
            for forbidden in ("OPENAI_API_KEY", "GH_TOKEN", "GITHUB_TOKEN", "ACTIONS_RUNTIME_TOKEN", "FS_REVIEW_ENV_PASSTHROUGH"):
                self.assertNotIn(forbidden, env)
            with self.assertRaises(gate.GateError):
                gate.model_env("codex", Path("isolated"))

    def test_missing_provider_credentials_fail(self):
        with patch.dict(os.environ, {}, clear=True):
            for provider in ("codex", "claude"):
                with self.assertRaises(gate.GateError):
                    gate.model_env(provider, Path("isolated"))

    def test_native_codex_review_requires_exact_head_bot_and_no_comments(self):
        payload, _ = sample()
        api = FakeGitHub(payload["identity"])
        api.native_reviews = [{"id": 42, "commit_id": payload["identity"]["head"],
                               "user": {"id": gate.CODEX_REVIEWER_ID,
                                        "login": gate.CODEX_REVIEWER, "type": "Bot"},
                               "state": "COMMENTED", "submitted_at": "2026-11-05T10:00:00Z",
                               "body": "<!-- codex-review-receipt:v1 -->\nNo suggestions found",
                               "html_url": "https://github.com/o/r/pull/7#pullrequestreview-42"}]
        evidence = gate.codex_review(api, 7, payload["identity"]["head"])
        self.assertEqual(evidence["review_ids"], [42])
        self.assertEqual(evidence["outcome"], "clean")
        api.native_comments = [{"id": 1, "body": "fix this"}]
        evidence = gate.codex_review(api, 7, payload["identity"]["head"])
        self.assertEqual(evidence["outcome"], "changes_required")
        self.assertEqual(evidence["comment_count"], 1)
        api.native_reviews[0]["commit_id"] = "c" * 40
        with self.assertRaises(gate.NativeReviewPending):
            gate.codex_review(api, 7, payload["identity"]["head"])
        api.native_reviews[0]["commit_id"] = payload["identity"]["head"]
        api.native_reviews[0]["user"]["id"] = 123
        with self.assertRaises(gate.NativeReviewPending):
            gate.codex_review(api, 7, payload["identity"]["head"])

    def test_native_codex_result_uses_live_review_without_api_key(self):
        payload, _ = sample()
        payload["identity"]["labels"] = ["authorship:claude"]
        payload["providers"] = ["codex"]
        payload.pop("binding")
        payload["binding"] = gate.digest(payload)
        api = FakeGitHub(payload["identity"])
        api.native_reviews = [{"id": 42, "commit_id": payload["identity"]["head"],
                               "user": {"id": gate.CODEX_REVIEWER_ID,
                                        "login": gate.CODEX_REVIEWER, "type": "Bot"},
                               "state": "COMMENTED", "submitted_at": "2026-11-05T10:00:00Z",
                               "body": "<!-- codex-review-receipt:v1 -->\nNo suggestions found",
                               "html_url": "https://github.com/o/r/pull/7#pullrequestreview-42"}]
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            with patch.object(gate, "GitHub", return_value=api), patch.dict(os.environ, {}, clear=True):
                gate.run_provider(work, "codex")
            result = gate.load(work / "result-codex.json")
            self.assertEqual(result["native_review"]["review_ids"], [42])
            self.assertTrue(gate.validate_results(payload, [result], api))
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}):
                gate.publish(work, api, "success")
            self.assertEqual(api.posted[-1][1], "success")
            self.assertTrue(api.posted[-1][2].startswith("codex-evidence=" + gate.digest([42])[:16]))
            api.native_comments = [{"id": 1, "body": "fix this"}]
            with self.assertRaises(gate.GateError):
                gate.validate_results(payload, [result], api)

    def test_native_codex_review_after_base_retarget_and_prior_findings(self):
        payload, _ = sample()
        api = FakeGitHub(payload["identity"])
        first = {"id": 42, "commit_id": payload["identity"]["head"],
                 "user": {"id": gate.CODEX_REVIEWER_ID,
                          "login": gate.CODEX_REVIEWER, "type": "Bot"},
                 "state": "COMMENTED", "submitted_at": "2026-11-05T10:00:00Z",
                 "body": "<!-- codex-review-receipt:v1 -->\nSuggestions",
                 "html_url": "https://github.com/o/r/pull/7#pullrequestreview-42"}
        second = {**first, "id": 43, "submitted_at": "2026-11-05T10:10:00Z",
                  "body": "<!-- codex-review-receipt:v1 -->\nNo suggestions found"}
        api.native_reviews = [first]
        api.timeline = [{"event": "base_ref_changed", "created_at": "2026-11-05T10:05:00Z"}]
        with self.assertRaises(gate.NativeReviewPending):
            gate.codex_review(api, 7, payload["identity"]["head"])
        api.native_reviews.append(second)
        self.assertEqual(gate.codex_review(api, 7, payload["identity"]["head"])["outcome"], "clean")
        api.timeline = []
        api.native_comments_by_review = {42: [{"id": 1, "body": "fix this"}], 43: []}
        self.assertEqual(gate.codex_review(api, 7, payload["identity"]["head"])["outcome"],
                         "changes_required")
        api.native_comments_by_review = {42: [], 43: []}
        self.assertEqual(gate.codex_review(api, 7, payload["identity"]["head"])["outcome"],
                         "ambiguous")
        api.native_reviews[0]["body"] = "Unmarked review: cross-group data leak"
        api.native_comments_by_review = {42: [{"id": 2, "body": "cross-group data leak"}], 43: []}
        self.assertEqual(gate.codex_review(api, 7, payload["identity"]["head"])["outcome"],
                         "changes_required")
        api.native_comments_by_review = {42: [], 43: []}
        self.assertEqual(gate.codex_review(api, 7, payload["identity"]["head"])["outcome"],
                         "ambiguous")

    def test_clean_phrase_inside_a_finding_cannot_pass(self):
        payload, _ = sample()
        api = FakeGitHub(payload["identity"])
        api.native_reviews = [{"id": 42, "commit_id": payload["identity"]["head"],
                               "user": {"id": gate.CODEX_REVIEWER_ID,
                                        "login": gate.CODEX_REVIEWER, "type": "Bot"},
                               "state": "COMMENTED", "submitted_at": "2026-11-05T10:00:00Z",
                               "body": "<!-- codex-review-receipt:v1 -->\nNo suggestions found in Dart, but Firestore leaks groups",
                               "html_url": "https://github.com/o/r/pull/7#pullrequestreview-42"}]
        self.assertEqual(gate.codex_review(api, 7, payload["identity"]["head"])["outcome"],
                         "ambiguous")

    def test_ambiguous_codex_receipt_reports_investigation_not_findings(self):
        payload, _ = sample()
        payload["identity"]["labels"] = ["authorship:claude"]
        payload["providers"] = ["codex"]
        payload.pop("binding")
        payload["binding"] = gate.digest(payload)
        api = FakeGitHub(payload["identity"])
        api.native_reviews = [{"id": 42, "commit_id": payload["identity"]["head"],
                               "user": {"id": gate.CODEX_REVIEWER_ID,
                                        "login": gate.CODEX_REVIEWER, "type": "Bot"},
                               "state": "COMMENTED", "submitted_at": "2026-11-05T10:00:00Z",
                               "body": "<!-- codex-review-receipt:v1 -->\nReview complete",
                               "html_url": "https://github.com/o/r/pull/7#pullrequestreview-42"}]
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            gate.save(work / "result-codex.json", {"provider": "codex", "binding": payload["binding"],
                      "native_review": gate.codex_review(api, 7, payload["identity"]["head"])})
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}), self.assertRaises(gate.GateError):
                gate.publish(work, api, "success")
            self.assertIn("receipt unrecognized", gate.load(work / "summary.json")["message"])

    def test_missing_native_codex_review_leaves_pending_status(self):
        payload, _ = sample()
        payload["identity"]["labels"] = ["authorship:claude"]
        payload["providers"] = ["codex"]
        payload.pop("binding")
        payload["binding"] = gate.digest(payload)
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            api = FakeGitHub(payload["identity"])
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}):
                gate.publish(work, api, "failure")
            self.assertEqual(gate.load(work / "summary.json")["state"], "pending")
            self.assertEqual(api.posted[-1][1], "pending")

    def test_codex_review_arriving_after_job_failure_is_not_marked_processed(self):
        payload, _ = sample()
        payload["identity"]["labels"] = ["authorship:claude"]
        payload["providers"] = ["codex"]
        payload.pop("binding")
        payload["binding"] = gate.digest(payload)
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            gate.save(work / "result-codex.json", {"provider": "codex",
                      "binding": payload["binding"], "pending": "Waiting for Codex"})
            api = FakeGitHub(payload["identity"])
            api.native_reviews = [{"id": 42, "commit_id": payload["identity"]["head"],
                                   "user": {"id": gate.CODEX_REVIEWER_ID,
                                            "login": gate.CODEX_REVIEWER, "type": "Bot"},
                                   "state": "COMMENTED", "submitted_at": "2026-11-05T10:00:00Z",
                                   "body": gate.CODEX_CLEAN_BODY,
                                   "html_url": "https://github.com/o/r/pull/7#pullrequestreview-42"}]
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}):
                gate.publish(work, api, "failure")
            self.assertEqual(gate.load(work / "summary.json")["state"], "pending")
            self.assertEqual(api.posted[-1][1], "pending")
            self.assertNotIn("codex-evidence=", api.posted[-1][2])

    def test_mixed_review_waits_for_codex_before_spending_claude_usage(self):
        payload, _ = sample()
        payload["identity"]["labels"] = ["authorship:mixed"]
        payload["providers"] = ["codex", "claude"]
        payload.pop("binding")
        payload["binding"] = gate.digest(payload)
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            api = FakeGitHub(payload["identity"])
            with patch.object(gate, "GitHub", return_value=api), \
                    patch.object(gate.subprocess, "run") as process:
                gate.run_provider(work, "claude")
            process.assert_not_called()
            self.assertIn("pending", gate.load(work / "result-claude.json"))

    def test_publish_binds_live_head_base_and_labels(self):
        payload, result = sample()
        mutations = (lambda p: p["head"].update(sha="c" * 40),
                     lambda p: p["base"].update(sha="c" * 40),
                     lambda p: p.update(labels=[{"name": "authorship:claude"}]))
        for change in mutations:
            with tempfile.TemporaryDirectory() as tmp:
                work = Path(tmp)
                gate.save(work / "input.json", payload)
                gate.save(work / "result-claude.json", result)
                api = FakeGitHub(payload["identity"])
                change(api.pr)
                with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}), self.assertRaises(gate.GateError):
                    gate.publish(work, api, "success")
                self.assertEqual(api.posted[-1][1], "failure")

    def test_superseded_run_cannot_replace_newer_status(self):
        payload, _ = sample()
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            api = FakeGitHub(payload["identity"])
            api.owns = False
            gate.publish(work, api, "success")
            self.assertEqual(api.posted, [])

    def test_docs_pass_without_provider_job(self):
        payload, _ = sample()
        payload.update(paths=[], providers=[], chunks=[])
        payload.pop("binding")
        payload["binding"] = gate.digest(payload)
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            api = FakeGitHub(payload["identity"])
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}):
                gate.publish(work, api, "skipped")
            self.assertEqual(api.posted[-1][1], "success")

    def test_shared_head_cannot_publish_docs_only_success_over_functional_pr(self):
        payload, _ = sample()
        payload["identity"]["pr"] = 8
        payload["identity"]["base"] = "c" * 40
        payload.update(paths=[], providers=[], chunks=[])
        payload.pop("binding")
        payload["binding"] = gate.digest(payload)
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            api = FakeGitHub(payload["identity"])
            api.open_prs = [7, 8]
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}), self.assertRaises(gate.GateError):
                gate.publish(work, api, "skipped")
            self.assertEqual(api.posted[-1][1], "failure")
            self.assertEqual(gate.load(work / "summary.json")["state"], "failure")

    def test_failed_model_job_never_passes_with_a_good_artifact(self):
        payload, result = sample()
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            gate.save(work / "input.json", payload)
            gate.save(work / "result-claude.json", result)
            api = FakeGitHub(payload["identity"])
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "summary.md")}), self.assertRaises(gate.GateError):
                gate.publish(work, api, "failure")
            self.assertEqual(api.posted[-1][1], "failure")

    def test_prepare_denies_untrusted_paid_trigger(self):
        payload, _ = sample()
        api = FakeGitHub(payload["identity"])
        api.permission = "read"
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"GITHUB_ACTOR": "outsider", "GITHUB_TRIGGERING_ACTOR": "outsider"}):
            with self.assertRaises(gate.GateError):
                gate.prepare(Path(tmp), Path(tmp), 7, api)
        self.assertEqual(api.posted[-1][1], "failure")
        self.assertEqual(api.permission_calls, 1)

    def test_prepare_timeout_publishes_failure(self):
        payload, _ = sample()
        api = FakeGitHub(payload["identity"])
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"GITHUB_ACTOR": "maintainer",
                "GITHUB_TRIGGERING_ACTOR": "maintainer"}), patch.object(gate, "git",
                side_effect=subprocess.TimeoutExpired("git", 1)):
            with self.assertRaises(subprocess.TimeoutExpired):
                gate.prepare(Path(tmp), Path(tmp), 7, api)
        self.assertEqual(api.posted[-1][1], "failure")
        self.assertIn("preparation failed", api.posted[-1][2])

    def test_scheduled_dispatch_requires_pr_author_write_access(self):
        payload, _ = sample()
        api = FakeGitHub(payload["identity"])
        api.permission = "read"
        env = {"GITHUB_ACTOR": "github-actions[bot]", "GITHUB_TRIGGERING_ACTOR": "github-actions[bot]",
               "GITHUB_EVENT_NAME": "workflow_dispatch", "GITHUB_REF": "refs/heads/main",
               "GITHUB_DEFAULT_BRANCH": "main"}
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, env):
            with self.assertRaises(gate.GateError) as error:
                gate.prepare(Path(tmp), Path(tmp), 7, api)
        self.assertIn("maintainer", str(error.exception))
        self.assertEqual(api.permission_calls, 1)
        api.permission = "write"
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, env):
            with self.assertRaises(gate.GateError) as error:
                gate.prepare(Path(tmp), Path(tmp), 7, api)
        self.assertNotIn("maintainer", str(error.exception))
        self.assertEqual(api.last_permission_actor, "builder")
        api.pr["base"]["ref"] = "feature/stack"
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, env):
            with self.assertRaises(gate.GateError) as error:
                gate.prepare(Path(tmp), Path(tmp), 7, api)
        self.assertNotIn("maintainer", str(error.exception))
        self.assertEqual(api.last_permission_actor, "builder")

    def test_prepare_fetches_diff_without_executing_or_checking_out_pr(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            def git(*args):
                return subprocess.check_output(["git", *args], cwd=root, text=True, encoding="utf-8").strip()
            git("init", "--quiet")
            git("config", "user.name", "Gate test")
            git("config", "user.email", "gate-test@example.invalid")
            git("config", "commit.gpgsign", "false")
            git("config", "core.hooksPath", str(root / "no-hooks"))
            source = root / "mobile/lib/main.dart"
            source.parent.mkdir(parents=True)
            source.write_text("void main() {}\n", encoding="utf-8")
            git("add", ".")
            git("commit", "--quiet", "-m", "base")
            base = git("rev-parse", "HEAD")
            source.write_text("void main() { print('changed'); }\n", encoding="utf-8")
            git("commit", "--quiet", "-am", "functional change")
            head = git("rev-parse", "HEAD")
            git("update-ref", "refs/pull/7/head", head)
            git("checkout", "--quiet", "--detach", base)
            git("remote", "add", "origin", str(root))
            payload, _ = sample()
            payload["identity"].update(head=head, base=base)
            api = FakeGitHub(payload["identity"])
            with patch.dict(os.environ, {"GITHUB_OUTPUT": str(root / "outputs"), "GITHUB_ACTOR": "maintainer", "GITHUB_TRIGGERING_ACTOR": "maintainer"}):
                gate.prepare(root, root / "gate", 7, api)
            prepared = gate.load(root / "gate/input.json")
            gate.check_payload(prepared)
            self.assertEqual(prepared["providers"], ["claude"])
            self.assertIn("print('changed')", prepared["chunks"][0]["prompt"])
            self.assertEqual(source.read_text(), "void main() {}\n")
            self.assertEqual(git("rev-parse", "HEAD"), base)


if __name__ == "__main__":
    unittest.main()
