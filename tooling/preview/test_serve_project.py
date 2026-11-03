"""Deterministic loopback server security and content tests (stdlib only)."""
from __future__ import annotations

import threading
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from serve_project import ATLAS, make_server


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
        for path in ("/.git/config", "/docs/HOME.md", "/seed/", "/",
                     "/tooling/preview/serve_project.py", "/%2e%2e/.git/config",
                     "/build/architecture-explorer/../../.git/config"):
            if path != "/":
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
        (self.root / "index.html").symlink_to(target)
        self.assert_rejected("/index.html")

    def test_symlink_cannot_reveal_internal_git_config(self) -> None:
        (self.root / "index.html").unlink()
        (self.root / "index.html").symlink_to(self.root / ".git" / "config")
        self.assert_rejected("/index.html")

    def test_generated_atlas_symlink_cannot_reveal_git_config(self) -> None:
        atlas = self.root / ATLAS.lstrip("/")
        atlas.unlink()
        atlas.symlink_to(self.root / ".git" / "config")
        self.assert_rejected(ATLAS)

    def test_missing_atlas_is_not_replaced_with_other_files(self) -> None:
        (self.root / ATLAS.lstrip("/")).unlink()
        self.assert_rejected(ATLAS)


if __name__ == "__main__":
    unittest.main()
