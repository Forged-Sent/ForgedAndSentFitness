import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import embed_seed  # noqa: E402

# Seed files that decision L11 does not cover. Anything else under seed/ must
# be the source of an embed, so a new program or challenge file cannot be
# added without the prototype's copy being generated from it.
OUTSIDE_L11 = {
    "db-rules.json",
    "devotionals-2026-10-30.json",
    "devotionals.json",
    "esv-verses.json",
    "lifts.json",
    "tasks.json",
}


def embedded_sources() -> set[str]:
    names: set[str] = set()
    for embed in embed_seed.EMBEDS:
        names.update(part.strip() for part in embed.source.split(","))
    return names


class StripEffortTest(unittest.TestCase):
    def test_effort_first_in_brackets_is_removed(self):
        self.assertEqual(embed_seed.strip_effort("3 x 5 (RPE 7, rest 2 min)"), "3 x 5 (rest 2 min)")
        self.assertEqual(embed_seed.strip_effort("3 x 8 (RIR 2, rest 90 sec)"), "3 x 8 (rest 90 sec)")
        self.assertEqual(embed_seed.strip_effort("4 x 6 (RPE 7-8, rest 2 min)"), "4 x 6 (rest 2 min)")
        self.assertEqual(embed_seed.strip_effort("4 x 6 (RIR 2-3, rest 2 min)"), "4 x 6 (rest 2 min)")
        self.assertEqual(embed_seed.strip_effort("5 x 3 (RPE 7.5, rest 3 min)"), "5 x 3 (rest 3 min)")

    def test_effort_alone_in_brackets_takes_the_brackets_with_it(self):
        self.assertEqual(
            embed_seed.strip_effort("Superset A1: 3 x 12 (RIR 3). Go straight to A2"),
            "Superset A1: 3 x 12. Go straight to A2",
        )
        self.assertEqual(embed_seed.strip_effort("3 x 10 (RIR 2-3)"), "3 x 10")

    def test_other_text_is_untouched(self):
        for text in ("3 x 5 (rest 2 min)", "Keep every set at RPE 7 or below.", "", "RIR"):
            self.assertEqual(embed_seed.strip_effort(text), text)

    def test_effort_in_a_sentence_keeps_its_words(self):
        # Only effort straight after a prescription's opening bracket goes.
        for text in (
            "If you reach RPE 7, rest.",
            "Stop at RIR 2, then rest 90 sec.",
            "Work up to RPE 7-8, then hold that weight.",
            "3 x 5 (rest 2 min). At RPE 9, stop.",
        ):
            self.assertEqual(embed_seed.strip_effort(text), text)
        self.assertEqual(
            embed_seed.strip_effort("3 x 5 (RPE 7, rest 2 min). At RPE 9, stop."),
            "3 x 5 (rest 2 min). At RPE 9, stop.",
        )

    def test_every_string_in_a_library_is_stripped_and_nothing_else_changes(self):
        library = {"Forged": [{"day": 1, "sets": [["Squat", "3 x 5 (RPE 7, rest 2 min)"]], "ok": True, "x": None}]}
        self.assertEqual(
            embed_seed.strip_effort(library),
            {"Forged": [{"day": 1, "sets": [["Squat", "3 x 5 (rest 2 min)"]], "ok": True, "x": None}]},
        )


class MovementTest(unittest.TestCase):
    def test_video_object_becomes_id_and_channel_after_the_other_fields(self):
        movement = {
            "pattern": "Squat",
            "cue": "Brace.",
            "video": {"url": "https://www.youtube.com/watch?v=irA7MTz96ho", "channel": "Kelly Matthews", "views": 430781},
            "howTo": "Setup.",
        }
        out = embed_seed.movement_for_prototype("Back Squat", movement)
        self.assertEqual(
            list(out.items()),
            [("pattern", "Squat"), ("cue", "Brace."), ("howTo", "Setup."), ("vid", "irA7MTz96ho"), ("vch", "Kelly Matthews")],
        )

    def test_a_movement_without_a_video_has_neither_field(self):
        self.assertEqual(embed_seed.movement_for_prototype("Rest Day", {"pattern": "Rest"}), {"pattern": "Rest"})
        self.assertEqual(
            embed_seed.movement_for_prototype("Rest Day", {"pattern": "Rest", "video": None}), {"pattern": "Rest"}
        )

    def test_a_video_that_is_not_a_plain_youtube_watch_url_is_an_error(self):
        for video in (
            {"url": "https://youtu.be/irA7MTz96ho", "channel": "A"},
            {"url": "https://www.youtube.com/watch?v=irA7MTz96ho&t=3", "channel": "A"},
            {"url": "https://www.youtube.com/watch?v=irA7MTz96ho"},
            {},
        ):
            with self.assertRaises(embed_seed.EmbedError):
                embed_seed.movement_for_prototype("Back Squat", {"video": video})

    def test_a_video_that_is_not_an_object_is_an_error_that_names_the_movement(self):
        for video in ("https://www.youtube.com/watch?v=irA7MTz96ho", "irA7MTz96ho", ["a"], 7, True):
            with self.assertRaisesRegex(embed_seed.EmbedError, "'Back Squat' needs a video", msg=repr(video)):
                embed_seed.movement_for_prototype("Back Squat", {"video": video})


class LiteralTest(unittest.TestCase):
    def test_pattern_is_written_with_bare_number_keys(self):
        self.assertEqual(embed_seed.pattern_literal({"1": [1], "2": [1, 4]}), "{ 1: [1], 2: [1, 4] }")
        for key in ("one", "01", "\u00b2", "1.5", "-1", ""):
            with self.assertRaises(embed_seed.EmbedError, msg=key):
                embed_seed.pattern_literal({key: [1]})
        with self.assertRaises(embed_seed.EmbedError):
            embed_seed.pattern_literal([[1]])

    def test_routine_values_must_be_flat_lists_of_whole_numbers(self):
        # Anything else would be written and then not found on the next run.
        for wrong in ({"a": 1}, [{"a": 1}], [[1, 2]], ["1"], [1.5], [True], [-1], "1", 1, None):
            with self.assertRaisesRegex(embed_seed.EmbedError, r"trainingDays\[3\]", msg=repr(wrong)):
                embed_seed.pattern_literal({"1": [1], "3": wrong})
            with self.assertRaisesRegex(embed_seed.EmbedError, "weeks", msg=repr(wrong)):
                embed_seed.weeks_literal(wrong)
        self.assertEqual(embed_seed.weeks_literal([4, 6, 8, 12]), "[4, 6, 8, 12]")
        self.assertEqual(embed_seed.pattern_literal({"1": []}), "{ 1: [] }")

    def test_prayer_is_one_escaped_line_per_paragraph(self):
        self.assertEqual(
            embed_seed.prayer_literal(["I’m Yours.", "Amen."]),
            '[\n    "I\\u2019m Yours.",\n    "Amen."]',
        )
        for wrong in ([], "Amen.", {"Amen.": 1}, ["Amen.", 1], None):
            with self.assertRaises(embed_seed.EmbedError, msg=repr(wrong)):
                embed_seed.prayer_literal(wrong)


class RepositoryTest(unittest.TestCase):
    def test_index_html_is_what_seed_generates(self):
        html = embed_seed.INDEX.read_text(encoding="utf-8")
        fresh, stale = embed_seed.regenerate(html)
        self.assertEqual(stale, [])
        self.assertEqual(fresh, html)

    def test_every_seed_file_is_embedded_or_named_as_outside_l11(self):
        present = {path.name for path in embed_seed.SEED.glob("*.json")}
        self.assertEqual(present - OUTSIDE_L11, embedded_sources())
        self.assertEqual(OUTSIDE_L11 - present, set())

    def test_seed_keeps_effort_guidance_that_the_prototype_does_not_show(self):
        seed_text = (embed_seed.SEED / "workouts.json").read_text(encoding="utf-8")
        self.assertIn("(RPE 7, rest 2 min)", seed_text)
        self.assertEqual(embed_seed.plan()["W"], embed_seed.strip_effort(json.loads(seed_text)))
        embedded = json.dumps(embed_seed.plan()["W"])
        self.assertNotRegex(embedded, r"\((?:RPE|RIR) \d")
        self.assertNotRegex(embedded, r"(?:RPE|RIR) [\d.-]+, ")


class RegenerateTest(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, True)
        for name in embedded_sources():
            shutil.copy(embed_seed.SEED / name, self.tmp / name)
        self.html = embed_seed.INDEX.read_text(encoding="utf-8")

    def edit(self, name, change):
        path = self.tmp / name
        value = json.loads(path.read_text(encoding="utf-8"))
        change(value)
        path.write_text(json.dumps(value), encoding="utf-8")

    def test_a_seed_edit_makes_only_its_own_embed_stale_and_write_fixes_it(self):
        self.edit("challenge-modes.json", lambda modes: modes.append("Ski"))
        fresh, stale = embed_seed.regenerate(self.html, self.tmp)
        self.assertEqual(stale, ["CH_MODES"])
        self.assertIn('  var CH_MODES = ["Row", "Bike", "Swim", "Ski"];\n', fresh)
        self.assertEqual(len(fresh), len(self.html) + len(', "Ski"'))
        again, stale_again = embed_seed.regenerate(fresh, self.tmp)
        self.assertEqual((again, stale_again), (fresh, []))

    def test_each_part_of_the_plan_and_the_small_constants_are_watched(self):
        self.edit("workout-meta.json", lambda meta: meta.update(extra="x"))
        self.edit("routines.json", lambda routines: routines["weeks"].append(16))
        self.edit("routines.json", lambda routines: routines["trainingDays"].update({"7": [1, 2, 3, 4, 5, 6, 0]}))
        self.edit("workout-prayer.json", lambda lines: lines.insert(0, 'A "new" line.'))
        self.edit("camps.json", lambda camps: camps["names"].pop())
        fresh, stale = embed_seed.regenerate(self.html, self.tmp)
        self.assertEqual(stale, ["PLAN", "CAMP_NAMES", "WORKOUT_PRAYER", "RT_WEEKS", "RT_PATTERN"])
        self.assertIn("  var RT_WEEKS = [4, 6, 8, 12, 16], RT_DOWS = [[1,", fresh)
        self.assertIn("7: [1, 2, 3, 4, 5, 6, 0] };\n", fresh)
        self.assertIn('  var WORKOUT_PRAYER = [\n    "A \\"new\\" line.",\n', fresh)
        self.assertEqual(embed_seed.regenerate(fresh, self.tmp), (fresh, []))

    def test_text_with_a_backslash_is_written_as_it_is(self):
        self.edit("challenge-modes.json", lambda modes: modes.append("Ski\\1 \\g<0>"))
        fresh, _ = embed_seed.regenerate(self.html, self.tmp)
        line = next(l for l in fresh.split("\n") if l.startswith("  var CH_MODES = "))
        self.assertTrue(line.endswith('"Ski\\\\1 \\\\g\\u003c0>"];'), line[-40:])
        self.assertEqual(json.loads(line[len("  var CH_MODES = "):-1])[-1], "Ski\\1 \\g<0>")

    def test_seed_text_cannot_end_the_script_it_is_embedded_in(self):
        closing = "Row </ScRiPt><script>alert(1)</script> <!-- x"
        self.edit("challenge-modes.json", lambda modes: modes.append(closing))
        self.edit("workout-prayer.json", lambda lines: lines.append(closing))
        self.edit("workout-meta.json", lambda meta: meta.update(extra=closing))
        self.edit("camps.json", lambda camps: camps["names"][0].update(name=closing))
        fresh, stale = embed_seed.regenerate(self.html, self.tmp)
        self.assertEqual(stale, ["PLAN", "CH_MODES", "CAMP_NAMES", "WORKOUT_PRAYER"])
        self.assertEqual(fresh.lower().count("</script"), self.html.lower().count("</script"))
        self.assertEqual(fresh.count("<!--"), self.html.count("<!--"))
        self.assertNotIn("alert(1)<", fresh)
        # The escape is one JavaScript and JSON both read back as "<".
        line = next(l for l in fresh.split("\n") if l.startswith("  var CH_MODES = "))
        self.assertEqual(json.loads(line[len("  var CH_MODES = "):-1])[-1], closing)
        self.assertEqual(embed_seed.regenerate(fresh, self.tmp), (fresh, []))

    def test_a_missing_or_repeated_variable_is_an_error_not_a_guess(self):
        missing = self.html.replace("  var CH_MODES = ", "  var CH_MODEZ = ")
        with self.assertRaisesRegex(embed_seed.EmbedError, "CH_MODES"):
            embed_seed.regenerate(missing, self.tmp)
        twice = self.html.replace("  var ALT = ", "  var ALT = {};\n  var ALT = ", 1)
        with self.assertRaisesRegex(embed_seed.EmbedError, "ALT"):
            embed_seed.regenerate(twice, self.tmp)

    def test_a_malformed_routine_is_refused_before_anything_is_written(self):
        self.edit("routines.json", lambda routines: routines["trainingDays"].update({"3": [{"days": [1, 3, 5]}]}))
        with self.assertRaisesRegex(embed_seed.EmbedError, r"trainingDays\[3\]"):
            embed_seed.regenerate(self.html, self.tmp)
        self.edit("routines.json", lambda routines: routines["trainingDays"].update({"3": [1, 3, 5]}))
        self.edit("routines.json", lambda routines: routines.update(weeks=[[4, 6], 8]))
        with self.assertRaisesRegex(embed_seed.EmbedError, "weeks"):
            embed_seed.regenerate(self.html, self.tmp)

    def test_a_video_written_as_a_string_is_a_clear_error_not_a_traceback(self):
        def as_string(movements):
            name = next(key for key, item in movements.items() if item.get("video"))
            movements[name]["video"] = movements[name]["video"]["url"]

        self.edit("movements.json", as_string)
        with self.assertRaisesRegex(embed_seed.EmbedError, "needs a video"):
            embed_seed.regenerate(self.html, self.tmp)

    def test_a_missing_or_broken_seed_file_is_an_error(self):
        (self.tmp / "camps.json").unlink()
        with self.assertRaisesRegex(embed_seed.EmbedError, "camps.json"):
            embed_seed.regenerate(self.html, self.tmp)
        (self.tmp / "camps.json").write_text("{", encoding="utf-8")
        with self.assertRaisesRegex(embed_seed.EmbedError, "camps.json"):
            embed_seed.regenerate(self.html, self.tmp)
        (self.tmp / "camps.json").write_text('{"names": [{"name": "A"}], "banners": []}', encoding="utf-8")
        with self.assertRaisesRegex(embed_seed.EmbedError, "camps.json"):
            embed_seed.regenerate(self.html, self.tmp)


if __name__ == "__main__":
    unittest.main()
