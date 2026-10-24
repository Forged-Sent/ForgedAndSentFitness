#!/usr/bin/env python3
"""Build dev/preview.html: index.html with the local claude.ai runtime stand-in injected. Open it in a browser."""
import pathlib
root = pathlib.Path(__file__).resolve().parent.parent
html = (root / "index.html").read_text()
(root / "dev" / "preview.html").write_text('<script src="mock-claude.js"></script>\n' + html)
print("wrote dev/preview.html")
