#!/usr/bin/env python3
"""Owner settings: Save campaign now shows it worked. The save already went through, but the page redrew as soon as the
new settings came back and wiped the "Saved" line, so it looked like nothing happened. The button now says Saving...,
and the confirmation (with what the brothers will see) stays on screen after the redraw.
Usage: patch_ownsave.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('  function drawCampOwner() {', '  var ownMsg = { t: "", at: 0 };\n  function drawCampOwner() {')
rep('''    var ok = el("p", "note ok"); ok.hidden = true; f.appendChild(ok);
    var sv = el("button", "btn", "Save campaign"); sv.type = "submit"; f.appendChild(sv);''',
    '''    var ok = el("p", "own-ok"); ok.setAttribute("role", "status"); ok.hidden = !(ownMsg.t && Date.now() - ownMsg.at < 15000); ok.textContent = ownMsg.t; f.appendChild(ok);
    var sv = el("button", "btn own-save", "Save campaign"); sv.type = "submit"; f.appendChild(sv);''')
rep('''      B.saveCamp("current", o).then(function () { ok.textContent = "Saved."; ok.hidden = false; }).catch(function () { err.textContent = "That didn’t save. Only the app’s owner can change campaigns."; err.hidden = false; });''',
    '''      sv.disabled = true; sv.textContent = "Saving\\u2026";
      var ph2 = campPhase(o), msg = "\\u2713 Saved. " + (ph2 === "signup" ? "Sign-ups are open now. The brothers see the campaign on Today." : ph2 === "soon" ? "Sign-ups open " + longDate(o.signup) + "." : ph2 === "live" ? "The campaign is underway." : "") + " Starts " + longDate(o.start) + ".";
      B.saveCamp("current", o).then(function () { ownMsg = { t: msg, at: Date.now() }; sv.disabled = false; sv.textContent = "Save campaign"; var live = document.querySelector("#s-owner .own-ok") || ok; live.textContent = msg; live.hidden = false; var b2 = document.querySelector("#s-owner .own-save"); if (b2) { b2.disabled = false; b2.textContent = "Save campaign"; } setTimeout(function () { ownMsg.t = ""; var o2 = document.querySelector("#s-owner .own-ok"); if (o2) o2.hidden = true; }, 15000); })
        .catch(function () { sv.disabled = false; sv.textContent = "Save campaign"; err.textContent = "That didn\\u2019t save. Only the app\\u2019s owner can change campaigns."; err.hidden = false; });''')
rep('#s-owner .btn { width: 100%; margin-top: 8px; }', '#s-owner .btn { width: 100%; margin-top: 8px; }\n.own-ok { margin: 4px 0 0; padding: 10px 12px; border: 1px solid var(--accent); border-radius: 8px; color: var(--ink); font-weight: 600; }')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
