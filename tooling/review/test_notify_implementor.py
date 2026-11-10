"""Handoff comments are current-head only and idempotent."""
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import github_gate as gate
from notify_implementor import GITHUB_ACTIONS_BOT_ID, notify


class FakeAPI:
    run_url = "https://github.com/o/r/actions/runs/1"

    def __init__(self, snapshot):
        self.pr = {"number": snapshot["pr"], "head": {"sha": snapshot["head"]},
                   "base": {"sha": snapshot["base"], "ref": snapshot["base_ref"]},
                   "draft": False, "state": "open", "user": {"login": "builder"},
                   "labels": [{"name": x} for x in snapshot["labels"]]}
        self.comments = []
        self.owns = True
        self.statuses = []
        self.post_error = False
        self.get_error = False
        self.supersede_on_post = False
        self.supersede_after_post = False
        self.change_head_after_post = False
        self.status_error = False
        self.unique = True

    def owns_status(self, head):
        return self.owns

    def api(self, path, body=None):
        if path.startswith("pulls/"):
            return self.pr
        if body is not None:
            if self.post_error:
                if self.supersede_on_post:
                    self.owns = False
                raise gate.GateError("GitHub API returned HTTP 403")
            comment = {**body, "user": {"id": GITHUB_ACTIONS_BOT_ID,
                                        "login": "github-actions[bot]"}}
            self.comments.append(comment)
            if self.supersede_after_post:
                self.owns = False
            if self.change_head_after_post:
                self.pr["head"]["sha"] = "c" * 40
            return comment
        if self.get_error and path.startswith("issues/"):
            raise gate.GateError("GitHub API returned HTTP 403")
        return self.comments

    def status(self, head, state, description):
        if self.status_error:
            raise gate.GateError("Status API unavailable")
        self.statuses.append((head, state, description))

    def assert_unique_open_pr(self, head, number):
        if not self.unique:
            raise gate.GateError("Commit shared by multiple open PRs")


def claude_pass_fixture():
    snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
    prompt = "Review the current diff"
    payload = {"identity": snapshot, "paths": ["tooling/review/test_notify_implementor.py"],
               "providers": ["claude"], "policy_sha": snapshot["base"],
               "run_url": FakeAPI.run_url,
               "chunks": [{"prompt": prompt, "sha256": gate.digest(prompt)}]}
    payload["binding"] = gate.digest(payload)
    result = {"provider": "claude", "binding": payload["binding"],
              "results": [{"sha256": payload["chunks"][0]["sha256"],
                           "review": {"verdict": "PASS", "slice_complete": True,
                                      "findings": [],
                                      "unverified": ["Runtime tests were not executed by the reviewer"]}}]}
    return payload, result


class NotifyTests(unittest.TestCase):
    def test_published_claude_pass_stays_pending_until_handoff_succeeds(self):
        payload, result = claude_pass_fixture()
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "input.json", payload)
            gate.save(work / "result-claude.json", result)
            api = FakeAPI(payload["identity"])
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "step.md")}):
                gate.publish(work, api, "success")
            summary = gate.load(work / "summary.json")
            self.assertIsNone(summary["codex_evidence"])
            self.assertEqual([state for _, state, _ in api.statuses], ["pending"])
            api.post_error = True
            with self.assertRaisesRegex(gate.GateError, "HTTP 403"):
                notify(work, api)
            self.assertEqual([state for _, state, _ in api.statuses], ["pending"])
            api.post_error = False
            notify(work, api)
            self.assertEqual(len(api.comments), 1)
            self.assertEqual([state for _, state, _ in api.statuses], ["pending", "success"])

    def test_initial_pending_write_failure_cannot_finalize(self):
        payload, result = claude_pass_fixture()
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "input.json", payload)
            gate.save(work / "result-claude.json", result)
            api = FakeAPI(payload["identity"])
            api.status_error = True
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(work / "step.md")}), \
                    self.assertRaisesRegex(gate.GateError, "Status API unavailable"):
                gate.publish(work, api, "success")
            self.assertTrue((work / "summary.json").exists())
            summary = gate.load(work / "summary.json")
            self.assertEqual(summary["state"], "success")
            self.assertNotIn("handoff_status_staged", summary)
            api.status_error = False
            with self.assertRaisesRegex(gate.GateError, "no staged pending status"):
                notify(work, api)
            self.assertEqual(api.comments, [])
            self.assertEqual(api.statuses, [])

    def test_failed_required_handoff_leaves_pending_status(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "handoff_status_staged": gate.handoff_marker(snapshot, "receipt"),
                   "message": "PASS", "providers": [{"provider": "claude", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            api.statuses = [(snapshot["head"], "pending", "Review complete; posting handoff")]
            api.post_error = True
            with self.assertRaises(gate.GateError):
                notify(work, api)
            self.assertEqual(api.statuses[-1][1], "pending")
            self.assertEqual(api.comments, [])
            api.supersede_on_post = True
            with self.assertRaises(gate.GateError):
                notify(work, api)
            self.assertEqual(api.statuses[-1][1], "pending")

            api.owns = True
            api.supersede_on_post = False
            api.post_error = False
            api.get_error = True
            with self.assertRaises(gate.GateError):
                notify(work, api)
            self.assertEqual(api.statuses[-1][1], "pending")

    def test_success_requires_delivered_handoff_and_current_unique_head(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "handoff_status_staged": gate.handoff_marker(snapshot, "receipt"),
                   "message": "PASS: claude reviewed this exact diff",
                   "providers": [{"provider": "claude", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            notify(work, api)
            self.assertEqual(len(api.comments), 1)
            self.assertEqual(api.statuses, [(snapshot["head"], "success", summary["message"])])
            api.statuses.clear()
            notify(work, api)  # The existing bot handoff is sufficient on retry.
            self.assertEqual(len(api.comments), 1)
            self.assertEqual(api.statuses[-1][1], "success")
            for flag in ("supersede_after_post", "change_head_after_post"):
                api = FakeAPI(snapshot)
                setattr(api, flag, True)
                notify(work, api)
                self.assertEqual(api.statuses, [])
            api = FakeAPI(snapshot)
            api.unique = False
            with self.assertRaisesRegex(gate.GateError, "shared"):
                notify(work, api)
            self.assertEqual(api.statuses, [])

    def test_final_status_failure_or_malformed_summary_never_succeeds(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "handoff_status_staged": gate.handoff_marker(snapshot, "receipt"),
                   "message": "PASS", "providers": [{"provider": "claude", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            api.status_error = True
            with self.assertRaisesRegex(gate.GateError, "Status API unavailable"):
                notify(work, api)
            self.assertEqual(api.statuses, [])
            gate.save(work / "summary.json", {"state": "success", "providers": [{}]})
            with self.assertRaises(KeyError):
                notify(work, FakeAPI(snapshot))

    def test_unstaged_or_rebound_handoff_cannot_finalize_success(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "message": "PASS", "providers": [{"provider": "claude", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            api = FakeAPI(snapshot)
            altered_identity = {**snapshot, "base": "c" * 40}
            for marker in (None, gate.handoff_marker(snapshot, "different"),
                           gate.handoff_marker(altered_identity, "receipt")):
                summary["handoff_status_staged"] = marker
                gate.save(work / "summary.json", summary)
                with self.assertRaisesRegex(gate.GateError, "no staged pending status"):
                    notify(work, api)
            self.assertEqual(api.comments, [])
            self.assertEqual(api.statuses, [])

    def test_superseded_unstaged_run_exits_without_a_handoff_error(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "message": "PASS", "providers": [{"provider": "claude", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            for change in (lambda pr: pr["head"].update(sha="c" * 40),
                           lambda pr: pr.update(state="closed")):
                api = FakeAPI(snapshot)
                change(api.pr)
                notify(work, api)
                self.assertEqual(api.comments, [])
                self.assertEqual(api.statuses, [])

    def test_codex_success_keeps_exact_evidence_prefix(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:claude"]}
        evidence_ids = ["review:42"]
        evidence = gate.digest(evidence_ids)[:16]
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "handoff_status_staged": gate.handoff_marker(snapshot, "receipt"),
                   "message": "PASS: codex reviewed this exact diff", "codex_evidence": evidence,
                   "providers": [{"provider": "codex", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            with patch("notify_implementor.codex_review", return_value={
                    "outcome": "clean", "evidence_ids": evidence_ids}) as receipt:
                notify(work, api)
            self.assertEqual(receipt.call_count, 2)
            self.assertTrue(api.statuses[-1][2].startswith("codex-evidence=" + evidence))
            api.statuses.clear()
            summary.pop("codex_evidence")
            gate.save(work / "summary.json", summary)
            with self.assertRaisesRegex(gate.GateError, "Missing or malformed native Codex"):
                notify(work, FakeAPI(snapshot))

    def test_changed_codex_receipt_blocks_handoff_before_comment(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:claude"]}
        evidence_ids = ["review:42"]
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "handoff_status_staged": gate.handoff_marker(snapshot, "receipt"),
                   "message": "PASS: codex reviewed this exact diff",
                   "codex_evidence": gate.digest(evidence_ids)[:16],
                   "providers": [{"provider": "codex", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            for live in ({"outcome": "ambiguous", "evidence_ids": evidence_ids},
                         {"outcome": "changes_required", "evidence_ids": evidence_ids},
                         {"outcome": "clean", "evidence_ids": ["review:43"]}):
                api = FakeAPI(snapshot)
                with patch("notify_implementor.codex_review", return_value=live), \
                        self.assertRaisesRegex(gate.GateError, "Native Codex review evidence changed"):
                    notify(work, api)
                self.assertEqual(api.comments, [])
                self.assertEqual(api.statuses, [])
            api = FakeAPI(snapshot)
            with patch("notify_implementor.codex_review",
                       side_effect=gate.NativeReviewPending("Waiting for native Codex")), \
                    self.assertRaises(gate.NativeReviewPending):
                notify(work, api)
            self.assertEqual(api.comments, [])
            self.assertEqual(api.statuses, [])

    def test_codex_receipt_changed_after_handoff_still_blocks_final_success(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:claude"]}
        evidence_ids = ["review:42"]
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "handoff_status_staged": gate.handoff_marker(snapshot, "receipt"),
                   "message": "PASS: codex reviewed this exact diff",
                   "codex_evidence": gate.digest(evidence_ids)[:16],
                   "providers": [{"provider": "codex", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            with patch("notify_implementor.codex_review", side_effect=[
                    {"outcome": "clean", "evidence_ids": evidence_ids},
                    {"outcome": "changes_required", "evidence_ids": evidence_ids}]), \
                    self.assertRaisesRegex(gate.GateError, "Native Codex review evidence changed"):
                notify(work, api)
            self.assertEqual(len(api.comments), 1)
            self.assertEqual(api.statuses, [])

    def test_docs_success_and_pending_do_not_write_handoff_status(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            api = FakeAPI(snapshot)
            api.post_error = True
            for summary in ({"identity": snapshot, "state": "pending"},
                            {"identity": snapshot, "state": "success", "providers": []}):
                gate.save(work / "summary.json", summary)
                notify(work, api)
            self.assertEqual(api.statuses, [])

    def test_notifies_once_and_ignores_stale_head(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:claude"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "failure",
                   "message": "Claude found issues", "providers": [{"provider": "claude", "results": [
                       {"review": {"findings": [{"severity": "high", "path": "mobile/lib/main.dart",
                                                  "line": 12}]}}]}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            notify(work, api)
            notify(work, api)
            self.assertEqual(len(api.comments), 1)
            api.owns = False
            notify(work, api)
            self.assertEqual(len(api.comments), 1)
            api.owns = True
            self.assertIn("@builder", api.comments[0]["body"])
            self.assertIn("authorship:claude", api.comments[0]["body"])
            self.assertIn("HIGH `mobile/lib/main.dart:12`", api.comments[0]["body"])
            api.pr["head"]["sha"] = "c" * 40
            notify(work, api)
            self.assertEqual(len(api.comments), 1)

    def test_pending_review_does_not_notify(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:claude"]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", {"identity": snapshot, "state": "pending"})
            api = FakeAPI(snapshot)
            notify(work, api)
            self.assertEqual(api.comments, [])

    def test_unrecognized_codex_receipt_requests_investigation(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:claude"]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", {"identity": snapshot, "binding": "receipt",
                "state": "failure", "message": "Codex receipt unrecognized; investigate review evidence",
                "providers": []})
            api = FakeAPI(snapshot)
            notify(work, api)
            self.assertIn("Investigate the Codex review receipt", api.comments[0]["body"])
            self.assertNotIn("Address the review findings", api.comments[0]["body"])

    def test_pass_with_medium_finding_still_calls_for_assessment(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
            "handoff_status_staged": gate.handoff_marker(snapshot, "receipt"),
            "message": "PASS: claude reviewed this exact diff", "providers": [{"provider": "claude",
            "results": [{"review": {"findings": [{"severity": "medium", "path": "mobile/lib/main.dart", "line": 9}]}}]}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            notify(work, api)
            self.assertIn("Non-blocking findings were reported", api.comments[0]["body"])

    def test_second_findings_head_pauses_for_human_review(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "first", "state": "failure",
                   "message": "Reviewer requested changes; resolve findings and rerun",
                   "providers": [{"provider": "claude", "results": [{"review": {"findings": [
                       {"severity": "high", "path": "mobile/lib/main.dart", "line": 9}]}}]}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            notify(work, api)
            self.assertIn("Address the review findings", api.comments[0]["body"])
            snapshot["head"] = "c" * 40
            api.pr["head"]["sha"] = snapshot["head"]
            summary["binding"] = "second"
            gate.save(work / "summary.json", summary)
            notify(work, api)
            self.assertEqual(len(api.comments), 2)
            self.assertIn("Pause implementation and wait for the maintainer", api.comments[1]["body"])
            self.assertNotIn("Address the review findings", api.comments[1]["body"])


if __name__ == "__main__":
    unittest.main()
