"""Scheduled reconciliation binds native evidence IDs, not status timestamps."""
import unittest

import github_gate as gate
import reconcile_codex as reconcile

HEAD = "a" * 40
BOT = {"id": gate.CODEX_REVIEWER_ID, "login": gate.CODEX_REVIEWER, "type": "Bot"}


class FakeApi:
    def __init__(self):
        self.prs = [{"number": 7, "draft": False,
                     "labels": [{"name": "authorship:claude"}],
                     "head": {"sha": HEAD}}]
        self.reviews = [{"id": 42, "user": BOT, "commit_id": HEAD,
                         "state": "COMMENTED", "submitted_at": "2026-11-05T01:00:00Z",
                         "body": "unknown", "html_url": "https://example.invalid/review/42"}]
        self.status = None
        self.active = []
        self.runs = {}
        self.queried = []
        self.sent = []
        self.bad_pr = None
        self.files = [{"filename": "mobile/lib/main.dart"}]

    def pages(self, path):
        if path == "pulls?state=open":
            return iter(self.prs)
        if path == f"commits/{HEAD}/statuses":
            return iter([self.status] if self.status else [])
        if path == "pulls/7/files":
            return iter(self.files)
        raise AssertionError(path)

    def request(self, path, body=None):
        if path.startswith("actions/workflows/flutter-ai-review.yml/runs?"):
            self.queried.append(path)
            selected = path.split("status=", 1)[1].split("&", 1)[0]
            return {"workflow_runs": [run for run in self.active if run["status"] == selected]}
        if path.startswith("actions/runs/"):
            return self.runs[path.split("/")[-1]]
        if path == "pulls/7":
            return {"changed_files": len(self.files), "head": {"sha": HEAD}}
        if path == "actions/workflows/flutter-ai-review.yml/dispatches":
            self.sent.append((path, body))
            return None
        if path.startswith("issues/7/timeline?"):
            return []
        if path.startswith("pulls/7/reviews/") and "/comments?" in path:
            return []
        if path.startswith("pulls/7/reviews?"):
            return self.reviews
        if path.startswith("issues/8/timeline?") or path.startswith("pulls/8/reviews?"):
            raise RuntimeError("Temporary API failure")
        raise AssertionError(path)

    api = request


class ReconcileTests(unittest.TestCase):
    def test_new_review_dispatches_to_default_branch(self):
        api = FakeApi()
        self.assertEqual(reconcile.reconcile(api, "main"), [7])
        self.assertEqual(api.sent, [("actions/workflows/flutter-ai-review.yml/dispatches",
                                     {"ref": "main", "inputs": {"pr": "7"}})])

    def test_matching_evidence_digest_skips_even_if_status_timestamp_is_old(self):
        api = FakeApi()
        marker = gate.digest([42])[:16]
        api.status = {"context": reconcile.CONTEXT,
                      "description": f"codex-evidence={marker} PASS",
                      "created_at": "2026-11-04T23:00:00Z"}
        self.assertEqual(reconcile.reconcile(api, "main"), [])

    def test_status_after_unprocessed_review_still_dispatches(self):
        api = FakeApi()
        api.status = {"context": reconcile.CONTEXT, "description": "Review pending",
                      "created_at": "2026-11-05T02:00:00Z"}
        self.assertEqual(reconcile.reconcile(api, "main"), [7])

    def test_old_docs_only_status_cannot_hide_current_functional_pr(self):
        api = FakeApi()
        api.status = {"context": reconcile.CONTEXT,
                      "description": "Not required: no functional Flutter/backend changes"}
        self.assertEqual(reconcile.reconcile(api, "main"), [7])
        api = FakeApi()
        api.status = {"context": reconcile.CONTEXT,
                      "description": "Not required: no functional Flutter/backend changes"}
        api.files = [{"filename": "docs/notes.md"}]
        self.assertEqual(reconcile.reconcile(api, "main"), [])

    def test_active_run_prevents_duplicate_dispatch(self):
        api = FakeApi()
        api.active = [{"display_title": "Flutter AI review PR #7", "status": "in_progress"}]
        self.assertEqual(reconcile.reconcile(api, "main"), [])
        self.assertEqual(api.sent, [])

    def test_completed_history_does_not_exhaust_active_run_search(self):
        api = FakeApi()
        api.active = [{"display_title": "Flutter AI review PR #7", "status": "completed"}] * 3001
        self.assertEqual(reconcile.reconcile(api, "main"), [7])
        self.assertTrue(all("status=" in path for path in api.queried))

    def test_terminal_failure_after_review_is_not_redispatched(self):
        api = FakeApi()
        api.status = {"context": reconcile.CONTEXT, "state": "failure",
                      "description": "Commit is shared by multiple open PRs",
                      "target_url": "https://github.com/o/r/actions/runs/123/attempts/1"}
        api.runs["123"] = {"display_title": "Flutter AI review PR #7",
                            "event": "workflow_dispatch", "created_at": "2026-11-05T02:00:00Z"}
        self.assertEqual(reconcile.reconcile(api, "main"), [])
        self.assertEqual(api.sent, [])

    def test_review_arriving_during_failed_run_is_retried(self):
        api = FakeApi()
        api.status = {"context": reconcile.CONTEXT, "state": "failure",
                      "description": "Reviewer job failed",
                      "target_url": "https://github.com/o/r/actions/runs/123/attempts/1"}
        api.runs["123"] = {"display_title": "Flutter AI review PR #7",
                            "event": "workflow_dispatch", "created_at": "2026-11-05T00:00:00Z"}
        self.assertEqual(reconcile.reconcile(api, "main"), [7])

    def test_null_user_does_not_abort_and_later_pr_still_reconciles(self):
        api = FakeApi()
        api.reviews.insert(0, {"id": 41, "user": None, "commit_id": HEAD,
                               "state": "COMMENTED", "submitted_at": "2026-11-05T00:00:00Z"})
        self.assertEqual(reconcile.reconcile(api, "main"), [7])

    def test_one_pr_error_does_not_stop_later_pr(self):
        api = FakeApi()
        bad = {"number": 8, "draft": False,
               "labels": [{"name": "authorship:claude"}], "head": {"sha": "b" * 40}}
        api.prs.insert(0, bad)
        with self.assertRaisesRegex(RuntimeError, "PR #8"):
            reconcile.reconcile(api, "main")
        self.assertEqual(len(api.sent), 1)

    def test_draft_and_codex_authored_prs_skip(self):
        api = FakeApi()
        api.prs[0]["draft"] = True
        api.prs.append({"number": 8, "draft": False,
                        "labels": [{"name": "authorship:codex"}],
                        "head": {"sha": "b" * 40}})
        self.assertEqual(reconcile.reconcile(api, "main"), [])


if __name__ == "__main__":
    unittest.main()
