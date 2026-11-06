#!/usr/bin/env python3
"""Rally composer: show a thumbnail of each attached photo or video instead of the file name (Curtis 2026-11-06).
Usage: patch_attthumb.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''.chip button { background: transparent; border: 0; color: var(--muted); padding: 4px; }''', '''.chip button { background: transparent; border: 0; color: var(--muted); padding: 4px; }
#file-chips { gap: 8px; padding-top: 8px; }
#file-chips:empty { display: none; }
.att-th { position: relative; width: 72px; height: 72px; flex: none; border: 1px solid var(--line); border-radius: 10px; overflow: hidden; background: #000; }
.att-th img, .att-th video { width: 100%; height: 100%; object-fit: cover; display: block; pointer-events: none; }
.att-th .att-play { position: absolute; left: 6px; bottom: 6px; width: 22px; height: 22px; border-radius: 50%; background: rgba(0,0,0,.6); display: grid; place-items: center; }
.att-th .att-play svg { width: 10px; height: 10px; fill: #fff; margin-left: 2px; }
.att-th .att-x { position: absolute; top: 4px; right: 4px; width: 24px; height: 24px; min-height: 0; padding: 0; border-radius: 50%; border: 0; background: rgba(0,0,0,.7); color: #fff; font-size: 14px; line-height: 1; display: grid; place-items: center; cursor: pointer; }
.att-th .att-doc { position: absolute; inset: 0; display: grid; place-items: center; padding: 4px; font-size: 10.5px; color: var(--muted); text-align: center; overflow: hidden; }''')
rep('''    var c = $("file-chips"); c.textContent = "";
    state.files.forEach(function (f, i) {
      var chip = el("span", "chip"); chip.appendChild(el("span", null, f.name));
      var x = el("button", null, "×"); x.type = "button"; x.setAttribute("aria-label", "Remove " + f.name);
      x.addEventListener("click", function () { state.files.splice(i, 1); drawChips(); }); chip.appendChild(x); c.appendChild(chip);
    });''', '''    var c = $("file-chips"); c.textContent = "";
    // Free preview URLs for files that are no longer attached.
    (c._urls || []).forEach(function (u) { if (!state.files.some(function (f) { return f.__thumb === u; })) { try { URL.revokeObjectURL(u); } catch (e) {} } });
    c._urls = [];
    state.files.forEach(function (f, i) {
      var isV = /^video\\//.test(f.type || ""), isI = /^image\\//.test(f.type || "");
      var tile = el("span", "att-th"); tile.setAttribute("role", "group"); tile.setAttribute("aria-label", (isV ? "Video" : isI ? "Photo" : "File") + " attached");
      if ((isV || isI) && !f.__thumb) { try { f.__thumb = URL.createObjectURL(f); } catch (e) {} }
      if (f.__thumb) c._urls.push(f.__thumb);
      if (isI && f.__thumb) { var im = el("img"); im.alt = ""; im.src = f.__thumb; tile.appendChild(im); }
      else if (isV && f.__thumb) {
        var vd = el("video"); vd.muted = true; vd.setAttribute("muted", ""); vd.playsInline = true; vd.setAttribute("playsinline", ""); vd.preload = "metadata"; vd.src = f.__thumb + "#t=0.1"; tile.appendChild(vd);
        var pl = el("span", "att-play"); pl.innerHTML = '<svg viewBox="0 0 10 10" aria-hidden="true"><path d="M0 0l10 5-10 5z"/></svg>'; tile.appendChild(pl);
      } else tile.appendChild(el("span", "att-doc", f.name || "File"));
      var x = el("button", "att-x", "×"); x.type = "button"; x.setAttribute("aria-label", "Remove " + (isV ? "video" : isI ? "photo" : f.name));
      x.addEventListener("click", function () { state.files.splice(i, 1); drawChips(); }); tile.appendChild(x); c.appendChild(tile);
    });''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
