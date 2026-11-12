"""Optional shell consent and portable source packaging; never installs user tools."""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SELECT = """
. "$1/tooling/macos/common.sh"
. "$1/tooling/macos/forge-shell.sh"
fs_select_engineering_shell
printf '\\nRESULT=%s,%s,%s\\n' "$FS_SHELL_INSTALL" "$FS_SHELL_TERMINAL" "$FS_SHELL_TOOLS"
"""


class OptionalShellTests(unittest.TestCase):
    def choose(self, answer, *, tty=False, ci=False):
        bash = shutil.which("bash")
        self.assertIsNotNone(bash)
        with tempfile.TemporaryDirectory(prefix="forge-consent-") as fixture:
            env = {k: v for k, v in os.environ.items() if k not in ("CI", "FS_CI")}
            env["HOME"] = Path(fixture).as_posix()
            if ci:
                env["CI"] = "1"
            args = [bash, "-c", SELECT, (ROOT / "tooling/macos/setup.sh").as_posix(), ROOT.as_posix()]
            if tty:
                import pty
                master, slave = pty.openpty()
                try:
                    proc = subprocess.Popen(args, stdin=slave, stdout=subprocess.PIPE,
                                            stderr=subprocess.STDOUT, text=True, env=env)
                    os.write(master, answer.encode())
                    output, _ = proc.communicate(timeout=10)
                finally:
                    os.close(master)
                    os.close(slave)
            else:
                proc = subprocess.run(args, input=answer, capture_output=True, text=True,
                                      env=env, timeout=10)
                output = proc.stdout
            self.assertEqual(proc.returncode, 0, output)
            self.assertEqual(list(Path(fixture).iterdir()), [], "Selecting must not write files")
            return output

    def test_eof_and_piped_yes_both_skip_without_prompts(self):
        for answer in ("", "yes\n1\nyes\n"):
            with self.subTest(answer=answer):
                output = self.choose(answer)
                self.assertIn("RESULT=0,none,0", output)
                self.assertNotIn("Would you like", output)

    @unittest.skipIf(os.name == "nt", "POSIX pseudo-terminal required; exercised on Linux/macOS")
    def test_return_declines_on_a_real_terminal(self):
        output = self.choose("\n", tty=True)
        self.assertIn("RESULT=0,none,0", output)
        self.assertNotIn("Colors [none]", output)

    @unittest.skipIf(os.name == "nt", "POSIX pseudo-terminal required; exercised on Linux/macOS")
    def test_core_acceptance_leaves_extras_off(self):
        self.assertIn("RESULT=1,none,0", self.choose("yes\n\n\n", tty=True))

    @unittest.skipIf(os.name == "nt", "POSIX pseudo-terminal required; exercised on Linux/macOS")
    def test_extras_require_separate_choices(self):
        self.assertIn("RESULT=1,ghostty,1", self.choose("yes\n2\nyes\n", tty=True))

    @unittest.skipIf(os.name == "nt", "POSIX pseudo-terminal required; exercised on Linux/macOS")
    def test_ci_never_prompts_even_on_a_terminal(self):
        output = self.choose("yes\n1\nyes\n", tty=True, ci=True)
        self.assertIn("RESULT=0,none,0", output)
        self.assertNotIn("Would you like", output)

    def test_packages_have_no_personal_state_or_machine_defaults(self):
        import json
        package = ROOT / "tooling/forge-shell"
        settings = json.loads((package / "windows/config/settings.json").read_text())
        self.assertEqual(settings["DefaultProject"], "")
        self.assertEqual(settings["WorkspaceRoots"], [])
        self.assertEqual(settings["FlutterSdk"], "")
        tracked = subprocess.check_output(
            ["git", "-C", str(ROOT), "ls-files", "--", "tooling/forge-shell"], text=True
        ).splitlines()
        forbidden = {"data", "backups", "__pycache__", ".qa", "proposed"}
        for name in tracked:
            self.assertFalse(forbidden.intersection(Path(name).parts), name)
        for platform in ("windows", "macos"):
            self.assertTrue((package / platform / "README.md").is_file())


if __name__ == "__main__":
    unittest.main()
