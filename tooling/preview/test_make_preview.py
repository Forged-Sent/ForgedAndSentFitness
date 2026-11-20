"""dev/make_preview.py builds the prototype preview whatever the system's own text encoding is.

It is tested here, beside the knowledge preview server, because this folder's
tests are the ones CI runs on Linux, macOS and Windows. Standard library only.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

SCRIPT = Path(__file__).resolve().parents[2] / "dev" / "make_preview.py"

# What index.html really holds: curly quotes, a dash, an accent, a tick. The
# closing curly quote is the character Windows' own encoding cannot read back
# from UTF-8, and the one the script stopped on.
PAGE = "<!doctype html>\n<p>“Be watchful” — café ✓</p>\n"

# Keeps Python out of UTF-8 mode, so it uses the system's own encoding: cp1252
# on a Windows workstation, ASCII on Linux and macOS with the C locale.
NOT_UTF8 = {"PYTHONUTF8": "0", "PYTHONCOERCECLOCALE": "0", "LC_ALL": "C", "LANG": "C"}


class MakePreviewTest(unittest.TestCase):
    def build(self, environment: dict[str, str]) -> tuple[subprocess.CompletedProcess, bytes]:
        """Runs a copy of the script beside a small index.html, as it runs in the repository."""
        with TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "dev").mkdir()
            script = shutil.copy2(SCRIPT, root / "dev" / "make_preview.py")
            (root / "index.html").write_bytes(PAGE.encode("utf-8"))
            result = subprocess.run([sys.executable, str(script)], cwd=root, capture_output=True, text=True,
                                    env={**os.environ, **environment})
            preview = root / "dev" / "preview.html"
            return result, preview.read_bytes() if preview.is_file() else b""

    def default_encoding(self, environment: dict[str, str]) -> str:
        """The encoding Python opens a text file with, in a process started with [environment]."""
        probe = subprocess.run([sys.executable, "-c", "import locale; print(locale.getpreferredencoding(False))"],
                               capture_output=True, text=True, env={**os.environ, **environment})
        return probe.stdout.strip().lower().replace("_", "-")

    def test_a_system_encoding_that_is_not_utf8_does_not_stop_it(self) -> None:
        # Asked, not assumed: a Windows PC set to use UTF-8 system-wide stays UTF-8 whatever
        # this test sets, and there the script would pass with or without its fix.
        encoding = self.default_encoding(NOT_UTF8)
        if encoding in ("utf-8", "utf8", "cp65001"):
            self.skipTest(f"this system's own encoding is already UTF-8 ({encoding}); nothing to prove here")

        result, written = self.build(NOT_UTF8)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("wrote dev/preview.html", result.stdout)
        # Every character is there, as UTF-8. Line ends may be the system's own.
        self.assertEqual(written.decode("utf-8").replace("\r\n", "\n"),
                         '<script src="mock-claude.js"></script>\n' + PAGE)

    def test_the_preview_is_the_page_with_the_mock_runtime_in_front(self) -> None:
        result, written = self.build({"PYTHONUTF8": "1"})

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(written.decode("utf-8").replace("\r\n", "\n"),
                         '<script src="mock-claude.js"></script>\n' + PAGE)


if __name__ == "__main__":
    unittest.main()
