#!/usr/bin/env python3
"""Generate the read-only work views from docs/knowledge/WORK.md.

WORK.md is the only place a task's state, owner and next action are edited.
This tool derives two views from it and can prove they are current:

* docs/knowledge/WORK-BOARD-VIEW.md, a board in the Markdown format the
  Obsidian Kanban community plugin saves (five fixed lanes, one card per row);
* the "work-focus" block at the top of docs/HOME.md (one recommended action
  and a short list of ready or active work).

    python tooling/knowledge/work_board.py            # check (default), exit 1 when stale
    python tooling/knowledge/work_board.py --write    # regenerate both views

Moving a card in Obsidian does not change WORK.md. Edit the row, then --write.
No dependencies beyond the standard library.
"""
from __future__ import annotations

import argparse
import json
import posixpath
import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = Path("docs/knowledge/WORK.md")
BOARD = Path("docs/knowledge/WORK-BOARD-VIEW.md")
HOME = Path("docs/HOME.md")
COMMAND = "python tooling/knowledge/work_board.py --write"

LANES = ("Next", "In progress", "Waiting", "Done", "Later")

# Every state a WORK row may carry maps to exactly one lane. An unknown state is
# an error, never a silently dropped card.
STATE_LANES = {
    "ready": "Next",
    "next": "Next",
    "active": "In progress",
    "in progress": "In progress",
    "blocked": "Waiting",
    "paused": "Waiting",
    "waiting": "Waiting",
    "decision needed": "Waiting",
    "review": "Waiting",
    "completed": "Done",
    "done": "Done",
    "later": "Later",
    "deferred": "Later",
}
# A table without a State column takes its lane from the heading it sits under.
SECTION_LANES = {
    "next": "Next",
    "in progress": "In progress",
    "paused": "Waiting",
    "waiting": "Waiting",
    "blocked": "Waiting",
    "done": "Done",
    "completed": "Done",
    "later": "Later",
    "deferred": "Later",
}

TITLE_COLUMNS = ("work", "step", "task")
STATE_COLUMNS = ("state", "status")
OWNER_COLUMNS = ("owner",)
NEXT_COLUMNS = ("blocker / next action", "next action", "next")
PROMPT_COLUMNS = ("prompt",)
REF_COLUMNS = ("branch or pr", "branch", "pr")
REASON_COLUMNS = ("why", "blocker", "waiting on")
UNBLOCK_COLUMNS = ("resume when", "unblocks when")

EMPTY_CELLS = {"", "-", "–", "—", "none", "n/a"}
SEPARATOR = re.compile(r"^:?-+:?$")
HEADING = re.compile(r"^#{1,6}\s+(.*?)\s*#*$")
UNBLOCKS = re.compile(r"^(.*?)[.;]?\s+unblocks when:?\s+(.*)$", re.IGNORECASE)
LINK_TARGET = re.compile(r"\]\(([^)\s]+)\)")
INLINE_LINK = re.compile(r"\[([^\]]*)\]\([^)]*\)")

FOCUS_START = "<!-- work-focus:start"
FOCUS_END = "<!-- work-focus:end -->"
FOCUS_OPEN = (f"{FOCUS_START} (generated from knowledge/WORK.md; edit that table, "
              f"then run: {COMMAND}) -->")

# The settings footer is written exactly as the plugin serialises it, so opening
# and saving the board in Obsidian without moving anything leaves the file unchanged.
KANBAN_SETTINGS = {
    "kanban-plugin": "board",
    "list-collapse": [False] * len(LANES),
    "show-checkboxes": False,
    "show-add-list": False,
    "show-archive-all": False,
}


class WorkBoardError(ValueError):
    """WORK.md cannot be turned into a board without guessing."""


@dataclass(frozen=True)
class Card:
    title: str        # Markdown from the row's title cell, relative to docs/knowledge
    plain_title: str  # the same without link or emphasis syntax
    lane: str
    state: str        # the state exactly as WORK.md words it, or the section heading
    owner: str
    ref: str          # branch or pull request, when the table has that column
    next_action: str
    prompt: str
    reason: str
    unblock: str
    line: int


def _split_row(line: str) -> list[str]:
    cells = re.split(r"(?<!\\)\|", line.strip())
    if cells and not cells[0].strip():
        cells = cells[1:]
    if cells and not cells[-1].strip():
        cells = cells[:-1]
    return [cell.strip() for cell in cells]


def _clean(cell: str) -> str:
    """Cell text as it should read outside a table."""
    text = cell.replace("\\|", "|")
    text = re.sub(r"<br\s*/?>", "; ", text, flags=re.IGNORECASE)
    return re.sub(r"\s+", " ", text).strip()


def _unbold(text: str) -> str:
    match = re.fullmatch(r"(\*\*|__)(.+)\1", text)
    return match.group(2).strip() if match else text


def _plain(text: str) -> str:
    text = INLINE_LINK.sub(r"\1", text)
    return re.sub(r"[*_`]", "", text).strip()


def _value(cell: str) -> str:
    text = _clean(cell)
    return "" if _unbold(text).lower() in EMPTY_CELLS else text


def _column(header: list[str], names: tuple[str, ...]) -> int | None:
    for name in names:
        if name in header:
            return header.index(name)
    return None


def parse_work(text: str) -> list[Card]:
    """Cards in WORK.md row order. Raises WorkBoardError listing every problem."""
    lines = text.replace("\r\n", "\n").split("\n")
    cards: list[Card] = []
    problems: list[str] = []
    section = ""
    index = 0
    while index < len(lines):
        line = lines[index]
        heading = HEADING.match(line)
        if heading:
            section = _plain(heading.group(1))
            index += 1
            continue
        is_table = (line.lstrip().startswith("|") and index + 1 < len(lines)
                    and lines[index + 1].lstrip().startswith("|")
                    and all(SEPARATOR.match(c) for c in _split_row(lines[index + 1]))
                    and _split_row(lines[index + 1]))
        if not is_table:
            index += 1
            continue
        header = [_plain(_clean(cell)).lower() for cell in _split_row(line)]
        title_at = _column(header, TITLE_COLUMNS)
        state_at = _column(header, STATE_COLUMNS)
        owner_at = _column(header, OWNER_COLUMNS)
        next_at = _column(header, NEXT_COLUMNS)
        prompt_at = _column(header, PROMPT_COLUMNS)
        ref_at = _column(header, REF_COLUMNS)
        reason_at = _column(header, REASON_COLUMNS)
        unblock_at = _column(header, UNBLOCK_COLUMNS)
        index += 2
        if title_at is None:
            if state_at is not None:
                problems.append(f"line {index - 1}: table has a State column but no Work, Step or "
                                f"Task column, so its rows cannot become cards")
            while index < len(lines) and lines[index].lstrip().startswith("|"):
                index += 1
            continue
        while index < len(lines) and lines[index].lstrip().startswith("|"):
            number = index + 1
            cells = _split_row(lines[index])
            index += 1

            def cell(at: int | None) -> str:
                return _value(cells[at]) if at is not None and at < len(cells) else ""

            title = _unbold(cell(title_at))
            plain_title = _plain(title)
            if not plain_title:
                problems.append(f"line {number}: row has no task title")
                continue
            if state_at is not None:
                state = _plain(cell(state_at))
                lane = STATE_LANES.get(state.lower())
                if lane is None:
                    problems.append(
                        f"line {number}: state '{state or '(empty)'}' of '{plain_title}' has no "
                        f"lane; use one of {', '.join(sorted(s.title() for s in STATE_LANES))}")
                    continue
            else:
                state = section
                lane = SECTION_LANES.get(section.lower())
                if lane is None:
                    problems.append(
                        f"line {number}: '{plain_title}' has no State column and sits under "
                        f"'{section or '(no heading)'}', which is not a lane section "
                        f"({', '.join(sorted(s.title() for s in SECTION_LANES))})")
                    continue
            next_action = cell(next_at)
            reason = cell(reason_at)
            unblock = cell(unblock_at)
            if lane == "Waiting":
                if not reason:
                    reason, next_action = next_action, ""
                split = UNBLOCKS.match(reason)
                if split and not unblock:
                    reason, unblock = split.group(1).strip(), split.group(2).strip()
                if not reason:
                    problems.append(f"line {number}: '{plain_title}' is waiting but gives no "
                                    f"reason; say what it waits on and what would unblock it")
                    continue
            elif lane in ("Next", "In progress") and not next_action:
                problems.append(f"line {number}: '{plain_title}' is {state} but has no concrete "
                                f"next action")
                continue
            cards.append(Card(title, plain_title, lane, state, cell(owner_at), cell(ref_at),
                              next_action, cell(prompt_at), reason, unblock, number))
    seen: dict[str, int] = {}
    for card in cards:
        key = card.plain_title.lower()
        if key in seen:
            problems.append(f"line {card.line}: '{card.plain_title}' is also on line {seen[key]}; "
                            f"each work item needs one row")
        seen.setdefault(key, card.line)
    if problems:
        raise WorkBoardError("\n".join(problems))
    return cards


def by_lane(cards: list[Card]) -> dict[str, list[Card]]:
    lanes: dict[str, list[Card]] = {lane: [] for lane in LANES}
    for card in cards:
        lanes[card.lane].append(card)
    return lanes


def _card_lines(card: Card) -> list[str]:
    lines = [f"**{card.title}**"]
    if card.lane == "Waiting":
        lines.append(f"**Waiting on:** {card.reason}")
        if card.unblock:
            lines.append(f"**Unblocks when:** {card.unblock}")
    if card.next_action:
        lines.append(f"**{'Note' if card.lane == 'Done' else 'Next'}:** {card.next_action}")
    if card.prompt:
        lines.append(f"**Prompt:** {card.prompt}")
    if card.owner:
        lines.append(f"**Owner:** {card.owner}")
    if card.ref:
        lines.append(f"**Branch or PR:** {card.ref}")
    if card.lane == "Waiting" and card.state.lower() in ("decision needed", "review"):
        lines.append(f"**State in WORK:** {card.state}")
    lines.append("[Edit this row in WORK](WORK.md)")
    return lines


def render_board(cards: list[Card]) -> str:
    """The board exactly as obsidian-kanban 2.0.51 writes one (see OBSIDIAN-SETUP.md)."""
    out = ["---", "", "kanban-plugin: board", "view-of: WORK.md",
           "update-by: edit WORK.md then run tooling/knowledge/work_board.py --write", "", "---", ""]
    for lane, lane_cards in by_lane(cards).items():
        out += [f"## {lane}", ""]
        if lane == "Done":
            out.append("**Complete**")
        mark = "x" if lane == "Done" else " "
        for card in lane_cards:
            out.append(f"- [{mark}] " + "\n\t".join(_card_lines(card)))
        out += ["", ""]
    out += ["", "", "%% kanban:settings", "```",
            json.dumps(KANBAN_SETTINGS, separators=(",", ":")), "```", "%%"]
    return "\n".join(out)


def _rebase(markdown: str, folder: str = "knowledge") -> str:
    """Rewrite links that are relative to docs/knowledge so they work from docs/."""
    def target(match: re.Match[str]) -> str:
        raw = match.group(1)
        if raw.startswith(("https://", "http://", "mailto:", "#", "/")):
            return match.group(0)
        path, _, anchor = raw.partition("#")
        path = posixpath.normpath(posixpath.join(folder, path))
        return f"]({path}{'#' + anchor if anchor else ''})"
    return LINK_TARGET.sub(target, markdown)


def _who(card: Card) -> list[str]:
    """Who has the task and where the work is, as far as the row says."""
    parts = []
    if card.owner:
        parts.append(f"Owner: {card.owner}")
    if card.ref:
        parts.append(f"Branch or PR: {_rebase(card.ref)}")
    return parts


def render_focus(cards: list[Card]) -> str:
    """The generated block for HOME: one action, a short list, the lane counts."""
    lanes = by_lane(cards)
    ready = lanes["In progress"] + lanes["Next"]
    board = "knowledge/WORK-BOARD-VIEW.md"
    out = [FOCUS_OPEN, "## Do this next", ""]
    if ready:
        first = ready[0]
        facts = [f"Task: {_rebase(first.title)}", *_who(first), f"Lane: {first.lane}"]
        out += [f"> **{_rebase(first.next_action)}**", ">", "> " + " · ".join(facts), ""]
        others = ready[1:3]
        if others:
            out += ["## Also ready or in progress", ""]
            for card in others:
                who = f" ({'; '.join(_who(card))})" if _who(card) else ""
                out.append(f"- **{card.lane}** · {_rebase(card.title)}{who}: "
                           f"{_rebase(card.next_action)}")
            out.append("")
        more = len(ready) - 1 - len(others)
        if more > 0:
            out += [f"{more} more ready or active item{'s' if more != 1 else ''} on the "
                    f"[Work board]({board}).", ""]
    else:
        out += [f"Nothing is marked Next or In progress. Open the [Work board]({board}) to "
                f"triage: pick a Later or Waiting item and change its state in "
                f"[WORK](knowledge/WORK.md).", ""]
    counts = " · ".join(f"{lane} {len(lanes[lane])}" for lane in LANES)
    out += [f"Board now: {counts}.", FOCUS_END]
    return "\n".join(out)


def apply_focus(home: str, focus: str) -> str:
    """HOME with its generated block replaced. HOME keeps its own line endings."""
    newline = "\r\n" if "\r\n" in home else "\n"
    text = home.replace("\r\n", "\n")
    start = text.find(FOCUS_START)
    end = text.find(FOCUS_END)
    if start < 0 or end < start:
        raise WorkBoardError(f"{HOME.as_posix()} has no work-focus block; restore the "
                             f"'{FOCUS_START} ... {FOCUS_END}' markers")
    text = text[:start] + focus + text[end + len(FOCUS_END):]
    return text.replace("\n", newline)


def _read(path: Path) -> str | None:
    return path.read_bytes().decode("utf-8") if path.is_file() else None


def _console(text: str) -> str:
    """Messages quote task titles; keep them printable on a non-UTF-8 Windows console."""
    return text.encode("ascii", "backslashreplace").decode("ascii")


def expected(root: Path) -> dict[Path, str]:
    """What each generated file should contain for the WORK.md in this checkout."""
    work = _read(root / WORK)
    if work is None:
        raise WorkBoardError(f"{WORK.as_posix()} is missing")
    cards = parse_work(work)
    result = {BOARD: render_board(cards)}
    home = _read(root / HOME)
    if home is not None:
        result[HOME] = apply_focus(home, render_focus(cards))
    return result


def problems(root: Path) -> list[str]:
    """Reasons the generated views are not current; empty when they are.

    A checkout without WORK.md has no board to check. Line endings are ignored
    because Windows checkouts may hold CRLF copies of the same content.
    """
    if not (root / WORK).is_file():
        return []
    try:
        wanted = expected(root)
    except WorkBoardError as error:
        return [_console(f"{WORK.as_posix()}: {line}") for line in str(error).splitlines()]
    issues = []
    for path, content in wanted.items():
        current = _read(root / path)
        if current is None:
            issues.append(f"{path.as_posix()} is missing; run {COMMAND}")
        elif current.replace("\r\n", "\n") != content.replace("\r\n", "\n"):
            issues.append(f"{path.as_posix()} is out of date with {WORK.as_posix()} (or was "
                          f"edited by hand or by moving a card); run {COMMAND}. If this branch "
                          f"does not have that tool yet, merge origin/main into it first")
    return issues


def write(root: Path) -> list[Path]:
    """Regenerate the views; returns the files whose content changed."""
    changed = []
    for path, content in expected(root).items():
        if _read(root / path) != content:
            (root / path).write_bytes(content.encode("utf-8"))
            changed.append(path)
    return changed


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--write", action="store_true", help="regenerate the board and HOME block")
    mode.add_argument("--check", action="store_true", help="fail when a view is stale (default)")
    args = parser.parse_args(argv)
    if args.write:
        try:
            changed = write(ROOT)
        except WorkBoardError as error:
            for line in str(error).splitlines():
                print("ERROR: " + _console(line))
            return 2
        for path in changed:
            print(f"Updated {path.as_posix()}")
        if not changed:
            print("Work views already match WORK.md.")
        return 0
    issues = problems(ROOT)
    for issue in issues:
        print("ERROR: " + issue)
    if not issues:
        print("Work board view and HOME focus block match WORK.md.")
    return int(bool(issues))


if __name__ == "__main__":
    sys.exit(main())
