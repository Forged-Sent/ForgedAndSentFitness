#!/usr/bin/env python3
"""Generate the prototype's embedded program and challenge data from seed/.

Decision L11: `seed/` is the single source for program and challenge content.
`index.html` carries a copy of it as JavaScript variables. This tool writes
that copy, and checks that it is current.

    python3 tooling/prototype/embed_seed.py --check    # exit 1 if index.html is stale
    python3 tooling/prototype/embed_seed.py --write    # rewrite the embedded copy

Edit the JSON under `seed/`, then run `--write`. Never edit the embedded copy
by hand: `--check` runs in CI and fails when the two differ.

The copy is not always the seed value as written. Three shapes differ, each on
purpose, and each is a function below:

- `strip_effort`: seed keeps the RPE/RIR guidance in every set prescription.
  The prototype has shown prescriptions without it since v76, and the
  maintainer chose to keep it that way (2026-11-19).
- `movement_for_prototype`: seed stores a movement's video as an object with a
  URL, a channel and a view count. The prototype stores the YouTube id and the
  channel.
- `camp_rows` and friends: seed names its fields; the prototype reads
  positional arrays.

What is not here, also on purpose: scoring numbers that exist only in the
prototype's code (`PR_PTS`, the step goals and the step bonus). They are
preview rules, not content, and stay in the prototype until the official rule
set is decided. Devotionals, daily boxes and lifts are outside L11.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[2]
SEED = ROOT / "seed"
INDEX = ROOT / "index.html"

_EFFORT = r"(?:RPE|RIR) \d+(?:\.\d+)?(?:-\d+(?:\.\d+)?)?"
_EFFORT_ALONE = re.compile(r" \(" + _EFFORT + r"\)")
# Only straight after the opening bracket of a prescription. A sentence such
# as "If you reach RPE 7, rest." is not a prescription and keeps its words.
_EFFORT_FIRST = re.compile(r"(?<=\()" + _EFFORT + r", ")
_YOUTUBE = re.compile(r"https://www\.youtube\.com/watch\?v=([\w-]{11})")


class EmbedError(Exception):
    """A seed file or index.html is not in the shape this tool can embed."""


def load_seed(name: str, seed: Path = SEED) -> Any:
    try:
        return json.loads((seed / name).read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise EmbedError(f"seed/{name} is missing") from error
    except json.JSONDecodeError as error:
        raise EmbedError(f"seed/{name} is not valid JSON: {error}") from error


def strip_effort(value: Any) -> Any:
    """Remove RPE/RIR guidance from every string in a workout library.

    "3 x 5 (RPE 7, rest 2 min)" becomes "3 x 5 (rest 2 min)";
    "3 x 12 (RIR 3). Go straight to A2" becomes "3 x 12. Go straight to A2".
    Effort that is not inside a prescription's brackets is left as written.
    """
    if isinstance(value, str):
        return _EFFORT_FIRST.sub("", _EFFORT_ALONE.sub("", value))
    if isinstance(value, list):
        return [strip_effort(item) for item in value]
    if isinstance(value, dict):
        return {key: strip_effort(item) for key, item in value.items()}
    return value


def movement_for_prototype(name: str, movement: dict[str, Any]) -> dict[str, Any]:
    """Seed's `video` object becomes the prototype's `vid` and `vch`."""
    out = {key: item for key, item in movement.items() if key != "video"}
    video = movement.get("video")
    if video is None:
        return out
    # A string, a list or a number here is a mistake in the seed file. Say
    # so by name, as for a wrong url, rather than failing on `.get`.
    match = _YOUTUBE.fullmatch(str(video.get("url", ""))) if isinstance(video, dict) else None
    if not match or not isinstance(video.get("channel"), str):
        raise EmbedError(
            f"seed/movements.json: {name!r} needs a video with a "
            "https://www.youtube.com/watch?v=<id> url and a channel"
        )
    out["vid"] = match.group(1)
    out["vch"] = video["channel"]
    return out


def plan(seed: Path = SEED) -> dict[str, Any]:
    movements = load_seed("movements.json", seed)
    return {
        "W": strip_effort(load_seed("workouts.json", seed)),
        "M": {name: movement_for_prototype(name, item) for name, item in movements.items()},
        "T": load_seed("workout-themes.json", seed),
        "META": load_seed("workout-meta.json", seed),
    }


def camp_rows(seed: Path = SEED) -> list[list[str]]:
    return [[camp["name"], camp["reference"]] for camp in load_seed("camps.json", seed)["names"]]


def banner_rows(seed: Path = SEED) -> list[list[str]]:
    return [
        [banner["id"], banner["label"], banner["color"]]
        for banner in load_seed("camps.json", seed)["banners"]
    ]


def script_safe(text: str) -> str:
    """Keep seed text from ending the <script> it is embedded in.

    The copy sits inside an inline script, where the browser's HTML parser
    looks for "</script" and "<!--" before JavaScript ever sees the string.
    Writing every "<" as its escape leaves the value unchanged and gives the
    HTML parser nothing to find.
    """
    return text.replace("<", "\\u003c")


def compact(value: Any) -> str:
    return script_safe(json.dumps(value, separators=(",", ":"), ensure_ascii=True))


def spaced(value: Any) -> str:
    return script_safe(json.dumps(value, ensure_ascii=False))


def prayer_literal(lines: Any) -> str:
    if not isinstance(lines, list) or not lines or not all(isinstance(line, str) for line in lines):
        raise EmbedError("seed/workout-prayer.json must be a list of lines")
    body = ",\n".join("    " + script_safe(json.dumps(line, ensure_ascii=True)) for line in lines)
    return "[\n" + body + "]"


def whole_numbers(value: Any, what: str) -> list[int]:
    """A flat list of whole numbers, or an error that names [what].

    The two routine constants are found again in index.html by their
    brackets: RT_WEEKS up to its first "]", RT_PATTERN up to its first "}".
    A list or an object inside one of them would be written and then not
    found on the next run, so anything but plain numbers is refused here,
    before a line is written.
    """
    if not isinstance(value, list) or not all(type(item) is int and item >= 0 for item in value):
        raise EmbedError(f"seed/routines.json: {what} must be a list of whole numbers such as [1, 4]")
    return value


def weeks_literal(weeks: Any) -> str:
    return spaced(whole_numbers(weeks, "weeks"))


def pattern_literal(days: Any) -> str:
    # Written as bare JavaScript keys, so only plain decimal numbers: "01"
    # would become the key 1, and other digit characters are not numbers there.
    if not isinstance(days, dict) or not all(re.fullmatch(r"0|[1-9][0-9]*", key) for key in days):
        raise EmbedError("seed/routines.json: trainingDays keys must be whole numbers such as 1 or 12")
    return (
        "{ "
        + ", ".join(f"{key}: {spaced(whole_numbers(item, f'trainingDays[{key}]'))}" for key, item in days.items())
        + " }"
    )


@dataclass(frozen=True)
class Embed:
    """One span of index.html that is generated from seed."""

    name: str
    source: str
    span: re.Pattern[str]
    render: Callable[[Path], str]


def _line(name: str) -> re.Pattern[str]:
    return re.compile(rf"^  var {name} = .*;$", re.MULTILINE)


EMBEDS: tuple[Embed, ...] = (
    Embed(
        "CHAL",
        "weekly-challenges.json",
        _line("CHAL"),
        lambda seed: f"  var CHAL = {compact(load_seed('weekly-challenges.json', seed))};",
    ),
    Embed(
        "STANDARDS",
        "movement-standards.json",
        _line("STANDARDS"),
        lambda seed: f"  var STANDARDS = {compact(load_seed('movement-standards.json', seed))};",
    ),
    Embed(
        "JUNIOR",
        "junior-challenges.json",
        _line("JUNIOR"),
        lambda seed: f"  var JUNIOR = {spaced(load_seed('junior-challenges.json', seed))};",
    ),
    Embed(
        "PLAN",
        "workouts.json, movements.json, workout-themes.json, workout-meta.json",
        _line("PLAN"),
        lambda seed: f"  var PLAN = {compact(plan(seed))};",
    ),
    Embed(
        "ALT",
        "alternates.json",
        _line("ALT"),
        lambda seed: f"  var ALT = {compact(load_seed('alternates.json', seed))};",
    ),
    Embed(
        "PLAN_INFO",
        "workout-programs.json",
        _line("PLAN_INFO"),
        lambda seed: f"  var PLAN_INFO = {compact(load_seed('workout-programs.json', seed))};",
    ),
    Embed(
        "CH_MODES",
        "challenge-modes.json",
        _line("CH_MODES"),
        lambda seed: f"  var CH_MODES = {spaced(load_seed('challenge-modes.json', seed))};",
    ),
    Embed(
        "CAMP_NAMES",
        "camps.json",
        _line("CAMP_NAMES"),
        lambda seed: f"  var CAMP_NAMES = {spaced(camp_rows(seed))};",
    ),
    Embed(
        "CAMP_BANNERS",
        "camps.json",
        _line("CAMP_BANNERS"),
        lambda seed: f"  var CAMP_BANNERS = {spaced(banner_rows(seed))};",
    ),
    Embed(
        "WORKOUT_PRAYER",
        "workout-prayer.json",
        re.compile(r"^  var WORKOUT_PRAYER = \[\n(?:    .*\n)*?    .*\];$", re.MULTILINE),
        lambda seed: f"  var WORKOUT_PRAYER = {prayer_literal(load_seed('workout-prayer.json', seed))};",
    ),
    Embed(
        "RT_WEEKS",
        "routines.json",
        re.compile(r"^  var RT_WEEKS = \[[^\]\n]*\](?=, RT_DOWS = )", re.MULTILINE),
        lambda seed: f"  var RT_WEEKS = {weeks_literal(load_seed('routines.json', seed)['weeks'])}",
    ),
    Embed(
        "RT_PATTERN",
        "routines.json",
        re.compile(r"^  var RT_PATTERN = \{[^}\n]*\};$", re.MULTILINE),
        lambda seed: f"  var RT_PATTERN = {pattern_literal(load_seed('routines.json', seed)['trainingDays'])};",
    ),
)


def regenerate(html: str, seed: Path = SEED) -> tuple[str, list[str]]:
    """Return index.html with every embed rewritten, and the names that changed."""
    stale: list[str] = []
    for embed in EMBEDS:
        found = embed.span.findall(html)
        if len(found) != 1:
            raise EmbedError(
                f"index.html: expected exactly one `var {embed.name} = ...`, found {len(found)}"
            )
        try:
            fresh = embed.render(seed)
        except (KeyError, TypeError) as error:
            raise EmbedError(f"seed/{embed.source}: unexpected shape ({error!r})") from error
        if "\n" in fresh and embed.name != "WORKOUT_PRAYER":
            raise EmbedError(f"{embed.name}: generated text spans more than one line")
        if fresh != found[0]:
            stale.append(embed.name)
            html = embed.span.sub(lambda _match, text=fresh: text, html, count=1)
    return html, stale


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="fail if index.html is stale (default)")
    mode.add_argument("--write", action="store_true", help="rewrite the embedded copy in index.html")
    args = parser.parse_args(argv)

    try:
        html = INDEX.read_text(encoding="utf-8")
        fresh, stale = regenerate(html)
    except EmbedError as error:
        print(f"embed_seed: {error}", file=sys.stderr)
        return 2

    if not stale:
        print(f"index.html matches seed/ for all {len(EMBEDS)} embedded data sets.")
        return 0
    sources = {embed.name: embed.source for embed in EMBEDS}
    if args.write:
        INDEX.write_text(fresh, encoding="utf-8")
        for name in stale:
            print(f"Rewrote {name} in index.html from seed/{sources[name]}")
        return 0
    for name in stale:
        print(f"STALE: {name} in index.html differs from seed/{sources[name]}", file=sys.stderr)
    print(
        "Edit seed/, then run: python3 tooling/prototype/embed_seed.py --write",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
