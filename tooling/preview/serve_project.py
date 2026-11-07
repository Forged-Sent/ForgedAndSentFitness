#!/usr/bin/env python3
"""Serve only the public prototype and generated Atlas on IPv4 loopback.

No dependencies, cloud access, repository-wide file serving or authentication.
The JavaScript pages remain untrusted previews; do not enter real credentials.
"""
from __future__ import annotations

import argparse
import errno
import mimetypes
import os
import shutil
import socket
import subprocess
import sys
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PORT = 43117
ATLAS = "/build/architecture-explorer/Architecture-Atlas.html"
ALLOWED_FILES = frozenset({
    "/index.html",
    ATLAS,
    "/build/architecture-explorer/index.html",
    "/build/architecture-explorer/site.css",
    "/build/architecture-explorer/site.js",
    "/build/architecture-explorer/data.js",
})
LANDING = """<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Forged &amp; Sent Knowledge Workspace</title>
<h1>Forged &amp; Sent / Knowledge Workspace</h1>
<p>These are local, JavaScript-enabled previews of the current Git checkout, not a production app.</p>
<ul><li><a href="/index.html">Open the actual HTML prototype</a></li>
<li><a href="/build/architecture-explorer/Architecture-Atlas.html">Open the generated Architecture Atlas</a></li></ul>
<p><strong>Expected prototype limits:</strong> the HTML prototype was built for the Claude-hosted runtime
(<code>window.claude</code>) and its <code>/_blob/</code> media service. Here, sign-in identity, saved data,
sharing and uploaded photos or PDFs are missing. That is expected and is <em>not</em> a Flutter or Firebase failure.</p>
<p>For Obsidian (desktop app only), open docs/ as your vault and paste this URL into the core Web viewer.</p>
<p>Do not enter personal information, secrets or production credentials.
To stop, close the terminal window (or press Ctrl+C; on Windows answer Y if asked to terminate the batch job).</p>
""".encode("utf-8")


class PreviewHandler(BaseHTTPRequestHandler):
    """Explicit-path static handler; never exposes arbitrary repository files."""

    server_version = "ForgedSentPreview/1.0"
    sys_version = ""

    def do_GET(self) -> None:
        self._serve(body=True)

    def do_HEAD(self) -> None:
        self._serve(body=False)

    def _serve(self, *, body: bool) -> None:
        # Reject DNS rebinding and other unexpected Host headers even though
        # the socket binds only to IPv4 loopback.
        expected = f"127.0.0.1:{self.server.server_port}"
        if self.headers.get("Host", "") != expected:
            self.send_error(400, "Use the printed 127.0.0.1 URL")
            return

        path = urlsplit(self.path).path
        if path == "/":
            self._send(200, "text/html; charset=utf-8", len(LANDING))
            if body:
                self.wfile.write(LANDING)
            return
        if path not in ALLOWED_FILES:
            self.send_error(404, "Not an allowed preview path")
            return

        root = self.server.project_root
        candidate = root / path.lstrip("/")
        # A tracked file can itself be a symlink into .git or other private
        # paths. Refuse every symlink component, even if it stays inside root.
        if any(p.is_symlink() for p in (candidate, *candidate.parents)
               if p != root and p.is_relative_to(root)):
            self.send_error(404, "Symlinks are not preview files")
            return
        file = candidate.resolve()
        if not file.is_relative_to(root) or not file.is_file():
            self.send_error(404, "Preview file unavailable")
            return
        content_type = mimetypes.guess_type(file.name)[0] or "application/octet-stream"
        if content_type.startswith(("text/", "application/javascript")):
            content_type += "; charset=utf-8"
        try:
            stream = file.open("rb")
        except OSError:
            # A concurrent Atlas regeneration may briefly replace files.
            self.send_error(404, "Preview file unavailable")
            return
        with stream:
            # Size of the file actually opened, not a later path lookup that a
            # concurrent Atlas regeneration could have replaced.
            self._send(200, content_type, os.fstat(stream.fileno()).st_size)
            if body:
                try:
                    shutil.copyfileobj(stream, self.wfile)
                except (BrokenPipeError, ConnectionResetError):
                    pass  # Browser navigated away after receiving headers.

    def _send(self, code: int, content_type: str, size: int) -> None:
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(size))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.end_headers()


class PreviewServer(ThreadingHTTPServer):
    """Loopback server that owns its port exclusively.

    http.server.HTTPServer sets allow_reuse_address = 1, so SO_REUSEADDR would be
    applied. On Windows that lets a second process bind the same port, and which
    listener answers becomes nondeterministic. On Windows we therefore disable it
    and request SO_EXCLUSIVEADDRUSE. POSIX keeps SO_REUSEADDR: there it never
    permits two active listeners, it only allows a quick restart after Ctrl+C
    while old connections sit in TIME_WAIT.
    """

    daemon_threads = True
    allow_reuse_address = sys.platform != "win32"

    def __init__(self, root: Path, port: int = DEFAULT_PORT):
        self.project_root = root.resolve()
        super().__init__(("127.0.0.1", port), PreviewHandler)

    def server_bind(self) -> None:
        if sys.platform == "win32":
            exclusive = getattr(socket, "SO_EXCLUSIVEADDRUSE", None)
            if exclusive is None:  # Should not happen on CPython for Windows.
                raise OSError("SO_EXCLUSIVEADDRUSE unavailable; refusing a shareable port")
            self.socket.setsockopt(socket.SOL_SOCKET, exclusive, 1)
        super().server_bind()


def make_server(root: Path = ROOT, port: int = DEFAULT_PORT) -> PreviewServer:
    """Create a bound server. Port zero is supported for isolated tests."""
    return PreviewServer(root, port)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build-atlas", action="store_true", help="Regenerate Atlas from this Git checkout")
    parser.add_argument("--open-browser", action="store_true", help="Open the landing page in the default browser")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT,
                        help="Loopback port (default: 43117; 0 picks a free port, used by tests)")
    args = parser.parse_args()
    if not 0 <= args.port <= 65535:
        parser.error("port must be between 0 and 65535")
    if sys.version_info < (3, 11):
        print("Python 3.11+ is required.", file=sys.stderr)
        return 1
    if args.build_atlas:
        result = subprocess.run(
            [sys.executable, str(ROOT / "tooling/architecture/build_explorer.py"), "--write"],
            cwd=ROOT, check=False,
        )
        if result.returncode:
            print("Atlas generation failed; no preview server was started.", file=sys.stderr)
            return result.returncode
    if not (ROOT / "index.html").is_file():
        print("Missing root index.html; use a complete Git checkout.", file=sys.stderr)
        return 1
    try:
        server = make_server(ROOT, args.port)
    except OSError as exc:
        # 10048 = WSAEADDRINUSE; 10013 = WSAEACCES, returned on Windows when an
        # exclusive (SO_EXCLUSIVEADDRUSE) listener already owns the port.
        in_use = exc.errno == errno.EADDRINUSE or getattr(exc, "winerror", None) in (10048, 10013)
        if in_use:
            print(f"Port {args.port} is already in use, so no preview was started.\n"
                  "Another preview window may still be open: close it and retry. If you just closed one,\n"
                  "wait about a minute and retry. Don't trust a page on this port unless a preview\n"
                  "window says it is serving.", file=sys.stderr)
        else:
            print(f"Could not bind 127.0.0.1:{args.port}: {exc}", file=sys.stderr)
        return 1
    url = f"http://127.0.0.1:{server.server_port}"
    print(f"\nKnowledge workspace: {url}/", flush=True)
    print(f"Prototype: {url}/index.html", flush=True)
    print(f"Atlas: {url}{ATLAS}", flush=True)
    print("Paste a URL into Obsidian's core Web viewer or use your normal browser.", flush=True)
    print("Read-only allowlisted preview; no Firebase/cloud login.", flush=True)
    print("To stop: close this window, or press Ctrl+C (Windows may ask 'Terminate batch job?': answer Y).\n",
          flush=True)
    if args.open_browser:
        # Some platform browser launchers block; never delay the HTTP loop.
        threading.Thread(target=webbrowser.open, args=(url + "/",), daemon=True).start()
    try:
        server.serve_forever(poll_interval=0.2)
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
