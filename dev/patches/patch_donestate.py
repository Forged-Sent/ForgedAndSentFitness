#!/usr/bin/env python3
"""Make "done" obvious for the no-points Sabbath items.
- Legacy log: after Save, the sheet switches to a clear confirmation card ("Saved for <who>", a preview, Write another /
  Done) and the new entry is tagged NEW in the log below.
- Today: Family report and Legacy log rows show a filled orange check box and a DONE tag once they are complete
  (report shared with the family; legacy written this week), with "No points, just leadership" in the sub line.
  The report now remembers that it was shared (freport[day].shared).
Usage: patch_donestate.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- Legacy log: confirmation card after saving
rep('''    var t = el("h2", null, F.edit ? "Edit your entry" : "Write it down for them."); t.id = "lg-t"; box.appendChild(t);
    box.appendChild(el("p", "note", "Private. Only you can see this. It is never scored and never shows on the Board. When you're ready, give it to them."));''',
'''    var savedMode = !!(F.saved && !F.edit && lg.e[F.saved]);
    var t = el("h2", null, savedMode ? "Saved to your legacy log." : F.edit ? "Edit your entry" : "Write it down for them."); t.id = "lg-t"; box.appendChild(t);
    if (!savedMode) box.appendChild(el("p", "note", "Private. Only you can see this. It is never scored and never shows on the Board. When you're ready, give it to them."));
    var c0 = box.childNodes.length;''')
rep('''      l2.e = e2; F.t = ""; F.edit = ""; F.off = 0; saveLegacyNow(l2); openLegacy({ msg: "Saved for " + e2[id].who + ". Only you can see it." });''',
    '''      l2.e = e2; F.t = ""; F.off = 0; F.saved = id; F.open = ""; F.edit = ""; saveLegacyNow(l2); drawAll(); openLegacy();''')
rep('''    box.appendChild(srow); box.appendChild(msg);
    // The log so far, by person''', '''    box.appendChild(srow); box.appendChild(msg);
    if (savedMode) {
      Array.prototype.slice.call(box.childNodes, c0).forEach(function (n) { n.remove(); });
      var se = lg.e[F.saved], card = el("div", "lg-saved");
      var ck = el("span", "lg-ck"); ck.innerHTML = CHECK_SVG; card.appendChild(ck);
      var ct = el("div", "lg-ct"); ct.appendChild(el("b", null, "Saved for " + se.who));
      ct.appendChild(el("p", "lg-prev", "\\u201C" + se.t.replace(/\\s+/g, " ").slice(0, 160) + (se.t.length > 160 ? "\\u2026" : "") + "\\u201D"));
      ct.appendChild(el("small", null, "Only you can see it. Give it to them when you\\u2019re ready.")); card.appendChild(ct); box.appendChild(card);
      var sb2 = el("div", "cdlg-btns lg-sbtns"), more = el("button", "btn ghost", "+ Write another"), dn = el("button", "btn", "Done"); more.type = dn.type = "button";
      more.addEventListener("click", function () { F.saved = ""; openLegacy(); });
      dn.addEventListener("click", function () { F.saved = ""; back.remove(); });
      sb2.appendChild(more); sb2.appendChild(dn); box.appendChild(sb2);
    }
    // The log so far, by person''')
rep('''          top.appendChild(el("span", "lg-d", shortDate(x.d))); top.appendChild(el("span", "lg-s", x.t.split(/\\n/)[0].slice(0, 70) + (x.t.length > 70 ? "\\u2026" : "")));''',
    '''          top.appendChild(el("span", "lg-d", shortDate(x.d))); top.appendChild(el("span", "lg-s", x.t.split(/\\n/)[0].slice(0, 70) + (x.t.length > 70 ? "\\u2026" : ""))); if (x.id === F.saved) { it.classList.add("lg-new"); top.appendChild(el("span", "lg-newtag", "New")); }''')
rep('''    cl.addEventListener("click", function () { back.remove(); }); back.addEventListener("click", function (ev) { if (ev.target === back) back.remove(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); back.remove(); } });
    back.appendChild(box); document.body.appendChild(back);
  }
  // Hand the entries''', '''    if (savedMode) row.remove();
    cl.addEventListener("click", function () { F.saved = ""; back.remove(); }); back.addEventListener("click", function (ev) { if (ev.target === back) { F.saved = ""; back.remove(); } });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); F.saved = ""; back.remove(); } });
    back.appendChild(box); document.body.appendChild(back);
  }
  // Hand the entries''')

# ---- Family report remembers it was shared
rep('''f[rw.key] = { line: saved.line.slice(0, 400), gideon: saved.gideon.slice(0, 800) };''', '''f[rw.key] = { line: saved.line.slice(0, 400), gideon: saved.gideon.slice(0, 800), shared: !!saved.shared };''')
rep('''    sh.addEventListener("click", function () { keep(); var txt = reportText(rw, st, saved);''', '''    sh.addEventListener("click", function () { saved.shared = true; keep(); drawAll(); var txt = reportText(rw, st, saved);''')

# ---- Today rows: done state
rep('''      fb.appendChild(el("span", "fr-ic", "\\u2709")); var ftx = el("span", "txt"); ftx.appendChild(el("span", "name", "Family report"));
      ftx.appendChild(el("span", "sub", ((state.settings.freport || {})[todayKey()] ? "Ready. Tap to review and share" : "Your week, ready to share with your family"))); fb.appendChild(ftx); fb.appendChild(el("span", "chev", "\\u203A"));''',
'''      var frx = (state.settings.freport || {})[todayKey()], frDone = !!(frx && frx.shared);
      if (frDone) { fb.classList.add("fr-done"); var fbx = el("span", "box"); fbx.innerHTML = CHECK_SVG; fb.appendChild(fbx); } else fb.appendChild(el("span", "fr-ic", "\\u2709"));
      var ftx = el("span", "txt"); ftx.appendChild(el("span", "name", "Family report"));
      ftx.appendChild(el("span", "sub", frDone ? "Shared with your family \\u00B7 No points, just leadership" : frx ? "Ready. Tap to review and share" : "Your week, ready to share with your family")); fb.appendChild(ftx);
      if (frDone) fb.appendChild(el("span", "pts fr-tag", "Done")); fb.appendChild(el("span", "chev", "\\u203A"));''')
rep('''      lb0.appendChild(el("span", "fr-ic", "\\u270D\\uFE0E")); var ltx = el("span", "txt"); ltx.appendChild(el("span", "name", "Legacy log"));
      ltx.appendChild(el("span", "sub", lw ? "Written this week \\u2713" : legacyPrompt(ln0, 0))); lb0.appendChild(ltx); lb0.appendChild(el("span", "chev", "\\u203A"));''',
'''      if (lw) { lb0.classList.add("fr-done"); var lbx = el("span", "box"); lbx.innerHTML = CHECK_SVG; lb0.appendChild(lbx); } else lb0.appendChild(el("span", "fr-ic", "\\u270D\\uFE0E"));
      var ltx = el("span", "txt"); ltx.appendChild(el("span", "name", "Legacy log"));
      ltx.appendChild(el("span", "sub", lw ? "Written this week \\u00B7 Tap to add another" : legacyPrompt(ln0, 0))); lb0.appendChild(ltx);
      if (lw) lb0.appendChild(el("span", "pts fr-tag", "Done")); lb0.appendChild(el("span", "chev", "\\u203A"));''')
rep('''.lg-ib { display: flex; gap: 8px; margin-bottom: 10px; }''', '''.lg-ib { display: flex; gap: 8px; margin-bottom: 10px; }
.lg-saved { display: grid; grid-template-columns: 40px minmax(0, 1fr); gap: 12px; align-items: start; margin: 8px 0 12px; padding: 14px; border: 1px solid var(--accent); border-radius: 10px; background: var(--surface); }
.lg-ck { width: 36px; height: 36px; border-radius: 50%; background: var(--accent); display: grid; place-items: center; }
.lg-ck svg { width: 20px; height: 20px; opacity: 1; stroke: var(--accent-ink, #111); stroke-width: 3; fill: none; stroke-linecap: square; }
.lg-ct b { font-family: var(--f-label); font-weight: 800; letter-spacing: .08em; text-transform: uppercase; font-size: 16px; }
.lg-prev { margin: 6px 0; font-size: 15px; line-height: 1.45; } .lg-ct small { color: var(--muted); font-size: 13px; }
.lg-sbtns .btn { flex: 1; }
.lg-new { background: color-mix(in srgb, var(--accent) 10%, transparent); border-radius: 6px; }
.lg-newtag { flex: none; align-self: center; padding: 1px 8px; border: 1px solid var(--accent); border-radius: 10px; color: var(--accent); font-family: var(--f-label); font-weight: 700; font-size: 11.5px; letter-spacing: .08em; text-transform: uppercase; }
.fr-li .fr-open.fr-done { border-style: solid; }
.fr-done .box { background: var(--accent); border-color: var(--accent); } .fr-done .box svg { opacity: 1; }
.fr-tag { color: var(--accent); }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
