"""Gate scope/routing regressions; no providers, credentials or network calls."""
import unittest

from flutter_scope import needs_review, relevant_paths, reviewers_for


class FlutterScopeTests(unittest.TestCase):
    def test_functional_files_include_configuration_assets_tests_and_backend(self):
        for path in ("mobile/lib/main.dart", "mobile/test/widget_test.dart",
                     "mobile/pubspec.yaml", "mobile/pubspec.lock",
                     "mobile/android/app/build.gradle", "mobile/assets/icon.png", "mobile/assets/data.txt",
                     "mobile/lib/l10n/app_en.arb", "mobile/assets/devotional.md", "firebase/firestore.rules",
                     "tooling/firebase/package-lock.json", "firestore.rules", "mobile/docs/guide.md"):
            with self.subTest(path=path):
                self.assertTrue(needs_review(path))

    def test_docs_and_separate_html_prototype_are_exempt(self):
        for path in ("README.md", "docs/architecture/SYSTEM.md", "mobile/README.md",
                     "index.html", "versions/app-v238.html", "dev/demo.html",
                     "dev/mock-claude.js", "seed/devotionals.json",
                     "seed/devotionals-v2.json", "seed/lifts.json", "seed/esv-verses.json"):
            with self.subTest(path=path):
                self.assertFalse(needs_review(path))

    def test_unknown_and_new_backend_paths_require_review(self):
        for path in ("functions/src/score.ts", "backend/rules.sql", "new-feature/file.txt",
                     "versions/not-a-snapshot.js", "docs/architecture/explorer/app.js"):
            with self.subTest(path=path):
                self.assertTrue(needs_review(path))

    def test_gate_policy_cannot_exempt_itself(self):
        for path in ("tooling/review/flutter_scope.py", "tooling/review/README.md",
                     ".github/rulesets/flutter-ai-review.json",
                     ".github/workflows/flutter-ai-review.yml", ".github/workflows/other.yml",
                     ".github/actions/check/action.yml"):
            self.assertTrue(needs_review(path))

    def test_removed_and_renamed_code_still_requires_review(self):
        files = [{"filename": "mobile/lib/old.dart", "status": "removed"},
                 {"filename": "docs/old.dart", "previous_filename": "mobile/lib/moved.dart",
                  "status": "renamed"}]
        self.assertEqual(relevant_paths(files),
                         ["docs/old.dart", "mobile/lib/moved.dart", "mobile/lib/old.dart"])

    def test_invalid_paths_fail_closed(self):
        for path in ("", "../mobile/a.dart", "/mobile/a.dart", "mobile\\a.dart", "mobile//a"):
            with self.subTest(path=path), self.assertRaises(ValueError):
                needs_review(path)
        with self.assertRaises(ValueError):
            relevant_paths([{"status": "removed"}])

    def test_opposite_provider_routing(self):
        self.assertEqual(reviewers_for(["authorship:codex"]), ("claude",))
        self.assertEqual(reviewers_for(["authorship:claude"]), ("codex",))
        self.assertEqual(reviewers_for(["authorship:human"]), ("codex",))
        self.assertEqual(reviewers_for(["authorship:automation"]), ("codex",))
        self.assertEqual(reviewers_for(["authorship:mixed"]), ("codex", "claude"))

    def test_unknown_or_conflicting_authorship_blocks(self):
        for labels in ([], ["authorship:unknown"], ["authorship:codex", "authorship:claude"]):
            with self.subTest(labels=labels), self.assertRaises(ValueError):
                reviewers_for(labels)


if __name__ == "__main__":
    unittest.main()
