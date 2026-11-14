#!/usr/bin/env python3
"""Write docs/knowledge/LIVE.md: open pull requests, unpublished branches and what needs the maintainer.

Pull request and CI state change on GitHub without a commit, so a committed page
cannot stay current. This page is generated locally, is git-ignored and is never
committed. It needs the GitHub CLI (gh) signed in; without it the page says so
and still lists local branches and open decisions.

    python3 tooling/knowledge/live_status.py           # refresh the page in the main checkout
    python3 tooling/knowledge/live_status.py --pull    # fast-forward the main checkout first
    python3 tooling/knowledge/live_status.py --stdout  # print instead of writing
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PR_FIELDS = ("number,title,author,isDraft,headRefName,updatedAt,reviewDecision,statusCheckRollup,"
             "mergeable,url,files")
BOARD = "docs/knowledge/WORK.md"
FILES_LIMIT = 100  # gh lists at most this many changed files for a pull request
DECISIONS = "docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md"
FAILED = {"FAILURE", "ERROR", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED", "STARTUP_FAILURE"}
RUNNING = {"PENDING", "QUEUED", "IN_PROGRESS", "EXPECTED", "WAITING", "REQUESTED"}
# The checks the main ruleset requires. Other checks (for example the staged
# flutter-ai-review gate) are reported but never make a pull request "failing".
REQUIRED_CHECKS = {"ci-gate"}


def run(args: list[str], cwd: Path) -> tuple[int, str]:
    try:
        done = subprocess.run(args, cwd=cwd, capture_output=True, text=True, check=False, encoding="utf-8")
    except (FileNotFoundError, OSError):
        return 127, ""
    return done.returncode, done.stdout or ""


def main_worktree(root: Path) -> Path:
    """The checkout that has `main` checked out (the Obsidian vault), else this one."""
    code, out = run(["git", "worktree", "list", "--porcelain"], root)
    path = None
    for line in out.splitlines() if code == 0 else []:
        if line.startswith("worktree "):
            path = line[len("worktree "):].strip()
        elif line.strip() == "branch refs/heads/main" and path and Path(path).is_dir():
            return Path(path)
    return root


def _name(item: dict) -> str:
    # Check runs carry name; legacy commit statuses carry context.
    return str(item.get("name") or item.get("context") or "")


def _state(item: dict) -> str:
    # Check runs report status + conclusion; legacy commit statuses report state.
    return str(item.get("conclusion") or item.get("state") or item.get("status") or "").upper()


def checks_summary(rollup: list[dict] | None) -> str:
    """The headline for a pull request's checks. Only the required checks decide it.

    - "none": GitHub lists no checks at all.
    - "ci-gate not reported": checks are listed, but ci-gate is not among them.
      It is never guessed from the other checks, and it is not called running.
    - "failing" or "running": what ci-gate itself reports.
    - "passing": ci-gate concluded SUCCESS. Nothing else is passing; any other
      conclusion is shown as it is, for example "ci-gate skipped".

    Checks that are not required never change the headline. checks_cell adds
    the failed ones as a note.
    """
    items = rollup or []
    if not items:
        return "none"
    required = [(_name(item), _state(item)) for item in items if _name(item) in REQUIRED_CHECKS]
    states = [state for _, state in required]
    if any(s in FAILED for s in states):
        return "failing"
    missing = sorted(REQUIRED_CHECKS - {name for name, _ in required})
    if missing:
        return f"{', '.join(missing)} not reported"
    if any(s in RUNNING or s == "" for s in states):
        return "running"
    if all(s == "SUCCESS" for s in states):
        return "passing"
    return ", ".join(sorted({f"{name} {state.lower()}" for name, state in required if state != "SUCCESS"}))


def optional_failing(rollup: list[dict] | None) -> list[str]:
    """Names of failing checks that are not required."""
    return sorted({_name(item) for item in rollup or []
                   if _name(item) and _name(item) not in REQUIRED_CHECKS and _state(item) in FAILED})


def attention(pr: dict) -> str:
    """Why this pull request needs the maintainer now, or an empty string."""
    checks = checks_summary(pr.get("statusCheckRollup"))
    if checks == "failing":
        return "CI is failing"
    if pr.get("mergeable") == "CONFLICTING":
        return "Has merge conflicts"
    if pr.get("reviewDecision") == "CHANGES_REQUESTED":
        return "Changes requested"
    if not pr.get("isDraft") and checks == "passing":
        return "Ready for your merge decision"
    return ""


def open_decisions(vault: Path) -> list[str]:
    """IDs in the decisions table whose answer still contains TODO."""
    page = vault / DECISIONS
    if not page.is_file():
        return []
    found = []
    for line in page.read_text(encoding="utf-8").splitlines():
        match = re.match(r"\|\s*\*\*([A-Z]+[0-9]+)\*\*\s*\|", line)
        if match and "TODO" in line:
            found.append(match.group(1))
    return found


def unpublished_branches(root: Path) -> list[tuple[str, str, str, str]]:
    """Local branches holding work GitHub cannot show, with what is missing there.

    Either the branch has no upstream and has commits that are not on main
    ("the whole branch"), or it has an upstream and is ahead of it ("2 commits").
    """
    code, out = run(["git", "for-each-ref", "--sort=-committerdate", "refs/heads",
                     "--format=%(refname:short)\t%(upstream:short)\t%(upstream:track)"
                     "\t%(committerdate:short)\t%(subject)"], root)
    rows = []
    for line in out.splitlines() if code == 0 else []:
        name, upstream, track, day, subject = (line.split("\t") + [""] * 5)[:5]
        if name == "main":
            continue
        if upstream:
            ahead = re.search(r"ahead (\d+)", track)
            if ahead:
                count = int(ahead.group(1))
                rows.append((name, day, subject, f"{count} commit{'' if count == 1 else 's'}"))
            continue
        ahead_code, ahead = run(["git", "rev-list", "--count", f"main..{name}"], root)
        if ahead_code == 0 and ahead.strip().isdigit() and int(ahead.strip()) > 0:
            rows.append((name, day, subject, "the whole branch"))
    return rows[:10]


def board_cell(pr: dict) -> str:
    """Whether the pull request changes the work board, as far as GitHub's file list shows."""
    files = pr.get("files")
    if not isinstance(files, list):
        return "unknown"
    if any(isinstance(item, dict) and item.get("path") == BOARD for item in files):
        return "updated"
    return "unknown" if len(files) >= FILES_LIMIT else "not touched"


def local_edits(vault: Path) -> list[str]:
    """Tracked files changed in the vault checkout and not committed: edits made in Obsidian.

    They are invisible to GitHub and they stop the next fast-forward that touches
    the same file, so the page says so and an agent publishes them.
    """
    code, out = run(["git", "status", "--porcelain", "--untracked-files=no"], vault)
    if code != 0:
        return []
    return sorted({line[3:].split(" -> ")[-1].strip().strip('"') for line in out.splitlines() if len(line) > 3})


def edit_lines(edits: list[str]) -> list[str]:
    """What the page says about uncommitted edits in the vault checkout."""
    lines = []
    if BOARD in edits:
        lines.append("- **The work board was edited in this checkout and the edit is not in a pull request.** "
                     "An agent publishes it at the end of its next session. Until then the board view and the "
                     "\"Do this next\" block lag behind it; `python tooling/knowledge/work_board.py --write` "
                     "refreshes them here.")
    others = [path for path in edits if path != BOARD]
    if others:
        shown = ", ".join(f"`{cell(path)}`" for path in others[:6]) + (" and more" if len(others) > 6 else "")
        lines.append(f"- **{len(others)} other file{'' if len(others) == 1 else 's'} edited in this checkout "
                     f"{'is' if len(others) == 1 else 'are'} not in a pull request:** {shown}.")
    return lines


def agent_actions(edits: list[str]) -> list[str]:
    """Printed for the agent that ran this tool; AGENTS.md says what each one means."""
    actions = []
    if BOARD in edits:
        actions.append(f"ACTION: {BOARD} has an uncommitted edit in the main checkout. Publish it before you "
                       "finish: knowledge-steward skill, \"The maintainer's own edits\".")
    others = [path for path in edits if path != BOARD]
    if others:
        actions.append(f"ACTION: {len(others)} other uncommitted edit(s) in the main checkout "
                       f"({', '.join(others[:6])}). Tell the maintainer and ask whether to publish them.")
    return actions


def checks_cell(rollup: list[dict] | None) -> str:
    extra = optional_failing(rollup)
    return checks_summary(rollup) + (f" (not required, failing: {cell(', '.join(extra))})" if extra else "")


def cell(text: object) -> str:
    return str(text).replace("|", "\\|").replace("\n", " ").strip()


def render(prs: list[dict] | None, merged: list[dict] | None, branches: list[tuple[str, str, str, str]],
           decisions: list[str], now: str, edits: list[str] | None = None) -> str:
    lines = ["# Live status", "",
             f"Generated {now} by `tooling/knowledge/live_status.py`. Not committed. Refresh it; do not edit it.", ""]
    needs = [(pr, attention(pr)) for pr in prs or []]
    needs = [(pr, why) for pr, why in needs if why]
    lines += ["## Needs your attention", ""]
    if decisions:
        lines.append(f"- **{len(decisions)} product decisions are still TODO:** {', '.join(decisions)}. "
                     f"Answer them on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page.")
    for pr, why in needs:
        lines.append(f"- **[#{pr['number']}]({pr['url']}) {cell(pr['title'])}**: {why}")
    if branches:
        lines.append(f"- **{len(branches)} local branches have work that is not on GitHub.** See the table below.")
    lines += edit_lines(edits or [])
    if prs is None:
        lines.append("- **Pull requests could not be read.** Install the GitHub CLI and run `gh auth login`, then refresh.")
    if not (decisions or needs or branches or edits or prs is None):
        lines.append("- Nothing right now.")
    lines += ["", "## Open pull requests", ""]
    if prs:
        lines += ["| PR | Title | Branch | Checks | Review | Needs you | Work board |", "|---|---|---|---|---|---|---|"]
        for pr in prs:
            review = (pr.get("reviewDecision") or "none").replace("_", " ").lower()
            title = cell(pr["title"]) + (" (draft)" if pr.get("isDraft") else "")
            lines.append(f"| [#{pr['number']}]({pr['url']}) | {title} | `{cell(pr.get('headRefName', ''))}` | "
                         f"{checks_cell(pr.get('statusCheckRollup'))} | {review} | {attention(pr) or '—'} | "
                         f"{board_cell(pr)} |")
    else:
        lines.append("Unavailable." if prs is None else "None.")
    lines += ["", "## Local work not on GitHub", ""]
    if branches:
        lines += ["| Branch | Last commit | Subject | Not on GitHub |", "|---|---|---|---|"]
        lines += [f"| `{cell(name)}` | {day} | {cell(subject)} | {missing} |"
                  for name, day, subject, missing in branches]
    else:
        lines.append("None.")
    lines += ["", "## Recently merged", ""]
    if merged:
        lines += [f"- [#{pr['number']}]({pr['url']}) {cell(pr['title'])} ({str(pr.get('mergedAt', ''))[:10]})" for pr in merged]
    else:
        lines.append("Unavailable." if merged is None else "None.")
    return "\n".join(lines) + "\n"


def gh_json(args: list[str], root: Path) -> list[dict] | None:
    if shutil.which("gh") is None:
        return None
    code, out = run(["gh", *args], root)
    if code != 0:
        return None
    try:
        data = json.loads(out or "[]")
    except json.JSONDecodeError:
        return None
    return data if isinstance(data, list) else None


def pull(vault: Path) -> str:
    """Fast-forward `vault` if it has main checked out; return the reason if nothing was pulled.

    Only main is ever pulled. When no checkout has main checked out, `vault`
    is the current checkout on some other branch, and that branch is left alone.
    Otherwise Git decides whether the fast-forward is safe. Uncommitted changes
    do not stop it unless it would overwrite them, and then Git changes nothing
    and says which files are in the way.

    One case is cleared first. An edit made in the vault and then published
    through a pull request is still an uncommitted change here, and Git refuses
    to fast-forward over it even though the incoming file is identical. Such a
    file is put back to its committed state and the pull is tried once more.
    Nothing is lost: the fast-forward brings the same content. If the second try
    still fails (another file is in the way, or main has diverged), each file is
    written back exactly as it was, so the checkout is left as it was found.
    """
    code, branch = run(["git", "symbolic-ref", "--short", "-q", "HEAD"], vault)
    if code != 0 or branch.strip() != "main":
        return (f"Did not pull: {vault} is on {branch.strip() or 'no branch'}, not main. "
                "--pull only fast-forwards a checkout that has main checked out.")
    try:
        done = subprocess.run(["git", "pull", "--ff-only", "--quiet"], cwd=vault, capture_output=True,
                              text=True, check=False, encoding="utf-8", errors="replace")
    except (FileNotFoundError, OSError) as error:
        return f"Could not fast-forward {vault}: {error}"
    if done.returncode == 0:
        return ""
    restored = restore_landed_edits(vault)
    if restored:
        code, _ = run(["git", "pull", "--ff-only", "--quiet"], vault)
        if code == 0:
            return ""
        for path, content in restored.items():      # the pull still failed: undo our own change
            (vault / path).write_bytes(content)
    message = (done.stderr or done.stdout or "").strip() or f"git pull exited with {done.returncode}"
    return f"Could not fast-forward {vault}:\n{message}"


def restore_landed_edits(vault: Path) -> dict[str, bytes]:
    """Put back uncommitted edits whose content is already on the upstream branch.

    Only unstaged edits to tracked files are considered, and only when the file in
    the checkout is identical to the upstream version, so no work can be lost.
    Returns each file restored with the bytes it held, so the caller can write
    them back if the pull it was clearing the way for does not happen.
    """
    if run(["git", "fetch", "--quiet"], vault)[0] != 0:
        return {}
    code, out = run(["git", "diff", "--name-only"], vault)
    restored: dict[str, bytes] = {}
    for path in out.splitlines() if code == 0 else []:
        staged = run(["git", "diff", "--cached", "--quiet", "--", path], vault)[0] != 0
        same_as_upstream = run(["git", "diff", "--quiet", "@{upstream}", "--", path], vault)[0] == 0
        if staged or not same_as_upstream:
            continue
        try:
            content = (vault / path).read_bytes()
        except OSError:
            continue
        if run(["git", "checkout", "--", path], vault)[0] == 0:
            restored[path] = content
    return restored


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--pull", action="store_true",
                        help="fast-forward the checkout that has main checked out first "
                             "(git pull --ff-only); says why if nothing was pulled")
    parser.add_argument("--stdout", action="store_true", help="print the page instead of writing it")
    args = parser.parse_args()
    vault = main_worktree(ROOT)
    if args.pull:
        problem = pull(vault)
        if problem:
            print(problem)
    prs = gh_json(["pr", "list", "--state", "open", "--limit", "50", "--json", PR_FIELDS], ROOT)
    merged = gh_json(["pr", "list", "--state", "merged", "--limit", "8", "--json", "number,title,mergedAt,url"], ROOT)
    edits = local_edits(vault)
    page = render(prs, merged, unpublished_branches(ROOT), open_decisions(vault),
                  datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z"), edits)
    for action in agent_actions(edits):
        print(action)
    if args.stdout:
        print(page, end="")
        return 0
    target = vault / "docs" / "knowledge" / "LIVE.md"
    target.write_text(page, encoding="utf-8", newline="\n")
    print(f"Wrote {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
