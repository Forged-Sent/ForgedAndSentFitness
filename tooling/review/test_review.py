"""Review coordinator tests, no provider or network access."""
import tempfile
import unittest
from pathlib import Path

from review import build_prompt, chunk_patch, chunk_manifest, command_for, parse_report, summarize


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


    def test_large_patch_has_exact_coverage(self):
        patch = ("diff --git a/a.txt b/a.txt\\n@@ -1,0 +1,1 @@\\n+" +
                 "0123456789" * 25000 + "\\n") * 3
        chunks = chunk_patch(patch, limit=4096)
        self.assertGreater(len(chunks), 100)
        self.assertTrue(all(len(c["text"]) <= 4096 for c in chunks))
        self.assertEqual("".join(c["text"] for c in chunks), patch)
        self.assertEqual(chunks[0]["start"], 0)
        self.assertEqual(chunks[-1]["end"], len(patch))
        self.assertEqual(len(chunk_manifest(chunks)), len(chunks))

    def test_missing_slice_cannot_pass(self):
        good = {"status": "OK", "review": {"verdict": "PASS", "findings": [], "unverified": []}}
        chunks = chunk_patch("diff --git a/f b/f\\n+" + "x" * 7500, limit=4096)
        self.assertEqual(len(chunks), 2)
        _, ok = summarize({"claude#1/2": good}, "head", "sha", "base", 1,
                          chunks, ["claude"])
        self.assertFalse(ok)
        report, ok = summarize({"claude#1/2": good, "claude#2/2": good},
                               "head", "sha", "base", 1, chunks, ["claude"])
        self.assertTrue(ok)
        self.assertEqual(report["chunks"], chunk_manifest(chunks))

    def test_pr_worktree_guidance_is_not_trusted(self):
        import subprocess
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.name", "Test"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.email", "test@example.invalid"], cwd=root, check=True)
            (root / "AGENTS.md").write_text("BASELINE_REVIEW_GUIDE", encoding="utf-8")
            subprocess.run(["git", "add", "AGENTS.md"], cwd=root, check=True)
            subprocess.run(["git", "commit", "-qm", "base"], cwd=root, check=True)
            base = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
            (root / "AGENTS.md").write_text("INJECTED_BRANCH_GUIDE", encoding="utf-8")
            prompt = build_prompt(root, "diff --git a/a b/a", base)
            self.assertIn("BASELINE_REVIEW_GUIDE", prompt)
            self.assertNotIn("INJECTED_BRANCH_GUIDE", prompt)
            self.assertNotIn("trusted guidance", prompt)

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
