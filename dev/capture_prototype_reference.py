#!/usr/bin/env python3
"""Screenshot the HTML prototype at phone size, in dark and light, as a visual reference.

Used to compare Flutter golden images with the prototype by eye. It reads one
prototype file out of git, adds the local stand-in for the claude.ai runtime
(dev/mock-claude.js) and a small script that gets past the first-run screens,
then asks a headless Chrome or Edge for a screenshot of each page and theme.

    python3 dev/capture_prototype_reference.py
    python3 dev/capture_prototype_reference.py --source origin/main:index.html --pages today,fuel
    python3 dev/capture_prototype_reference.py --out some/other/folder
    python3 dev/capture_prototype_reference.py --out docs/design/reference/s1-today \
        --pages "today,today@#tasks,today+devo,today+devo@end"

A page is a tab's data-page name. Two things may follow it:
- "+devo" opens today's reading from Today's devotional box;
- "@where" scrolls before the picture is taken: "@end" to the bottom, or
  "@" and a CSS selector to bring that element to the top.

Nothing in the repository is changed except the PNG files written to --out.
The preview is built in a temporary folder and deleted afterwards.

What the pictures are and are not:
- They show the prototype as it renders today: the date on Today is the day
  the script ran, and the mission line changes daily.
- Fonts come from Google Fonts over the network, as in the prototype. Offline,
  the browser falls back to system fonts and the pictures are not a reference.
- The mock runtime is not a backend. These are pictures of layout and color only.
"""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import urlencode

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SOURCE = "origin/app/v241-bold:versions/app-v254.html"   # decision Q1: v254 for layout
DEFAULT_OUT = "docs/design/reference/s0-shell"
WIDTH, HEIGHT = 390, 844
BROWSERS = (
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "google-chrome", "chromium", "chromium-browser", "msedge",
)

# Runs inside the page. Agrees to the legal gate, skips the setup wizard,
# opens the requested page, sets the theme, and scrolls to the top. It only
# clicks buttons a person would click; it does not touch the app's data.
BOOTSTRAP = r"""
<script>
(function () {
  var query = new URLSearchParams(location.search);
  var page = query.get("page") || "today", theme = query.get("theme") || "dark";
  var opens = query.get("open") || "", where = query.get("at") || "";
  var shown = function (el) { return !!(el && el.offsetParent !== null); };
  var buttons = function (root) { return Array.prototype.filter.call(root.querySelectorAll("button"), shown); };
  var named = function (root, re) { return buttons(root).filter(function (b) { return re.test(b.textContent.trim()); })[0]; };
  var polls = 0, quiet = 0;
  function next() {
    if (++polls > 120) return open();
    var agree = named(document, /^i agree$/i);
    if (agree) {
      var box = Array.prototype.filter.call(document.querySelectorAll("input[type=checkbox]"), shown)[0];
      if (box && !box.checked) box.click();
      agree.click(); quiet = 0; return setTimeout(next, 300);
    }
    var wizard = document.getElementById("onb") || document.querySelector(".onb, [id^=onb]");
    // The wizard covers the screen with a fixed layer, so test its buttons, not the layer.
    if (wizard && buttons(wizard).length) {
      var b = named(wizard, /go to today/i) || named(wizard, /skip/i) || named(wizard, /let.s get set up|^next$/i);
      if (b) { b.click(); quiet = 0; return setTimeout(next, 300); }
    }
    var busy = document.documentElement.classList.contains("boot") || !!document.getElementById("splash");
    quiet = busy ? 0 : quiet + 1;
    if (quiet < 8) return setTimeout(next, 300);   // nothing to click for a while: the app is ready
    open();
  }
  function open() {
    var tab = document.querySelector('.tabbar button[data-page="' + page + '"]');
    if (tab) tab.click();
    setTimeout(function () {
      document.documentElement.setAttribute("data-theme", theme);
      // The devotional box is the first row of Today's list.
      var row = opens === "devo" ? document.querySelector("#tasks li.item .hit") : null;
      if (row) row.click();
      setTimeout(place, row ? 600 : 0);
    }, 500);
  }
  function place() {
    var scroller = document.getElementById("scroll");
    if (!scroller) return;
    var target = where && where !== "end" ? document.querySelector(where) : null;
    scroller.scrollTop = where === "end" ? scroller.scrollHeight
      : target ? scroller.scrollTop + target.getBoundingClientRect().top - scroller.getBoundingClientRect().top - 12
      : 0;
    // The reading unlocks Amen from its scroll handler.
    scroller.dispatchEvent(new Event("scroll"));
  }
  window.addEventListener("load", function () { setTimeout(next, 500); });
})();
</script>
"""


def find_browser(explicit: str | None) -> str:
    for candidate in ([explicit] if explicit else []) + list(BROWSERS):
        if candidate and (Path(candidate).is_file() or shutil.which(candidate)):
            return candidate if Path(candidate).is_file() else shutil.which(candidate)
    raise SystemExit("No Chrome or Edge found. Pass --browser with the path to one.")


def prototype_html(source: str) -> str:
    done = subprocess.run(["git", "show", source], cwd=ROOT, capture_output=True)
    if done.returncode:
        raise SystemExit(f"Cannot read {source} from git: {done.stderr.decode(errors='replace').strip()}")
    return done.stdout.decode("utf-8")


# A desktop browser will not make a window as narrow as a phone, so the
# prototype is shown in a phone-sized frame at the top left of the window and
# the screenshot, which is cut to the requested size, shows exactly that frame.
FRAME = f"""<!doctype html><meta charset="utf-8"><body style="margin:0;background:#000">
<iframe id="phone" style="border:0;display:block;width:{WIDTH}px;height:{HEIGHT}px"></iframe>
<script>document.getElementById("phone").src = "preview.html" + location.search;</script>
"""


def build_preview(folder: Path, source: str) -> Path:
    shutil.copyfile(ROOT / "dev" / "mock-claude.js", folder / "mock-claude.js")
    (folder / "preview.html").write_text(
        '<meta charset="utf-8">\n<script src="mock-claude.js"></script>\n'
        + prototype_html(source) + BOOTSTRAP, encoding="utf-8")
    frame = folder / "frame.html"
    frame.write_text(FRAME, encoding="utf-8")
    return frame


def parse_view(spec: str) -> tuple[str, str, str, str]:
    """Split "today+devo@end" into page, what to open, where to scroll, and a file-name part."""
    rest, _, where = spec.partition("@")
    page, _, opens = rest.partition("+")
    label = "-".join(part for part in (page, opens, re.sub(r"[^a-z0-9]+", "-", where.lower()).strip("-")) if part)
    return page, opens, where, label


def capture(browser: str, page: Path, view: tuple[str, str, str, str], theme: str, target: Path, profile: Path) -> None:
    name, opens, where, _ = view
    url = page.as_uri() + "?" + urlencode({"page": name, "theme": theme, "open": opens, "at": where})
    command = [
        browser, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
        "--no-default-browser-check", f"--user-data-dir={profile}",
        f"--window-size={WIDTH},{HEIGHT}", "--force-device-scale-factor=1",
        # The page's own timers (splash, first-run screens) run on this clock.
        "--virtual-time-budget=60000", f"--screenshot={target}", url,
    ]
    done = subprocess.run(command, capture_output=True, text=True, timeout=180)
    if done.returncode or not target.is_file():
        raise SystemExit(f"Browser did not write {target.name}: {done.stderr.strip()[-400:]}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--source", default=DEFAULT_SOURCE,
                        help=f"git revision and path of the prototype file (default: {DEFAULT_SOURCE})")
    parser.add_argument("--pages", default="today,walk",
                        help="comma-separated data-page names from the prototype's tab bar, each optionally "
                             'followed by "+devo" and "@where" (default: today,walk)')
    parser.add_argument("--themes", default="dark,light", help="comma-separated: dark, light")
    parser.add_argument("--prefix", default="v254", help="start of each file name (default: v254)")
    parser.add_argument("--out", default=DEFAULT_OUT, help=f"folder for the PNG files (default: {DEFAULT_OUT})")
    parser.add_argument("--browser", help="path to Chrome or Edge, if it is not in a usual place")
    args = parser.parse_args()

    browser = find_browser(args.browser)
    out = (ROOT / args.out).resolve() if not Path(args.out).is_absolute() else Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="fs-prototype-capture-") as tmp:
        folder = Path(tmp)
        page = build_preview(folder, args.source)
        for view in [parse_view(p.strip()) for p in args.pages.split(",") if p.strip()]:
            for theme in [t.strip() for t in args.themes.split(",") if t.strip()]:
                target = out / f"{args.prefix}-{view[3]}-{theme}.png"
                # A fresh browser profile each time, so every picture starts from first run.
                capture(browser, page, view, theme, target, folder / f"profile-{view[3]}-{theme}")
                print(f"wrote {target.relative_to(ROOT) if target.is_relative_to(ROOT) else target}")
    print(f"source: {args.source}; size {WIDTH}x{HEIGHT}; browser: {browser}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
