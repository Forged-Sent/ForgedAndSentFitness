#!/usr/bin/env python3
"""Challenge proof: Upload a video sits beside Record as an equal choice. Usage: patch_chupload.py <in> <out> [version]"""
import sys, re
src, dst = sys.argv[1], sys.argv[2]; ver = sys.argv[3] if len(sys.argv) > 3 else None
s = open(src).read()
def rep(old, new, count=1):
    global s
    assert s.count(old) == count, ("anchor", old[:80], s.count(old))
    s = s.replace(old, new)

OLD_START = '        var rb = el("button", "ch-rec-btn"); rb.type = "button"; rb.disabled = F.busy || F.files.length >= 3;'
OLD_END = '        if (F.files.length < 3) { pc.appendChild(lab); pc.appendChild(el("p", "fnote ch-rec-cap", "Uploading instead? " + chalProofTip(c))); }\n'
i = s.index(OLD_START); j = s.index(OLD_END, i) + len(OLD_END)
old = s[i:j]
assert 'recordVideo(' in old and 'prepShareFile(file' in old
new = r'''        // Two equal ways in: film it here, or upload a video he already took with his phone camera.
        var CHMAX = 5, full = F.busy || F.files.length >= CHMAX, two = el("div", "ch-two");
        var rb = el("button", "ch-rec-btn"); rb.type = "button"; rb.disabled = full;
        rb.innerHTML = '<svg viewBox="0 0 24 16" aria-hidden="true"><rect x="0" y="1" width="16" height="14" rx="3"/><path d="M17 6l7-4v12l-7-4z"/></svg>';
        rb.appendChild(el("span", null, F.files.length ? "Record again" : "Record it"));
        rb.addEventListener("click", function () { recordVideo(timed || c.scoredBy === "most_rounds", async function (file) { F.busy = true; F.msg = "Preparing video…"; drawChallengePage(); var ready = await prepShareFile(file, function (t) { F.msg = t; var q = $("ch-msg"); if (q) q.textContent = t; }); if (ready) { F.files.push(ready); F.msg = B.downloads ? "Tip: tap Save to my phone to keep a copy in case the upload fails." : ""; proofKeep(c.id, F.files); } F.busy = false; drawChallengePage(); }); });
        two.appendChild(rb);
        function pickInto(lab, accept) {
          var fi = el("input"); fi.type = "file"; fi.accept = accept; fi.multiple = true; fi.hidden = true; fi.disabled = full; lab.appendChild(fi);
          fi.addEventListener("change", async function () {
            var list = Array.prototype.slice.call(fi.files || []); fi.value = ""; if (!list.length) return;
            var room = CHMAX - F.files.length, extra = list.length - room; if (room <= 0) return; list = list.slice(0, room);
            F.busy = true; F.msg = ""; drawChallengePage();
            for (var n = 0; n < list.length; n++) {
              var ready = await prepShareFile(list[n], function (t) { F.msg = t; var p = document.getElementById("ch-msg"); if (p) p.textContent = t; });
              if (ready) F.files.push(ready);
            }
            proofKeep(c.id, F.files); if (extra > 0) F.msg = "Up to " + CHMAX + " photos or videos. The first " + room + " were added.";
            F.busy = false; drawChallengePage();
          });
        }
        var ub = el("label", "ch-rec-btn ch-up-btn" + (full ? " off" : "")); ub.setAttribute("role", "button"); ub.tabIndex = full ? -1 : 0;
        ub.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 16V4M6.5 9.5 12 4l5.5 5.5"/><path d="M4 15v4a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-4"/></svg>';
        ub.appendChild(el("span", null, "Upload videos or photos")); pickInto(ub, "image/*,video/*");
        ub.addEventListener("keydown", function (ev) { if ((ev.key === "Enter" || ev.key === " ") && !full) { ev.preventDefault(); ub.querySelector("input").click(); } });
        two.appendChild(ub); pc.appendChild(two);
        pc.appendChild(el("p", "fnote ch-rec-cap", "Film it here, or upload videos and photos you already took. Pick several at once, up to " + CHMAX + " (videos up to 3 minutes each)."));
        if (F.files.length < CHMAX) pc.appendChild(el("p", "fnote ch-rec-cap", "Good proof: " + chalProofTip(c)));
'''
s = s[:i] + new + s[j:]

rep('.ch-rec-cap { margin: 0; }', '''.ch-rec-cap { margin: 0; }
.ch-two { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.ch-two .ch-rec-btn { flex-direction: column; gap: 6px; min-height: 92px; padding: 10px 8px; font-size: 17px; white-space: normal; text-align: center; line-height: 1.05; }
.ch-two .ch-up-btn { border-color: var(--line); color: var(--ink); }
.ch-two .ch-up-btn svg { width: 26px; height: 26px; fill: none; stroke: currentColor; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
.ch-two .ch-up-btn.off { opacity: .5; pointer-events: none; }''')

if ver:
    m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
