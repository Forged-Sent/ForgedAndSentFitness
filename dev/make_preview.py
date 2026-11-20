#!/usr/bin/env python3
"""Build dev/preview.html: index.html with the local claude.ai runtime stand-in injected. Open it in a browser."""
import pathlib
root = pathlib.Path(__file__).resolve().parent.parent
# index.html is UTF-8. Say so: Python otherwise reads and writes in the
# system's own encoding, which on Windows is not UTF-8, and stops on the
# first character that encoding does not have.
html = (root / "index.html").read_text(encoding="utf-8")
(root / "dev" / "preview.html").write_text('<script src="mock-claude.js"></script>\n' + html, encoding="utf-8")
print("wrote dev/preview.html")
