"""Review coordinator tests, no provider or network access."""
import tempfile
import unittest
from pathlib import Path

from review import command_for, parse_report, summarize


class ReviewTests(unittest.TestCase):
    def test_good_json(self):
        r = parse_report('{"verdict":"PASS","findings":[],"unverified":[]}')
        self.assertEqual(r["verdict"], "PASS")

    def test_rejects_malformed_or_unverifiable(self):
        for s in (
            "I found no problems",
            '{"verdict":"PASS","findings":[]}',
            '{"verdict":"PASS","findings":[{"severity":"high","path":"a","line":1,"explanation":"bug","fix":"fix"}],"unverified":[]}',
            '{"verdict":"PASS","findings":[{"severity":"low","path":"a","line":0,"explanation":"bug","fix":"fix"}],"unverified":[]}',
        ):
            with self.assertRaises(ValueError):
                parse_report(s)

    def test_independent_reviews_and_blockers(self):
        good = {"status": "OK", "review": {"verdict": "PASS", "findings": [], "unverified": []}}
        report, ok = summarize({"codex": good, "claude": good}, "abc", "digest", "origin/main", 2)
        self.assertTrue(ok)
        self.assertEqual(report["status"], "PASS")
        _, ok = summarize({"codex": good, "gemini": {"status": "ERROR", "reason": "login"}}, "abc", "digest", "origin/main", 2)
        self.assertFalse(ok)

    def test_safe_commands(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "last.txt"
            codex = command_for("codex", out)
            claude = command_for("claude", out)
            gemini = command_for("gemini", out)
            self.assertIn("read-only", codex)
            self.assertIn("--skip-git-repo-check", codex)
            self.assertEqual(codex[-1], "-")
            self.assertIn("--tools", claude)
            self.assertIn("mcp__*", claude)
            self.assertIn("--sandbox", gemini)
            self.assertIn("plan", gemini)
            for cmd in (codex, claude, gemini):
                self.assertNotIn("--dangerously-skip-permissions", cmd)
                self.assertNotIn("--yolo", cmd)


if __name__ == "__main__":
    unittest.main()
