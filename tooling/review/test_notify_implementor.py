"""Handoff comments are current-head only and idempotent."""
from pathlib import Path
import tempfile
import unittest

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
            return comment
        if self.get_error and path.startswith("issues/"):
            raise gate.GateError("GitHub API returned HTTP 403")
        return self.comments

    def status(self, head, state, description):
        self.statuses.append((head, state, description))


class NotifyTests(unittest.TestCase):
    def test_failed_required_handoff_revokes_owned_green_status(self):
        snapshot = {"pr": 7, "head": "a" * 40, "base": "b" * 40,
                    "base_ref": "main", "draft": False, "labels": ["authorship:codex"]}
        summary = {"identity": snapshot, "binding": "receipt", "state": "success",
                   "message": "PASS", "providers": [{"provider": "claude", "results": []}]}
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            gate.save(work / "summary.json", summary)
            api = FakeAPI(snapshot)
            api.post_error = True
            with self.assertRaises(gate.GateError):
                notify(work, api)
            self.assertEqual(api.statuses, [(snapshot["head"], "failure",
                "Review handoff failed; inspect this workflow run")])
            self.assertEqual(api.comments, [])
            api.statuses.clear()
            api.supersede_on_post = True
            with self.assertRaises(gate.GateError):
                notify(work, api)
            self.assertEqual(api.statuses, [])

            api.owns = True
            api.supersede_on_post = False
            api.post_error = False
            api.get_error = True
            with self.assertRaises(gate.GateError):
                notify(work, api)
            self.assertEqual(api.statuses, [(snapshot["head"], "failure",
                "Review handoff failed; inspect this workflow run")])

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
