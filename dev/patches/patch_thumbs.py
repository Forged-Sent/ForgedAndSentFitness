#!/usr/bin/env python3
"""Challenge proof: picked photos and videos show as thumbnails. Usage: patch_thumbs.py <in> <out>"""
import sys
src, dst = sys.argv[1:3]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:80], s.count(old))
    s = s.replace(old, new)

rep('''          var chips = el("div", "chips");
          F.files.forEach(function (fl, k) { var ch = el("span", "chip ch-got", "✓ " + (fl.type.indexOf("video") === 0 ? "Video: " : "Photo: ") + (fl.name || "file")); var x = el("button", "mini", "✕"); x.type = "button"; x.setAttribute("aria-label", "Remove " + (fl.name || "file")); x.addEventListener("click", function () { F.files.splice(k, 1); proofKeep(c.id, F.files); drawChallengePage(); }); ch.appendChild(x); chips.appendChild(ch); });
          pc.appendChild(chips);''', '''          var chips = el("div", "ch-thumbs");
          F.files.forEach(function (fl, k) {
            var vid = (fl.type || "").indexOf("video") === 0, tile = el("div", "ch-th" + (vid ? " vid" : ""));
            try { if (!fl._u) fl._u = URL.createObjectURL(fl); } catch (e) {}
            if (vid) { var v = el("video"); v.muted = true; v.playsInline = true; v.controls = true; v.preload = "metadata"; if (fl._u) v.src = fl._u + "#t=0.1"; v.setAttribute("aria-label", "Your video " + (k + 1)); tile.appendChild(v); }
            else { var im = el("img"); im.alt = "Your photo " + (k + 1); if (fl._u) im.src = fl._u; tile.appendChild(im); }
            var x = el("button", "ch-th-x", "\\u2715"); x.type = "button"; x.setAttribute("aria-label", "Remove " + (vid ? "video " : "photo ") + (k + 1));
            x.addEventListener("click", function () { try { if (fl._u) URL.revokeObjectURL(fl._u); } catch (e) {} F.files.splice(k, 1); proofKeep(c.id, F.files); drawChallengePage(); });
            tile.appendChild(x); chips.appendChild(tile);
          });
          pc.appendChild(chips);''')
rep('.ch-two { display: grid;', '''.ch-thumbs { display: grid; grid-template-columns: repeat(auto-fill, minmax(96px, 1fr)); gap: 8px; }
.ch-th { position: relative; aspect-ratio: 1 / 1; border: 1px solid var(--line); border-radius: 8px; overflow: hidden; background: #000; }
.ch-th img, .ch-th video { width: 100%; height: 100%; object-fit: cover; display: block; }
.ch-th.vid video { object-fit: contain; }
.ch-th-x { position: absolute; top: 4px; right: 4px; width: 30px; height: 30px; min-height: 0; padding: 0; border: 0; border-radius: 50%; background: rgba(0,0,0,.65); color: #fff; font-size: 14px; display: grid; place-items: center; z-index: 2; }
.ch-two { display: grid;''')
open(dst, 'w').write(s); print('ok', dst)
