"""Tests for the WORK.md board and HOME focus generator."""
from pathlib import Path
from tempfile import TemporaryDirectory
import json
import unittest

import work_board
from work_board import (BOARD, HOME, LANES, WORK, WorkBoardError, apply_focus, by_lane,
                        parse_work, problems, render_board, render_focus, write)

HEADER = "| State | Work | Owner | Blocker / next action |\n|---|---|---|---|\n"
SAMPLE = "| {state} | [Sample task](handoffs/sample.md) | Tester | {action} |\n"
BASE_ROWS = (
    "| Active | [Review gate](PR-STATUS.md) | Maintainer | Verify the hosted route |\n"
    "| Ready | Native hosts | Flutter builder | Open the focused PR |\n"
    "| Blocked | Durable completion | Flutter builder | First slice is not merged. "
    "Unblocks when the storage contract merges |\n"
    "| Later | Firebase DEV | Maintainer | Design deny-by-default rules |\n"
)
HOME_PAGE = ("# Home\n\n<!-- work-focus:start -->\nold\n<!-- work-focus:end -->\n\n"
             "## Where to go\n")

# The layout on the unpublished dashboard refresh: sections instead of one table.
SECTIONED = """# Work board

## Now

| Step | What a man can see when it is done | State | Branch or PR | Next action |
|---|---|---|---|---|
| Decisions | Nothing yet | **Done** | branch `x` | None |
| CI accepts images | Nothing yet | **Done** | [#54](https://example.test/54) | — |
| Native hosts | The app builds | **Next** | no PR yet | Run prompt [P03](../reviews/P03.md) |
| S0 Design | The app opens | **In progress** | — | Run prompt P04 |

## Later

| Step | What a man can see when it is done | Prompt |
|---|---|---|
| S2 Private journal | Saves to a journal | [P06](../reviews/P06.md) |

## Paused

| Work | Why | Resume when |
|---|---|---|
| Hosted AI review gate | It guards an app with almost no code | S4 adds sign-in |

## How to update this page

- Starting a row: set State to **In progress**.
"""


def work(rows: str) -> str:
    return "# Active work\n\nIntro with a [link](PR-STATUS.md).\n\n" + HEADER + rows + "\nFooter.\n"


def lane_titles(cards) -> dict:
    return {lane: [c.plain_title for c in items] for lane, items in by_lane(cards).items()}


class ParseTest(unittest.TestCase):
    def test_each_state_maps_to_exactly_one_lane(self):
        wanted = {"Ready": "Next", "Next": "Next", "Active": "In progress",
                  "In progress": "In progress", "Blocked": "Waiting", "Paused": "Waiting",
                  "Waiting": "Waiting", "Decision needed": "Waiting", "Review": "Waiting",
                  "Completed": "Done", "Done": "Done", "Later": "Later", "Deferred": "Later"}
        self.assertEqual({s.lower() for s in wanted}, set(work_board.STATE_LANES))
        for state, lane in wanted.items():
            cards = parse_work(work(SAMPLE.format(state=state, action="Do the thing")))
            self.assertEqual([c.lane for c in cards], [lane], state)
            self.assertIn(lane, LANES)

    def test_bold_and_case_do_not_change_the_lane(self):
        cards = parse_work(work(SAMPLE.format(state="**ready**", action="Go")))
        self.assertEqual(cards[0].lane, "Next")

    def test_unknown_state_is_an_error_not_a_dropped_card(self):
        with self.assertRaises(WorkBoardError) as caught:
            parse_work(work(SAMPLE.format(state="Someday", action="Go")))
        self.assertIn("Someday", str(caught.exception))
        self.assertIn("Sample task", str(caught.exception))

    def test_duplicate_title_is_an_error(self):
        row = SAMPLE.format(state="Ready", action="Go")
        with self.assertRaises(WorkBoardError) as caught:
            parse_work(work(row + row))
        self.assertIn("each work item needs one row", str(caught.exception))

    def test_ready_or_active_row_needs_a_next_action(self):
        for state in ("Ready", "Active"):
            with self.assertRaises(WorkBoardError):
                parse_work(work(SAMPLE.format(state=state, action="—")))

    def test_waiting_row_needs_a_reason(self):
        with self.assertRaises(WorkBoardError) as caught:
            parse_work(work(SAMPLE.format(state="Blocked", action="")))
        self.assertIn("waiting but gives no reason", str(caught.exception))

    def test_waiting_reason_and_unblock_condition_are_separated(self):
        card = by_lane(parse_work(work(BASE_ROWS)))["Waiting"][0]
        self.assertEqual(card.reason, "First slice is not merged")
        self.assertEqual(card.unblock, "the storage contract merges")
        text = render_board([card])
        self.assertIn("**Waiting on:** First slice is not merged", text)
        self.assertIn("**Unblocks when:** the storage contract merges", text)

    def test_tables_without_a_work_column_are_not_cards(self):
        legend = "\n| WORK state | Lane |\n|---|---|\n| Ready | Next |\n"
        self.assertEqual(len(parse_work(work(BASE_ROWS) + legend)), 4)

    def test_state_table_without_a_title_column_is_an_error(self):
        with self.assertRaises(WorkBoardError):
            parse_work("| State | Owner |\n|---|---|\n| Ready | Me |\n")

    def test_escaped_pipe_and_line_break_are_safe_on_a_card(self):
        cards = parse_work(work("| Ready | A \\| B | Me | First<br>second |\n"))
        self.assertEqual(cards[0].plain_title, "A | B")
        self.assertEqual(cards[0].next_action, "First; second")

    def test_advanced_tables_formatting_keeps_links_and_states(self):
        plain = work(BASE_ROWS)
        rows = [work_board._split_row(l) for l in (HEADER + BASE_ROWS).splitlines()]
        widths = [max(len(r[i]) for r in rows) for i in range(4)]
        padded = "\n".join(
            "| " + " | ".join(("-" * w if set(c) == {"-"} else c.ljust(w))
                              for c, w in zip(r, widths)) + " |" for r in rows)
        formatted = "# Active work\n\n" + padded + "\n"
        self.assertNotEqual(plain, formatted)
        self.assertEqual([(c.title, c.lane, c.state, c.owner, c.next_action, c.reason, c.unblock)
                          for c in parse_work(plain)],
                         [(c.title, c.lane, c.state, c.owner, c.next_action, c.reason, c.unblock)
                          for c in parse_work(formatted)])
        self.assertIn("[Review gate](PR-STATUS.md)", [c.title for c in parse_work(formatted)])
        self.assertEqual(render_board(parse_work(plain)), render_board(parse_work(formatted)))

    def test_sectioned_layout_maps_sections_and_states(self):
        self.assertEqual(lane_titles(parse_work(SECTIONED)), {
            "Next": ["Native hosts"],
            "In progress": ["S0 Design"],
            "Waiting": ["Hosted AI review gate"],
            "Done": ["Decisions", "CI accepts images"],
            "Later": ["S2 Private journal"],
        })
        lanes = by_lane(parse_work(SECTIONED))
        waiting = lanes["Waiting"][0]
        self.assertEqual((waiting.reason, waiting.unblock),
                         ("It guards an app with almost no code", "S4 adds sign-in"))
        self.assertEqual(lanes["Next"][0].ref, "no PR yet")
        self.assertEqual(lanes["In progress"][0].ref, "")
        self.assertEqual(lanes["Later"][0].prompt, "[P06](../reviews/P06.md)")

    def test_sectioned_cards_show_branch_prompt_and_done_note(self):
        board = render_board(parse_work(SECTIONED))
        self.assertIn("- [ ] **Native hosts**\n\t**Next:** Run prompt [P03](../reviews/P03.md)\n"
                      "\t**Branch or PR:** no PR yet\n\t[Edit this row in WORK](WORK.md)\n", board)
        self.assertIn("- [ ] **S2 Private journal**\n\t**Prompt:** [P06](../reviews/P06.md)\n", board)
        self.assertIn("- [x] **Decisions**\n\t**Branch or PR:** branch `x`\n", board)
        done = render_board(parse_work(work(SAMPLE.format(state="Completed", action="See the ADR"))))
        self.assertIn("**Note:** See the ADR", done)
        self.assertNotIn("State in WORK", board)
        review = render_board(parse_work(work(SAMPLE.format(state="Review", action="Codex review"))))
        self.assertIn("**State in WORK:** Review", review)
        self.assertIn("- [x] **CI accepts images**\n"
                      "\t**Branch or PR:** [#54](https://example.test/54)\n", board)

    def test_sectioned_focus_names_the_branch_and_rebases_links(self):
        focus = render_focus(parse_work(SECTIONED))
        self.assertIn("> **Run prompt P04**", focus)
        self.assertIn("> Task: S0 Design · Lane: In progress", focus)
        self.assertIn("- **Next** · Native hosts (Branch or PR: no PR yet): "
                      "Run prompt [P03](reviews/P03.md)", focus)

    def test_table_under_an_unmapped_heading_without_state_is_an_error(self):
        text = "## Ideas\n\n| Work | Owner |\n|---|---|\n| Thing | Me |\n"
        with self.assertRaises(WorkBoardError) as caught:
            parse_work(text)
        self.assertIn("Ideas", str(caught.exception))


class BoardFormatTest(unittest.TestCase):
    def test_all_five_lanes_always_appear_in_order(self):
        for text in (work(""), work(BASE_ROWS)):
            board = render_board(parse_work(text))
            headings = [l[3:] for l in board.splitlines() if l.startswith("## ")]
            self.assertEqual(headings, list(LANES))

    def test_empty_board_matches_the_plugin_serialisation(self):
        self.assertEqual(render_board([]), (
            "---\n\nkanban-plugin: board\nview-of: WORK.md\n"
            "update-by: edit WORK.md then run tooling/knowledge/work_board.py --write\n"
            "\n---\n\n"
            "## Next\n\n\n\n"
            "## In progress\n\n\n\n"
            "## Waiting\n\n\n\n"
            "## Done\n\n**Complete**\n\n\n"
            "## Later\n\n\n\n"
            "\n\n%% kanban:settings\n```\n"
            '{"kanban-plugin":"board","list-collapse":[false,false,false,false,false],'
            '"show-checkboxes":false,"show-add-list":false,"show-archive-all":false}'
            "\n```\n%%"))

    def test_card_carries_title_next_action_owner_and_source_link(self):
        board = render_board(parse_work(work(SAMPLE.format(state="Ready", action="Open the PR"))))
        self.assertIn("- [ ] **[Sample task](handoffs/sample.md)**\n\t**Next:** Open the PR\n"
                      "\t**Owner:** Tester\n\t[Edit this row in WORK](WORK.md)\n", board)

    def test_done_cards_are_checked_and_others_are_not(self):
        board = render_board(parse_work(work(
            SAMPLE.format(state="Completed", action="") + "| Ready | Other | Me | Go |\n")))
        self.assertIn("**Complete**\n- [x] **[Sample task](handoffs/sample.md)**", board)
        self.assertIn("- [ ] **Other**", board)
        self.assertEqual(board.count("- [x]"), 1)

    def test_settings_footer_is_valid_json_with_one_collapse_flag_per_lane(self):
        board = render_board([])
        payload = board.split("%% kanban:settings\n```\n")[1].split("\n```\n%%")[0]
        settings = json.loads(payload)
        self.assertEqual(settings["kanban-plugin"], "board")
        self.assertEqual(len(settings["list-collapse"]), len(LANES))

    def test_no_trailing_whitespace_for_git_diff_check(self):
        for line in render_board(parse_work(work(BASE_ROWS))).splitlines():
            self.assertEqual(line, line.rstrip(), repr(line))

    def test_rendering_is_deterministic(self):
        text = work(BASE_ROWS)
        self.assertEqual(render_board(parse_work(text)), render_board(parse_work(text)))
        self.assertEqual(render_focus(parse_work(text)), render_focus(parse_work(text)))


class TransitionTest(unittest.TestCase):
    """Next -> In progress -> Waiting -> In progress -> Done, regenerating each time."""

    def test_each_transition_moves_exactly_one_card(self):
        steps = [("Ready", "Start the task", "Next"),
                 ("Active", "Finish the draft", "In progress"),
                 ("Blocked", "Review is pending. Unblocks when the maintainer answers", "Waiting"),
                 ("Active", "Apply the answer", "In progress"),
                 ("Completed", "", "Done")]
        previous = None
        for state, action, lane in steps:
            cards = parse_work(work(BASE_ROWS + SAMPLE.format(state=state, action=action)))
            titles = lane_titles(cards)
            self.assertIn("Sample task", titles[lane], state)
            everywhere = [t for items in titles.values() for t in items]
            self.assertEqual(everywhere.count("Sample task"), 1, "duplicated or lost")
            self.assertEqual(len(everywhere), 5, "a card was lost or added")
            board = render_board(cards)
            self.assertEqual(board.count("Sample task"), 1)
            if lane == "Waiting":
                self.assertIn("**Waiting on:** Review is pending", board)
                self.assertIn("**Unblocks when:** the maintainer answers", board)
            if previous is not None:
                moved = [t for l in LANES for t in set(previous[l]) ^ set(titles[l])]
                self.assertEqual(set(moved), {"Sample task"}, "another card moved")
                others = {l: [t for t in titles[l] if t != "Sample task"] for l in LANES}
                before = {l: [t for t in previous[l] if t != "Sample task"] for l in LANES}
                self.assertEqual(others, before)
            previous = titles

    def test_deferred_work_lands_in_later(self):
        cards = parse_work(work(SAMPLE.format(state="Deferred", action="Revisit after launch")))
        self.assertEqual(lane_titles(cards)["Later"], ["Sample task"])


class FocusTest(unittest.TestCase):
    def test_recommends_first_in_progress_then_next(self):
        focus = render_focus(parse_work(work(BASE_ROWS)))
        self.assertIn("> **Verify the hosted route**", focus)
        self.assertIn("Task: [Review gate](knowledge/PR-STATUS.md) · Owner: Maintainer · "
                      "Lane: In progress", focus)
        self.assertIn("- **Next** · Native hosts (Owner: Flutter builder): Open the focused PR",
                      focus)
        self.assertIn("Board now: Next 1 · In progress 1 · Waiting 1 · Done 0 · Later 1.", focus)

    def test_falls_back_to_first_next_item(self):
        focus = render_focus(parse_work(work("| Ready | Native hosts | Me | Open the PR |\n")))
        self.assertIn("> **Open the PR**", focus)
        self.assertNotIn("Also ready", focus)

    def test_shows_at_most_three_ready_or_active_items(self):
        rows = "".join(f"| Ready | Task {n} | Me | Step {n} |\n" for n in range(1, 6))
        focus = render_focus(parse_work(work(rows)))
        self.assertEqual(sum(f"Task {n}" in focus for n in range(1, 6)), 3)
        self.assertIn("2 more ready or active items", focus)

    def test_no_next_action_points_to_the_board_for_triage(self):
        focus = render_focus(parse_work(work("| Later | Firebase DEV | Me | Design rules |\n")))
        self.assertIn("Nothing is marked Next or In progress", focus)
        self.assertIn("(knowledge/WORK-BOARD-VIEW.md) to triage", focus)

    def test_links_are_rebased_from_knowledge_to_docs(self):
        rebase = work_board._rebase
        self.assertEqual(rebase("[a](PR-STATUS.md#x) [b](../architecture/SYSTEM.md) "
                                "[c](https://example.test/x) [d](#local)"),
                         "[a](knowledge/PR-STATUS.md#x) [b](architecture/SYSTEM.md) "
                         "[c](https://example.test/x) [d](#local)")

    def test_apply_focus_replaces_only_the_block_and_keeps_line_endings(self):
        focus = render_focus(parse_work(work(BASE_ROWS)))
        updated = apply_focus(HOME_PAGE, focus)
        self.assertTrue(updated.startswith("# Home\n\n<!-- work-focus:start"))
        self.assertTrue(updated.endswith("<!-- work-focus:end -->\n\n## Where to go\n"))
        self.assertNotIn("\nold\n", updated)
        self.assertEqual(apply_focus(updated, focus), updated)
        windows = apply_focus(HOME_PAGE.replace("\n", "\r\n"), focus)
        self.assertEqual(windows.replace("\r\n", "\n"), updated)
        self.assertNotIn("\n", windows.replace("\r\n", ""))

    def test_missing_markers_are_reported(self):
        with self.assertRaises(WorkBoardError):
            apply_focus("# Home\n", "x")


class StaleCheckTest(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / "docs" / "knowledge").mkdir(parents=True)
        (self.root / HOME).write_text(HOME_PAGE, encoding="utf-8")
        self.set_work(BASE_ROWS + SAMPLE.format(state="Ready", action="Start the task"))

    def set_work(self, rows: str) -> None:
        (self.root / WORK).write_bytes(work(rows).encode("utf-8"))

    def test_checkout_without_work_has_nothing_to_check(self):
        (self.root / WORK).unlink()
        self.assertEqual(problems(self.root), [])

    def test_missing_board_is_reported_then_written(self):
        self.assertTrue(any("is missing" in p for p in problems(self.root)))
        self.assertEqual(set(write(self.root)), {BOARD, HOME})
        self.assertEqual(problems(self.root), [])

    def test_second_refresh_changes_nothing(self):
        write(self.root)
        before = {p: (self.root / p).read_bytes() for p in (BOARD, HOME)}
        self.assertEqual(write(self.root), [])
        self.assertEqual(before, {p: (self.root / p).read_bytes() for p in (BOARD, HOME)})

    def test_work_change_makes_both_views_stale_until_regenerated(self):
        write(self.root)
        self.set_work(BASE_ROWS + SAMPLE.format(state="Active", action="Finish the draft"))
        stale = problems(self.root)
        self.assertEqual(len(stale), 2)
        self.assertTrue(all("out of date" in p for p in stale))
        write(self.root)
        self.assertEqual(problems(self.root), [])

    def test_moving_a_card_in_the_view_is_caught_and_does_not_touch_work(self):
        write(self.root)
        source = (self.root / WORK).read_bytes()
        board = (self.root / BOARD).read_text(encoding="utf-8")
        card = board[board.index("- [ ] **[Sample task]"):].split("\n- [", 1)[0].split("\n\n")[0]
        moved = board.replace(card + "\n", "").replace("## In progress\n\n",
                                                       "## In progress\n\n" + card + "\n")
        self.assertNotEqual(moved, board)
        (self.root / BOARD).write_text(moved, encoding="utf-8")
        self.assertTrue(any(BOARD.as_posix() in p for p in problems(self.root)))
        self.assertEqual(write(self.root), [BOARD])
        self.assertEqual((self.root / BOARD).read_text(encoding="utf-8"), board)
        self.assertEqual((self.root / WORK).read_bytes(), source)

    def test_crlf_checkout_is_not_reported_as_stale(self):
        write(self.root)
        for path in (BOARD, HOME):
            # On Windows the fixture is already written with CRLF; convert from LF either way.
            data = (self.root / path).read_bytes().replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
            (self.root / path).write_bytes(data)
        self.assertEqual(problems(self.root), [])

    def test_invalid_work_is_reported_by_the_check(self):
        self.set_work(SAMPLE.format(state="Someday", action="Go"))
        self.assertTrue(any("Someday" in p for p in problems(self.root)))

    def test_messages_are_ascii_for_windows_consoles(self):
        self.set_work("| Someday | Caf\u00e9 \u2192 launch | Me | Go |\n")
        issues = problems(self.root)
        self.assertTrue(issues)
        for issue in issues:
            issue.encode("ascii")
        self.assertTrue(any("Caf\\xe9" in issue for issue in issues))


if __name__ == "__main__":
    unittest.main()
