"""The pre-push hook, run by a real `git push`, from both kinds of checkout.

Each test builds a throwaway repository with the project's own
`.githooks/pre-push`, a linked worktree of it, and a local bare repository to
push to. Nothing leaves the temporary folder and no network is used.

Flutter is replaced by a small script that behaves like Flutter in the one way
that matters here: it finds its own version by running git inside its SDK
folder. When git's hook variables (GIT_DIR and its relatives) leak into it, it
reads the wrong repository and fails, as Flutter does with "0.0.0-unknown".
"""
from __future__ import annotations

import os
import pathlib
import shutil
import stat
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
HOOK = ROOT / ".githooks" / "pre-push"
UNSET_LINE = "  unset $(git rev-parse --local-env-vars)\n"

FAKE_FLUTTER = """#!/bin/sh
# Stands in for Flutter in tooling/onboarding/test_git_hooks.py.
log='@LOG@'
sdk='@SDK@'
want='@HEAD@'
got="$(cd "$sdk" && git rev-parse HEAD 2>/dev/null || true)"
if [ "$got" != "$want" ]; then
  echo "$1 unknown-version" >> "$log"
  echo "The current Flutter SDK version is 0.0.0-unknown." >&2
  exit 1
fi
echo "$1 ok $(basename "$(pwd)")" >> "$log"
if [ "${FAKE_FLUTTER_FAIL:-}" = "$1" ]; then
  echo "fake flutter $1 failed" >&2
  exit 1
fi
"""


def clean_env() -> dict[str, str]:
    """The caller's environment without anything that ties git to a repository."""
    listed = subprocess.run(
        ["git", "rev-parse", "--local-env-vars"], capture_output=True, text=True, check=True
    ).stdout.split()
    env = {key: value for key, value in os.environ.items() if key not in listed}
    env["GIT_CONFIG_GLOBAL"] = os.devnull
    env["GIT_CONFIG_NOSYSTEM"] = "1"
    env.pop("FAKE_FLUTTER_FAIL", None)
    env.pop("FS_REQUIRE_AI_REVIEW", None)
    return env


class PrePushHookTest(unittest.TestCase):
    def setUp(self):
        self.tmp = pathlib.Path(os.path.realpath(tempfile.mkdtemp()))
        self.addCleanup(shutil.rmtree, self.tmp, True)
        self.env = clean_env()
        self.log = self.tmp / "flutter.log"
        self.remote = self.tmp / "remote.git"
        self.first = self.tmp / "first"
        self.linked = self.tmp / "linked"

        # The stand-in SDK is its own repository, as Flutter's is.
        sdk = self.tmp / "sdk"
        sdk.mkdir()
        self.git(sdk, "init", "-q")
        (sdk / "version").write_text("stand-in SDK\n", encoding="utf-8")
        self.commit(sdk, "SDK")
        sdk_head = self.git(sdk, "rev-parse", "HEAD").stdout.strip()

        bin_dir = self.tmp / "bin"
        bin_dir.mkdir()
        fake = bin_dir / "flutter"
        fake.write_text(
            FAKE_FLUTTER.replace("@LOG@", self.log.as_posix())
            .replace("@SDK@", sdk.as_posix())
            .replace("@HEAD@", sdk_head),
            encoding="utf-8",
            newline="\n",
        )
        fake.chmod(fake.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        self.env["PATH"] = str(bin_dir) + os.pathsep + self.env["PATH"]

        self.git(self.tmp, "init", "-q", "--bare", str(self.remote))

        self.first.mkdir()
        self.git(self.first, "init", "-q")
        self.git(self.first, "symbolic-ref", "HEAD", "refs/heads/work")
        (self.first / "mobile").mkdir()
        (self.first / "mobile" / "pubspec.yaml").write_text("name: stand_in\n", encoding="utf-8")
        self.install_hook(HOOK.read_text(encoding="utf-8"))
        self.commit(self.first, "Project")
        self.git(self.first, "config", "core.hooksPath", ".githooks")
        self.git(self.first, "worktree", "add", "-q", "-b", "linked", str(self.linked))

    def git(self, cwd, *args, check=True, **extra_env):
        return subprocess.run(
            ["git", *args],
            cwd=cwd,
            env={**self.env, **extra_env},
            capture_output=True,
            text=True,
            check=check,
        )

    def commit(self, cwd, message):
        self.git(cwd, "add", "-A")
        self.git(cwd, "-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-q", "-m", message)

    def install_hook(self, text):
        # core.hooksPath is ".githooks", so each checkout runs its own copy.
        for checkout in (self.first, self.linked):
            if checkout.exists():
                hooks = checkout / ".githooks"
                hooks.mkdir(exist_ok=True)
                hook = hooks / "pre-push"
                hook.write_text(text, encoding="utf-8", newline="\n")
                hook.chmod(0o755)

    def push(self, checkout, ref, **extra_env):
        return self.git(checkout, "push", str(self.remote), f"HEAD:refs/heads/{ref}", check=False, **extra_env)

    def pushed(self, ref):
        """The commit the remote holds for this branch, or None."""
        found = self.git(self.tmp, "--git-dir", str(self.remote), "rev-parse", "-q", "--verify", f"refs/heads/{ref}", check=False)
        return found.stdout.strip() if found.returncode == 0 else None

    def flutter_log(self):
        return self.log.read_text(encoding="utf-8").splitlines() if self.log.exists() else []

    def checkouts(self):
        """Name, folder and a branch name of its own on the remote for each checkout."""
        return (("first checkout", self.first, "from-first"), ("linked worktree", self.linked, "from-linked"))

    def test_a_push_runs_analyze_then_test_in_mobile_from_either_checkout(self):
        for name, checkout, ref in self.checkouts():
            with self.subTest(checkout=name):
                self.log.unlink(missing_ok=True)
                self.assertIsNone(self.pushed(ref))
                result = self.push(checkout, ref)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.flutter_log(), ["analyze ok mobile", "test ok mobile"])
                self.assertEqual(self.pushed(ref), self.git(checkout, "rev-parse", "HEAD").stdout.strip())

    def test_a_push_is_refused_when_analyze_fails(self):
        for name, checkout, ref in self.checkouts():
            with self.subTest(checkout=name):
                self.log.unlink(missing_ok=True)
                result = self.push(checkout, ref, FAKE_FLUTTER_FAIL="analyze")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("fake flutter analyze failed", result.stderr)
                # The tests are not run once analysis has failed.
                self.assertEqual(self.flutter_log(), ["analyze ok mobile"])
                self.assertIsNone(self.pushed(ref))

    def test_a_push_is_refused_when_a_test_fails(self):
        for name, checkout, ref in self.checkouts():
            with self.subTest(checkout=name):
                self.log.unlink(missing_ok=True)
                result = self.push(checkout, ref, FAKE_FLUTTER_FAIL="test")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("fake flutter test failed", result.stderr)
                self.assertEqual(self.flutter_log(), ["analyze ok mobile", "test ok mobile"])
                self.assertIsNone(self.pushed(ref))

    def test_a_push_from_main_is_refused_before_flutter_runs(self):
        self.git(self.linked, "checkout", "-q", "-b", "main")
        result = self.push(self.linked, "from-main")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Main is protected", result.stderr)
        self.assertEqual(self.flutter_log(), [])
        self.assertIsNone(self.pushed("from-main"))

    def test_without_the_unset_line_a_linked_worktree_cannot_push(self):
        """The reason the line is there, and proof these tests would notice its loss."""
        text = HOOK.read_text(encoding="utf-8")
        self.assertEqual(text.count(UNSET_LINE), 1)
        self.install_hook(text.replace(UNSET_LINE, ""))

        first = self.push(self.first, "old-first")
        self.assertEqual(first.returncode, 0, first.stderr)

        self.log.unlink()
        linked = self.push(self.linked, "old-linked")
        self.assertNotEqual(linked.returncode, 0)
        self.assertIn("0.0.0-unknown", linked.stderr)
        self.assertEqual(self.flutter_log(), ["analyze unknown-version"])
        self.assertIsNone(self.pushed("old-linked"))


if __name__ == "__main__":
    unittest.main()
