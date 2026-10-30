#!/usr/bin/env python3
"""Challenge page: standings move below the submission, and each man's name gets a proof icon that opens his submission.
Usage: patch_chproof.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# Standings go last on the page (the page is a flex column, so order moves it under Submit).
rep('      var stS = el("section", "ch-sec"); stS.appendChild(el("h2", "label-caps", "Standings"));',
    '      var stS = el("section", "ch-sec ch-stand"); stS.appendChild(el("h2", "label-caps", "Standings"));')
# proof icon beside the name in each standings row
rep('''          var who = el("div", "who"), nm = el("div", "nm", nameOf(r.uid)); if (r.uid === state.me) nm.appendChild(el("em", null, "YOU")); makeLink(nm, r.uid); who.appendChild(nm);''',
    '''          var who = el("div", "who"), nl = el("div", "ch-nmrow"), nm = el("div", "nm", nameOf(r.uid)); if (r.uid === state.me) nm.appendChild(el("em", null, "YOU")); makeLink(nm, r.uid); nl.appendChild(nm); chalProofBtn(nl, c, r.uid); who.appendChild(nl);''')
# Alternate / Scaled finishers listed by name, each with his proof icon
rep('''      var flats = rows.filter(function (r) { return r.flat; }).length; if (flats) stS.appendChild(el("p", "fnote", flats + (flats === 1 ? " man" : " men") + " completed the Alternate or Scaled version."));''',
    '''      var flatRows = rows.filter(function (r) { return r.flat; });
      if (flatRows.length) {
        stS.appendChild(el("div", "ch-flh", "Completed Alternate or Scaled"));
        var fl0 = el("div", "ch-flats");
        flatRows.forEach(function (r) { var fr = el("div", "ch-flat"), im = el("img", "avatar"); im.alt = ""; if (avatarSrc(r.uid)) im.src = avatarSrc(r.uid); makeLink(im, r.uid); fr.appendChild(im); var n2 = el("span", "nm", nameOf(r.uid)); makeLink(n2, r.uid); fr.appendChild(n2); if (r.uid === state.me) fr.appendChild(el("em", null, "YOU")); chalProofBtn(fr, c, r.uid); fl0.appendChild(fr); });
        stS.appendChild(fl0);
      }''')

# helpers: the icon and the viewer
HELP = r'''  /* ---------- Challenge proof viewer: tap the icon by a man's name to see what he submitted. ---------- */
  var CH_PROOF_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="2.5" y="5" width="19" height="14" rx="2.5"/><path d="M2.5 9.2h19M6.8 5l-1.6 4.2M11.8 5l-1.6 4.2M16.8 5l-1.6 4.2"/><path class="pl" d="M10.2 11.6v5.2l4.5-2.6z"/></svg>';
  function chalProofOf(c, uid) {
    var d = (state.chalAll || {})[uid], sub = d && d.subs && d.subs[c.id];
    return ((sub && sub.attempts) || []).filter(function (a) { return (a.media || []).some(function (m) { return m && safeId(m.id); }); });
  }
  function chalProofBtn(host, c, uid) {
    var list = chalProofOf(c, uid); if (!list.length) return;
    var n = list.reduce(function (t, a) { return t + a.media.length; }, 0);
    var b = el("button", "ch-pf"); b.type = "button"; b.innerHTML = CH_PROOF_ICON;
    b.setAttribute("aria-label", "See " + (uid === state.me ? "your" : nameOf(uid) + "’s") + " submission (" + n + (n === 1 ? " file" : " files") + ")");
    b.title = "See submission";
    b.addEventListener("click", function (ev) { ev.stopPropagation(); openChalProof(c, uid); });
    host.appendChild(b);
  }
  function openChalProof(c, uid) {
    var old = $("cdlg"); if (old) old.remove();
    var list = chalProofOf(c, uid).slice().reverse(), all = (((state.chalAll || {})[uid] || {}).subs || {})[c.id], best = null;
    if (chalRanked(c)) ((all && all.attempts) || []).forEach(function (a) { if (a.mode === "standard" && a.v > 0 && chalBetter(c.scoredBy, a, best)) best = a; });
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box chp-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "chp-t");
    var x = el("button", "dlg-x"); x.type = "button"; x.setAttribute("aria-label", "Close"); x.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>'; box.appendChild(x);
    var hd = el("div", "chp-hd"), im = el("img", "avatar"); im.alt = ""; if (avatarSrc(uid)) im.src = avatarSrc(uid); hd.appendChild(im);
    var tt = el("div"); var h = el("h2", null, uid === state.me ? "Your submission" : nameOf(uid) + "’s submission"); h.id = "chp-t"; tt.appendChild(h); tt.appendChild(el("span", "chp-c", c.name.replace(/^Gauntlet:\s*/, ""))); hd.appendChild(tt); box.appendChild(hd);
    list.forEach(function (a) {
      var card = el("div", "chp-att" + (a === best ? " best" : ""));
      var top = el("div", "chp-top"); top.appendChild(el("b", null, chalResultText(c, a)));
      top.appendChild(el("span", null, (c.scoredBy === "completion" ? "" : chalModeLabel(a.mode) + " · ") + new Date(a.at).toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" }) + (a === best && list.length > 1 ? " · Counts" : "")));
      card.appendChild(top);
      if (a.note) card.appendChild(el("p", "chp-note", "“" + a.note + "”"));
      var md = el("div", "chp-media");
      a.media.forEach(function (m, k) {
        if (!m || !safeId(m.id)) return; var src = "/_blob/" + safeId(m.id);
        if (m.type === "video") { var v = el("video"); v.controls = true; v.playsInline = true; v.preload = "metadata"; v.src = src; v.setAttribute("aria-label", "Proof video " + (k + 1)); md.appendChild(v); }
        else { var i2 = el("img"); i2.alt = "Proof photo " + (k + 1); i2.loading = "lazy"; i2.src = src; md.appendChild(i2); }
      });
      card.appendChild(md); box.appendChild(card);
    });
    function close() { back.querySelectorAll("video").forEach(function (v) { try { v.pause(); } catch (e) {} }); back.remove(); }
    x.addEventListener("click", close);
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back); try { x.focus({ preventScroll: true }); } catch (e) {}
  }
'''
rep('  function drawChallengePage() {', HELP + '  function drawChallengePage() {')

CSS = '''#chal-body .ch-stand { order: 1; }
.ch-nmrow { display: flex; align-items: center; gap: 8px; min-width: 0; }
.ch-nmrow .nm { min-width: 0; }
.ch-pf { flex: none; width: 30px; height: 30px; min-height: 0; padding: 0; display: grid; place-items: center; border: 1.5px solid var(--brass, var(--accent)); border-radius: 8px; background: color-mix(in srgb, var(--brass, var(--accent)) 12%, transparent); color: var(--brass, var(--accent)); cursor: pointer; }
.ch-pf svg { width: 19px; height: 19px; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
.ch-pf svg .pl { fill: currentColor; stroke: none; }
.ch-pf:hover, .ch-pf:focus-visible { background: color-mix(in srgb, var(--brass, var(--accent)) 24%, transparent); }
.ch-flh { margin: 14px 0 6px; font-family: var(--f-label); font-weight: 700; font-size: 12.5px; letter-spacing: .1em; text-transform: uppercase; color: var(--muted); }
.ch-flats { display: flex; flex-direction: column; border-top: 1px solid var(--line); }
.ch-flat { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--line); min-width: 0; }
.ch-flat .avatar { width: 32px; height: 32px; }
.ch-flat .nm { flex: 0 1 auto; min-width: 0; font-family: var(--f-label); font-weight: 700; font-size: 15px; letter-spacing: .04em; text-transform: uppercase; overflow-wrap: anywhere; }
.ch-flat em { font-style: normal; font-size: 12px; letter-spacing: .12em; color: var(--brass); }
.ch-flat .ch-pf { margin-left: auto; }
.chp-box { max-height: calc(var(--app-h, 100dvh) - 60px); overflow-y: auto; }
.chp-hd { display: flex; align-items: center; gap: 12px; padding-right: 40px; margin-bottom: 10px; }
.chp-hd h2 { margin: 0; }
.chp-hd .avatar { width: 44px; height: 44px; }
.chp-c { display: block; color: var(--muted); font-size: 13px; }
.chp-att { border-top: 1px solid var(--line); padding: 10px 0; display: flex; flex-direction: column; gap: 6px; }
.chp-att.best .chp-top b { color: var(--accent); }
.chp-top { display: flex; flex-wrap: wrap; align-items: baseline; gap: 4px 10px; }
.chp-top b { font-family: var(--f-label); font-size: 22px; }
.chp-top span { font-size: 13px; color: var(--muted); }
.chp-note { margin: 0; font-style: italic; font-size: 14px; }
.chp-media { display: flex; flex-direction: column; gap: 8px; }
.chp-media img, .chp-media video { width: 100%; max-height: 60vh; object-fit: contain; background: #000; border-radius: 8px; display: block; }
'''
rep('.ch-rec-cap { margin: 0; }', CSS + '.ch-rec-cap { margin: 0; }')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
