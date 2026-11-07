"""Deterministic loopback server security and content tests (stdlib only)."""
from __future__ import annotations

import socket
import subprocess
import sys
import threading
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory, TemporaryFile
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

import serve_project
from serve_project import ATLAS, make_server

# Bypass any developer/CI HTTP proxy for loopback requests.
import urllib.request as _ur
_ur.install_opener(_ur.build_opener(_ur.ProxyHandler({})))


class PreviewServerTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / "index.html").write_text(
            "<!doctype html><button onclick='go()'>prototype</button>", encoding="utf-8"
        )
        atlas = self.root / ATLAS.lstrip("/")
        atlas.parent.mkdir(parents=True)
        atlas.write_text("<!doctype html><script>window.atlas=true</script>", encoding="utf-8")
        (atlas.parent / "site.js").write_text("window.atlas=true;", encoding="utf-8")
        (self.root / ".git").mkdir()
        (self.root / ".git" / "config").write_text("private", encoding="utf-8")
        (self.root / "docs").mkdir()
        (self.root / "docs" / "HOME.md").write_text("private docs", encoding="utf-8")
        self.server = make_server(self.root, port=0)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.addCleanup(self._close)
        self.base = f"http://127.0.0.1:{self.server.server_port}"

    def _close(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=3)

    def get(self, path: str, *, headers: dict | None = None, method: str = "GET"):
        return urlopen(Request(self.base + path, headers=headers or {}, method=method), timeout=3)

    def symlink_or_skip(self, link: Path, target: Path) -> None:
        # Windows needs Developer Mode or elevation to create symlinks.
        try:
            link.symlink_to(target)
        except OSError as exc:
            self.skipTest(f"symlink creation not permitted here: {exc}")

    def assert_rejected(self, path: str) -> None:
        with self.assertRaises(HTTPError) as caught:
            self.get(path)
        self.assertEqual(caught.exception.code, 404)

    def test_landing_has_only_preview_navigation(self) -> None:
        with self.get("/") as response:
            body = response.read().decode("utf-8")
            self.assertIn("/index.html", body)
            self.assertIn(ATLAS, body)
            self.assertNotIn("private docs", body)
            self.assertEqual(response.headers["Cache-Control"], "no-store")
            self.assertIsNone(response.headers.get("Access-Control-Allow-Origin"))

    def test_prototype_and_atlas_are_live_html(self) -> None:
        with self.get("/index.html") as response:
            self.assertIn(b"onclick='go()'", response.read())
            self.assertIn("text/html", response.headers["Content-Type"])
        with self.get(ATLAS) as response:
            self.assertIn(b"window.atlas=true", response.read())
        with self.get("/build/architecture-explorer/site.js") as response:
            self.assertIn(b"window.atlas=true", response.read())

    def test_rejects_sensitive_paths_and_traversal(self) -> None:
        for path in ("/.git/config", "/docs/HOME.md", "/seed/",
                     "/tooling/preview/serve_project.py", "/%2e%2e/.git/config",
                     "/build/architecture-explorer/../../.git/config"):
            with self.subTest(path=path):
                self.assert_rejected(path)

    def test_rejects_untrusted_host_header(self) -> None:
        with self.assertRaises(HTTPError) as caught:
            self.get("/index.html", headers={"Host": "malicious.example"})
        self.assertEqual(caught.exception.code, 400)

    def test_head_is_read_only_and_has_no_body(self) -> None:
        with self.get("/index.html", method="HEAD") as response:
            self.assertEqual(response.status, 200)
            self.assertEqual(response.read(), b"")
        with self.assertRaises(HTTPError) as caught:
            self.get("/index.html", method="POST")
        self.assertEqual(caught.exception.code, 501)

    def test_symlink_cannot_escape_root(self) -> None:
        target = self.root.parent / (self.root.name + "-outside.txt")
        target.write_text("private outside", encoding="utf-8")
        self.addCleanup(lambda: target.unlink(missing_ok=True))
        (self.root / "index.html").unlink()
        self.symlink_or_skip(self.root / "index.html", target)
        self.assert_rejected("/index.html")

    def test_symlink_cannot_reveal_internal_git_config(self) -> None:
        (self.root / "index.html").unlink()
        self.symlink_or_skip(self.root / "index.html", self.root / ".git" / "config")
        self.assert_rejected("/index.html")

    def test_generated_atlas_symlink_cannot_reveal_git_config(self) -> None:
        atlas = self.root / ATLAS.lstrip("/")
        atlas.unlink()
        self.symlink_or_skip(atlas, self.root / ".git" / "config")
        self.assert_rejected(ATLAS)

    def test_missing_atlas_is_not_replaced_with_other_files(self) -> None:
        (self.root / ATLAS.lstrip("/")).unlink()
        self.assert_rejected(ATLAS)

    def test_landing_explains_prototype_runtime_limits(self) -> None:
        with self.get("/") as response:
            body = response.read().decode("utf-8")
        self.assertIn("window.claude", body)
        self.assertIn("/_blob/", body)
        self.assertIn("not</em> a Flutter or Firebase failure", body)

    def test_second_server_cannot_share_the_port(self) -> None:
        # Regression for Windows SO_REUSEADDR port sharing: a repeat launch or a
        # foreign process must get an error instead of silently co-listening.
        with self.assertRaises(OSError):
            second = make_server(self.root, port=self.server.server_port)
            second.server_close()

    @unittest.skipUnless(sys.platform == "win32", "Windows-only socket option")
    def test_windows_listener_is_exclusive_and_not_reusable(self) -> None:
        sock = self.server.socket
        self.assertEqual(sock.getsockopt(socket.SOL_SOCKET, socket.SO_EXCLUSIVEADDRUSE), 1)
        self.assertEqual(sock.getsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR), 0)

    def test_stopped_server_no_longer_responds(self) -> None:
        port = self.server.server_port
        self._close()
        with self.assertRaises((URLError, ConnectionError, OSError)):
            urlopen(f"http://127.0.0.1:{port}/", timeout=2)
        # The registered cleanup calls _close again; shutdown/close are idempotent.


@unittest.skipUnless(sys.version_info >= (3, 11), "launcher entrypoint requires Python 3.11+")
class EntrypointSmokeTest(unittest.TestCase):
    """Run the real serve_project.py process, as the OS launchers do."""

    def test_real_process_serves_allowlist_and_stops(self) -> None:
        script = Path(serve_project.__file__).resolve()
        # Request logs go to stderr; a file (not a pipe) can never fill up and block.
        log = TemporaryFile(mode="w+")
        self.addCleanup(log.close)
        proc = subprocess.Popen([sys.executable, str(script), "--port", "0"],
                                stdout=subprocess.PIPE, stderr=log, text=True, bufsize=1)
        self.addCleanup(proc.stdout.close)
        self.addCleanup(lambda: proc.poll() is None and (proc.kill(), proc.wait(timeout=10)))
        url = ""
        for _ in range(12):
            line = proc.stdout.readline()
            if not line:
                break
            if line.startswith("Knowledge workspace: "):
                url = line.split(": ", 1)[1].strip().rstrip("/")
                break
        if not url.startswith("http://127.0.0.1:"):
            log.seek(0)
            self.fail(f"server did not print its URL: {log.read()[-2000:]}")
        with urlopen(url + "/", timeout=5) as response:
            self.assertEqual(response.status, 200)
        with urlopen(url + "/index.html", timeout=5) as response:
            self.assertIn("text/html", response.headers["Content-Type"])
        with self.assertRaises(HTTPError) as caught:
            urlopen(url + "/.git/config", timeout=5)
        self.assertEqual(caught.exception.code, 404)
        proc.terminate()
        proc.wait(timeout=10)
        with self.assertRaises((URLError, ConnectionError, OSError)):
            urlopen(url + "/", timeout=2)


if __name__ == "__main__":
    unittest.main()
