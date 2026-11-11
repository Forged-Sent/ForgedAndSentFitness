"""Tests for the generated live status page. No network and no gh calls."""
from pathlib import Path
from tempfile import TemporaryDirectory
import subprocess
import unittest

from live_status import (BOARD, DECISIONS, agent_actions, attention, board_cell, checks_cell,
                         checks_summary, local_edits, open_decisions, optional_failing, pull, render,
                         unpublished_branches)


def pr(**kw):
    base = {"number": 7, "title": "Add Today", "url": "https://example.test/pull/7", "headRefName": "feat/today",
            "isDraft": False, "mergeable": "MERGEABLE", "reviewDecision": "", "statusCheckRollup": []}
    base.update(kw)
    return base


class ChecksSummaryTest(unittest.TestCase):
    def test_none_when_empty(self):
        self.assertEqual(checks_summary([]), "none")
        self.assertEqual(checks_summary(None), "none")

    def test_failing_wins(self):
        self.assertEqual(checks_summary([{"name": "other", "conclusion": "SUCCESS"},
                                         {"name": "ci-gate", "conclusion": "FAILURE"}]), "failing")

    def test_running_only_when_the_required_check_itself_is_running(self):
        self.assertEqual(checks_summary([{"name": "ci-gate", "status": "IN_PROGRESS", "conclusion": ""}]), "running")
        self.assertEqual(checks_summary([{"name": "other", "status": "IN_PROGRESS", "conclusion": ""}]),
                         "ci-gate not reported")

    def test_only_required_checks_decide_when_present(self):
        rollup = [{"name": "ci-gate", "conclusion": "SUCCESS"}, {"name": "flutter-ai-review", "conclusion": "FAILURE"}]
        self.assertEqual(checks_summary(rollup), "passing")
        self.assertEqual(optional_failing(rollup), ["flutter-ai-review"])
        self.assertEqual(checks_cell(rollup), "passing (not required, failing: flutter-ai-review)")
        self.assertEqual(attention(pr(statusCheckRollup=rollup)), "Ready for your merge decision")

    def test_required_check_failing_is_failing(self):
        rollup = [{"name": "ci-gate", "conclusion": "FAILURE"}, {"name": "other", "conclusion": "SUCCESS"}]
        self.assertEqual(checks_summary(rollup), "failing")
        self.assertEqual(attention(pr(statusCheckRollup=rollup)), "CI is failing")

    def test_required_check_as_legacy_status_and_still_running(self):
        self.assertEqual(checks_summary([{"context": "ci-gate", "state": "PENDING"}, {"name": "x", "conclusion": "FAILURE"}]), "running")

    def test_ci_gate_alone_decides_the_headline_in_all_four_combinations(self):
        # ci-gate (success or not reported) x another check (passed or failed).
        # ci-gate appears in GitHub's list only once the jobs it waits for have finished.
        gate = {"name": "ci-gate", "conclusion": "SUCCESS"}
        other_passed = {"name": "changes", "conclusion": "SUCCESS"}
        other_failed = {"name": "flutter-ai-review", "conclusion": "FAILURE"}
        note = " (not required, failing: flutter-ai-review)"
        ready = "Ready for your merge decision"
        cases = [
            ("success, other passed", [gate, other_passed], "passing", "passing", ready),
            ("success, other failed", [gate, other_failed], "passing", "passing" + note, ready),
            ("not reported, other passed", [other_passed], "ci-gate not reported", "ci-gate not reported", ""),
            ("not reported, other failed", [other_failed], "ci-gate not reported", "ci-gate not reported" + note, ""),
        ]
        for label, rollup, summary, shown, needs in cases:
            with self.subTest(label):
                self.assertEqual(checks_summary(rollup), summary)
                self.assertEqual(checks_cell(rollup), shown)
                self.assertEqual(attention(pr(statusCheckRollup=rollup)), needs)

    def test_ready_needs_success_and_nothing_else(self):
        for conclusion, shown in (("SKIPPED", "ci-gate skipped"), ("NEUTRAL", "ci-gate neutral"), ("STALE", "ci-gate stale")):
            with self.subTest(conclusion):
                rollup = [{"name": "ci-gate", "conclusion": conclusion}, {"name": "docs", "conclusion": "SUCCESS"}]
                self.assertEqual(checks_summary(rollup), shown)
                self.assertEqual(attention(pr(statusCheckRollup=rollup)), "")

    def test_passing_for_check_runs_and_legacy_statuses(self):
        self.assertEqual(checks_summary([{"name": "ci-gate", "conclusion": "SUCCESS"},
                                         {"name": "docs", "conclusion": "SKIPPED"}]), "passing")
        self.assertEqual(checks_summary([{"context": "ci-gate", "state": "SUCCESS"}]), "passing")


GATE_PASSED = [{"name": "ci-gate", "conclusion": "SUCCESS"}]
GATE_FAILED = [{"name": "ci-gate", "conclusion": "FAILURE"}]


class AttentionTest(unittest.TestCase):
    def test_failing_ci(self):
        self.assertEqual(attention(pr(statusCheckRollup=GATE_FAILED)), "CI is failing")

    def test_conflicts(self):
        self.assertEqual(attention(pr(mergeable="CONFLICTING", statusCheckRollup=GATE_PASSED)),
                         "Has merge conflicts")

    def test_ready_when_green_and_not_draft(self):
        self.assertEqual(attention(pr(statusCheckRollup=GATE_PASSED)), "Ready for your merge decision")

    def test_draft_and_running_need_nothing(self):
        self.assertEqual(attention(pr(isDraft=True, statusCheckRollup=GATE_PASSED)), "")
        self.assertEqual(attention(pr(statusCheckRollup=[{"name": "ci-gate", "status": "QUEUED"}])), "")

    def test_none_and_ci_gate_skipped_are_not_ready(self):
        skipped = [{"name": "ci-gate", "conclusion": "SKIPPED"}]
        for label, rollup, shown in (("GitHub lists no checks", [], "none"),
                                     ("GitHub sends no list at all", None, "none"),
                                     ("ci-gate was skipped", skipped, "ci-gate skipped")):
            with self.subTest(label):
                request = pr(statusCheckRollup=rollup)       # not a draft, no conflicts
                self.assertEqual(checks_summary(rollup), shown)
                self.assertEqual(attention(request), "")
                page = render([request], [], [], [], "now")
                self.assertIn(f"| {shown} | none | — |", page)
                self.assertNotIn("Ready for your merge decision", page)


class RenderTest(unittest.TestCase):
    def test_lists_attention_items_and_tables(self):
        page = render([pr(statusCheckRollup=GATE_FAILED, title="A | B")], [],
                      [("codex/demo", "2026-11-09", "feat: demo", "the whole branch"),
                       ("feat/today", "2026-11-10", "fix: tally", "2 commits")],
                      ["Q1", "Q2"], "2026-11-10 01:00 MST")
        self.assertIn("2 product decisions are still TODO", page)
        self.assertIn("CI is failing", page)
        self.assertIn("A \\| B", page)
        self.assertIn("2 local branches have work that is not on GitHub.", page)
        self.assertIn("| `codex/demo` | 2026-11-09 | feat: demo | the whole branch |", page)
        self.assertIn("| `feat/today` | 2026-11-10 | fix: tally | 2 commits |", page)

    def test_unavailable_when_gh_is_missing(self):
        page = render(None, None, [], [], "now")
        self.assertIn("Pull requests could not be read", page)

    def test_quiet_when_nothing_is_open(self):
        self.assertIn("Nothing right now.", render([], [], [], [], "now"))

    def test_says_whether_each_pull_request_changes_the_work_board(self):
        touched = pr(files=[{"path": "mobile/lib/a.dart"}, {"path": BOARD}])
        untouched = pr(number=8, files=[{"path": "tooling/x.py"}])
        self.assertEqual(board_cell(touched), "updated")
        self.assertEqual(board_cell(untouched), "not touched")
        self.assertEqual(board_cell(pr()), "unknown")                      # gh sent no file list
        self.assertEqual(board_cell(pr(files=[{"path": f"f{n}"} for n in range(100)])), "unknown")
        page = render([touched, untouched], [], [], [], "now")
        self.assertIn("| Needs you | Work board |", page)
        self.assertIn("| — | updated |", page)
        self.assertIn("| — | not touched |", page)

    def test_edits_made_in_the_vault_checkout_need_attention(self):
        page = render([], [], [], [], "now", [BOARD, "docs/HOME.md", "docs/a|b.md"])
        self.assertIn("The work board was edited in this checkout and the edit is not in a pull request.", page)
        self.assertIn("2 other files edited in this checkout are not in a pull request:** "
                      "`docs/HOME.md`, `docs/a\\|b.md`.", page)
        self.assertNotIn("Nothing right now.", page)
        one = render([], [], [], [], "now", ["docs/HOME.md"])
        self.assertIn("1 other file edited in this checkout is not in a pull request", one)
        self.assertNotIn("The work board was edited", one)

    def test_the_agent_is_told_what_to_do_about_vault_edits(self):
        self.assertEqual(agent_actions([]), [])
        actions = agent_actions([BOARD, "docs/HOME.md"])
        self.assertEqual(len(actions), 2)
        self.assertTrue(all(action.startswith("ACTION: ") for action in actions))
        self.assertIn("Publish it before you finish", actions[0])
        self.assertIn("ask whether to publish", actions[1])


class OpenDecisionsTest(unittest.TestCase):
    def test_counts_only_rows_still_marked_todo(self):
        with TemporaryDirectory() as tmp:
            page = Path(tmp) / DECISIONS
            page.parent.mkdir(parents=True)
            page.write_text("| **Q1** | x | y | ==TODO== | P01 |\n| **Q2** | x | y | Team-first | P01 |\n"
                            "| **L11** | x | y | ==TODO== | S3 |\n", encoding="utf-8")
            self.assertEqual(open_decisions(Path(tmp)), ["Q1", "L11"])


class TwoClones(unittest.TestCase):
    """A bare origin whose main has moved on, the author clone that moved it, and a vault clone behind it."""

    def git(self, cwd: Path, *args: str) -> None:
        subprocess.run(["git", "-c", "user.name=T", "-c", "user.email=t@example.invalid", *args],
                       cwd=cwd, check=True, capture_output=True)

    def head(self, repo: Path) -> str:
        return subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=repo, text=True).strip()

    def commit(self, repo: Path, name: str) -> None:
        (repo / name).write_text(name + "\n", encoding="utf-8")
        self.git(repo, "add", name)
        self.git(repo, "commit", "-qm", "add " + name)

    def setUp(self):
        tmp = TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        root = Path(tmp.name)
        self.git(root, "init", "-q", "--bare", "origin.git")
        self.git(root / "origin.git", "symbolic-ref", "HEAD", "refs/heads/main")
        self.git(root, "clone", "-q", "origin.git", "author")
        self.author = root / "author"
        self.git(self.author, "symbolic-ref", "HEAD", "refs/heads/main")   # whatever Git's default name is
        (self.author / "board.md").write_text("one\n", encoding="utf-8")
        (self.author / "notes.md").write_text("notes\n", encoding="utf-8")
        self.git(self.author, "add", ".")
        self.git(self.author, "commit", "-qm", "first")
        self.git(self.author, "push", "-q", "origin", "HEAD")
        self.git(root, "clone", "-q", "origin.git", "vault")
        self.vault = root / "vault"
        # The remote moves on: its newer commit changes board.md only.
        (self.author / "board.md").write_text("two\n", encoding="utf-8")
        self.git(self.author, "commit", "-qam", "second")
        self.git(self.author, "push", "-q", "origin", "HEAD")


class PullTest(TwoClones):
    """--pull only ever pulls main, and lets Git decide whether that is safe.

    Uncommitted changes stop it only when the fast-forward would overwrite them.
    """

    def test_a_checkout_that_is_not_on_main_is_never_pulled(self):
        # With no checkout on main, the page falls back to the current checkout.
        # Its branch tracks a remote branch that has moved on, and it must stay put.
        self.git(self.vault, "checkout", "-q", "-b", "feature", "--track", "origin/main")
        before = self.head(self.vault)
        problem = pull(self.vault)
        self.assertIn("Did not pull", problem)
        self.assertIn("is on feature, not main", problem)
        self.assertEqual(self.head(self.vault), before)
        self.git(self.vault, "checkout", "-q", "--detach")
        self.assertIn("is on no branch, not main", pull(self.vault))
        self.assertEqual(self.head(self.vault), before)

    def test_fast_forwards_a_clean_checkout(self):
        self.assertEqual(pull(self.vault), "")
        self.assertEqual(self.head(self.vault), self.head(self.author))

    def test_uncommitted_changes_elsewhere_do_not_stop_the_fast_forward(self):
        (self.vault / "notes.md").write_text("my unsaved notes\n", encoding="utf-8")
        self.assertEqual(pull(self.vault), "")
        self.assertEqual(self.head(self.vault), self.head(self.author))
        self.assertEqual((self.vault / "notes.md").read_text(encoding="utf-8"), "my unsaved notes\n")

    def test_git_refuses_to_overwrite_local_changes_and_its_message_is_returned(self):
        before = self.head(self.vault)
        (self.vault / "board.md").write_text("my unsaved board\n", encoding="utf-8")
        problem = pull(self.vault)
        self.assertIn("Could not fast-forward", problem)
        self.assertIn("board.md", problem)                      # Git names the file in the way
        self.assertEqual(self.head(self.vault), before)         # nothing moved
        self.assertEqual((self.vault / "board.md").read_text(encoding="utf-8"), "my unsaved board\n")

    def test_a_checkout_with_nowhere_to_pull_from_reports_instead_of_raising(self):
        self.git(self.vault, "remote", "remove", "origin")
        self.assertIn("Could not fast-forward", pull(self.vault))

    def test_an_edit_that_already_landed_upstream_does_not_block_the_fast_forward(self):
        # The maintainer edited board.md in the vault; an agent published the same edit.
        (self.vault / "board.md").write_text("two\n", encoding="utf-8")
        (self.vault / "notes.md").write_text("my unsaved notes\n", encoding="utf-8")
        self.assertEqual(local_edits(self.vault), ["board.md", "notes.md"])
        self.assertEqual(pull(self.vault), "")
        self.assertEqual(self.head(self.vault), self.head(self.author))
        self.assertEqual((self.vault / "board.md").read_text(encoding="utf-8"), "two\n")
        self.assertEqual((self.vault / "notes.md").read_text(encoding="utf-8"), "my unsaved notes\n")
        self.assertEqual(local_edits(self.vault), ["notes.md"])           # only the unpublished edit is left

    def test_a_staged_edit_that_matches_upstream_is_left_to_git(self):
        # Git itself fast-forwards over an index entry that already equals the incoming file.
        (self.vault / "board.md").write_text("two\n", encoding="utf-8")
        self.git(self.vault, "add", "board.md")
        self.assertEqual(pull(self.vault), "")
        self.assertEqual(self.head(self.vault), self.head(self.author))
        self.assertEqual((self.vault / "board.md").read_text(encoding="utf-8"), "two\n")

    def test_a_staged_edit_with_further_unstaged_changes_is_never_put_back(self):
        before = self.head(self.vault)
        (self.vault / "board.md").write_text("staged\n", encoding="utf-8")
        self.git(self.vault, "add", "board.md")
        (self.vault / "board.md").write_text("two\n", encoding="utf-8")       # worktree now equals upstream
        self.assertIn("Could not fast-forward", pull(self.vault))
        self.assertEqual(self.head(self.vault), before)
        self.assertEqual((self.vault / "board.md").read_text(encoding="utf-8"), "two\n")

    def test_an_edit_that_differs_from_upstream_is_kept_beside_one_that_landed(self):
        before = self.head(self.vault)
        (self.vault / "board.md").write_text("my unsaved board\n", encoding="utf-8")
        self.assertIn("Could not fast-forward", pull(self.vault))
        self.assertEqual(self.head(self.vault), before)
        self.assertEqual((self.vault / "board.md").read_text(encoding="utf-8"), "my unsaved board\n")

    def test_a_landed_edit_is_written_back_when_another_file_still_blocks_the_pull(self):
        # Upstream also changes notes.md, and the vault has its own unsaved notes.
        (self.author / "notes.md").write_text("notes two\n", encoding="utf-8")
        self.git(self.author, "commit", "-qam", "third")
        self.git(self.author, "push", "-q", "origin", "HEAD")
        before = self.head(self.vault)
        (self.vault / "board.md").write_text("two\n", encoding="utf-8")            # already upstream
        (self.vault / "notes.md").write_text("my unsaved notes\n", encoding="utf-8")  # blocks the pull
        problem = pull(self.vault)
        self.assertIn("Could not fast-forward", problem)
        self.assertIn("notes.md", problem)
        self.assertEqual(self.head(self.vault), before)
        self.assertEqual((self.vault / "board.md").read_text(encoding="utf-8"), "two\n")
        self.assertEqual((self.vault / "notes.md").read_text(encoding="utf-8"), "my unsaved notes\n")
        self.assertEqual(local_edits(self.vault), ["board.md", "notes.md"])      # both still reported

    def test_a_landed_edit_is_written_back_when_main_has_diverged(self):
        self.commit(self.vault, "local-only.md")                                 # a commit upstream lacks
        before = self.head(self.vault)
        (self.vault / "board.md").write_text("two\n", encoding="utf-8")
        self.assertIn("Could not fast-forward", pull(self.vault))
        self.assertEqual(self.head(self.vault), before)
        self.assertEqual((self.vault / "board.md").read_text(encoding="utf-8"), "two\n")
        self.assertEqual(local_edits(self.vault), ["board.md"])


class UnpublishedBranchesTest(TwoClones):
    def test_lists_work_github_cannot_show_and_says_what_is_missing(self):
        vault = self.vault
        self.git(vault, "checkout", "-q", "-b", "local-only")              # never pushed, no upstream
        self.commit(vault, "a.md")
        self.git(vault, "checkout", "-q", "-b", "ahead-of-its-upstream", "main")
        self.git(vault, "push", "-q", "-u", "origin", "ahead-of-its-upstream")
        self.commit(vault, "b.md")                                         # one commit not pushed
        self.git(vault, "checkout", "-q", "-b", "cut-from-the-remote", "--track", "origin/main")
        self.commit(vault, "c.md")
        self.commit(vault, "d.md")                                         # tracks main, never pushed
        self.git(vault, "checkout", "-q", "-b", "fully-pushed", "main")
        self.commit(vault, "e.md")
        self.git(vault, "push", "-q", "-u", "origin", "fully-pushed")      # nothing missing: not listed
        self.git(vault, "checkout", "-q", "-b", "nothing-new", "main")     # no commits of its own
        found = {name: missing for name, _, _, missing in unpublished_branches(vault)}
        self.assertEqual(found, {"local-only": "the whole branch", "ahead-of-its-upstream": "1 commit",
                                 "cut-from-the-remote": "2 commits"})


if __name__ == "__main__":
    unittest.main()
