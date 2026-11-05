"""Handoff comments are current-head only and idempotent."""
from pathlib import Path
import tempfile
import unittest

import github_gate as gate
from notify_implementor import notify


class FakeAPI:
    run_url = "https://github.com/o/r/actions/runs/1"

    def __init__(self, snapshot):
        self.pr = {"number": snapshot["pr"], "head": {"sha": snapshot["head"]},
                   "base": {"sha": snapshot["base"], "ref": snapshot["base_ref"]},
                   "draft": False, "state": "open", "user": {"login": "builder"},
                   "labels": [{"name": x} for x in snapshot["labels"]]}
        self.comments = []
        self.owns = True

    def owns_status(self, head):
        return self.owns

    def api(self, path, body=None):
        if path.startswith("pulls/"):
            return self.pr
        if body is not None:
            self.comments.append(body)
            return body
        return self.comments


class NotifyTests(unittest.TestCase):
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


if __name__ == "__main__":
    unittest.main()
