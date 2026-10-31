#!/usr/bin/env python3
"""Post a challenge to Rally: after he submits, a Share with the brothers sheet opens (like after a workout) with a
challenge card (patch, week, name, result), a message he can edit, his proof included if he wants, plus selfie or
photo/video. "Post to Rally" is also on his latest submission so he can post later. Rally shows the challenge card.
Usage: patch_chalshare.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- posts keep a challenge card
rep('card: normCard(x.card), createdAt: Number(x.createdAt) || 0,', 'card: normCard(x.card), ch: normChCard(x.ch), createdAt: Number(x.createdAt) || 0,')

FN = r'''  /* Challenge card on a Rally post */
  function normChCard(c) {
    if (!c || typeof c !== "object" || !c.id) return null;
    return { id: String(c.id).slice(0, 30), slot: String(c.slot || "").slice(0, 12), week: Math.max(0, Math.min(99, Number(c.week) || 0)), name: String(c.name || "Challenge").slice(0, 60), res: String(c.res || "").slice(0, 40), mode: String(c.mode || "").slice(0, 12), gaunt: !!c.gaunt };
  }
  function chCardEl(cc, compact) {
    var f = chalFind(cc.id), c = f ? f.c : { slot: cc.slot, name: cc.name }, box = el("button", "chcard" + (compact ? "" : " big")); box.type = "button";
    var bd = el("span", "chc-b"); bd.innerHTML = chalBadgeSvg(c, f ? f.w.gauntlet : cc.gaunt); box.appendChild(bd);
    var tx = el("span", "chc-t");
    tx.appendChild(el("span", "chc-k", "Week " + cc.week + " · " + (chalSlot(cc.slot).label || cc.slot) + " challenge" + (cc.gaunt ? " · Gauntlet" : "")));
    tx.appendChild(el("span", "chc-n", cc.name));
    if (cc.res) tx.appendChild(el("span", "chc-r", cc.res + (cc.mode && cc.mode !== "Standard" ? " · " + cc.mode : "")));
    box.appendChild(tx);
    box.setAttribute("aria-label", "Open the " + cc.name + " challenge");
    box.addEventListener("click", function () { if (f) openChallenge(cc.id); });
    if (!f) box.disabled = true;
    return box;
  }
  function chShareText(c, a) {
    var nm = c.name.replace(/^Gauntlet:\s*/, "");
    if (c.scoredBy === "completion") return "Completed " + nm + " this week. Iron sharpens iron.";
    var r = chalResultText(c, a), m = a.mode === "standard" ? "" : " (" + chalModeLabel(a.mode) + ")";
    return r === "Completed" ? "Finished " + nm + m + ". Iron sharpens iron." : nm + m + ": " + r + ". Who's next? Iron sharpens iron.";
  }
  function openChalShare(c, w, a) {
    if (!state.me || !state.canWrite || !B.db || !a) return;
    var old = $("cdlg"); if (old) old.remove();
    var cc = normChCard({ id: c.id, slot: c.slot, week: w.week, name: c.name.replace(/^Gauntlet:\s*/, ""), res: chalResultText(c, a), mode: c.scoredBy === "completion" ? "" : chalModeLabel(a.mode), gaunt: w.gauntlet });
    var proof = (a.media || []).filter(function (m) { return m && m.id; }), useProof = proof.length > 0, file = null, url = "", busy = false;
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("form", "cdlg-box nw-box sh-box"); box.noValidate = true; box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "sh-t");
    var t = el("h2", null, "Share with the brothers"); t.id = "sh-t"; box.appendChild(t);
    var cardEl = chCardEl(cc, false); cardEl.disabled = true; box.appendChild(cardEl);
    var l = el("label", "flabel", "Message"), ta = el("textarea", "field"); ta.id = "sh-text"; ta.maxLength = 1000; ta.rows = 3; ta.value = chShareText(c, a);
    l.appendChild(ta); box.appendChild(l); fitSoon(ta);
    if (proof.length) {
      var pr = el("label", "chs-proof"), cb = el("input"); cb.type = "checkbox"; cb.checked = true;
      cb.addEventListener("change", function () { useProof = cb.checked; strip.hidden = !useProof; });
      pr.appendChild(cb); pr.appendChild(el("span", null, "Include my proof (" + proof.length + (proof.length === 1 ? " photo or video)" : " photos and videos)"))); box.appendChild(pr);
      var strip = el("div", "chs-strip");
      proof.slice(0, 6).forEach(function (m) { var th = el("span", "chs-th" + (m.type === "video" ? " vid" : "")); if (m.type !== "video") { var im = el("img"); im.alt = ""; im.src = "/_blob/" + m.id; th.appendChild(im); } else th.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l10.5-6.5z"/></svg>'; strip.appendChild(th); });
      box.appendChild(strip);
    }
    var prev = el("div", "sh-prev"); prev.hidden = true; box.appendChild(prev);
    var msg = el("p", "fnote"); box.appendChild(msg);
    function say(x) { msg.textContent = x || ""; }
    function showPrev() {
      prev.textContent = ""; prev.hidden = !file; if (!file) return;
      var isV = (file.type || "").indexOf("video") === 0, m = el(isV ? "video" : "img"); m.src = url; if (isV) { m.muted = true; m.playsInline = true; m.controls = true; } else m.alt = "Your photo";
      prev.appendChild(m);
      var x = el("button", "sh-x", "✕"); x.type = "button"; x.setAttribute("aria-label", "Remove photo or video");
      x.addEventListener("click", function () { if (url) try { URL.revokeObjectURL(url); } catch (e) {} file = null; url = ""; showPrev(); }); prev.appendChild(x);
    }
    function pick(accept, capture) {
      var inp = document.createElement("input"); inp.type = "file"; inp.accept = accept; if (capture) inp.setAttribute("capture", capture);
      inp.addEventListener("change", async function () {
        var f = inp.files && inp.files[0]; if (!f) return;
        var ready = await prepShareFile(f, say); if (!ready) return;
        if (url) try { URL.revokeObjectURL(url); } catch (e) {}
        file = ready; try { url = URL.createObjectURL(file); } catch (e) { url = ""; } showPrev();
      });
      inp.click();
    }
    var two = el("div", "sh-two"), sb = el("button", "btn ghost"), pb = el("button", "btn ghost"); sb.type = "button"; pb.type = "button";
    sb.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 8h4l2-3h6l2 3h4v12H3z"/><circle cx="12" cy="13.5" r="3.5"/></svg>'; sb.appendChild(document.createTextNode("Take selfie"));
    pb.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="1"/><path d="m3 16 5-5 4 4 3-3 6 6"/></svg>'; pb.appendChild(document.createTextNode("Photo/video"));
    var canUp = B.canUpload(); sb.disabled = !canUp; pb.disabled = !canUp;
    sb.addEventListener("click", function () { pick("image/*", "user"); });
    pb.addEventListener("click", function () { pick("image/*,video/*", ""); });
    two.appendChild(sb); two.appendChild(pb); box.appendChild(two);
    var post = el("button", "btn", "Post to Rally"); post.type = "submit"; box.appendChild(post);
    var no = el("button", "btn ghost", "Not now"); no.type = "button"; box.appendChild(no);
    function close() { if (url) try { URL.revokeObjectURL(url); } catch (e) {} back.remove(); }
    no.addEventListener("click", close);
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape" && !busy) close(); });
    async function send() {
      if (busy) return; busy = true; post.disabled = true; post.textContent = file ? "Uploading…" : "Posting…"; say("");
      try {
        var media = useProof ? proof.slice(0, 6).map(function (m) { return { id: m.id, type: m.type === "video" ? "video" : "image" }; }) : [];
        if (file) { var up = await B.upload(file); media.push({ id: up.id, type: (file.type || "").indexOf("video") === 0 ? "video" : "image" }); }
        await B.addPost({ uid: state.me, text: ta.value.trim().slice(0, 1000), media: media, mentions: [], ch: cc, createdAt: Date.now(), date: todayKey() });
        var ct = taskOfKind("checkin"); if (ct && !myDoc().done[ct.id]) toggle(ct.id);
        close(); go("checkin");
      } catch (e) {
        busy = false; post.disabled = false; post.textContent = "Post to Rally";
        say(file && e && e.code ? uploadErrText(e) : "Could not post. Check your connection and try again.");
      }
    }
    post.addEventListener("click", function (ev) { ev.preventDefault(); send(); });
    box.addEventListener("submit", function (ev) { ev.preventDefault(); send(); });
    back.appendChild(box); document.body.appendChild(back); post.focus();
  }
'''
rep('  function chalSave(id, attempts, msg) {', FN + '  function chalSave(id, attempts, msg) {')
# Rally shows the challenge card
rep('      if (p.card) card.appendChild(workoutCardEl(p.card, true));', '      if (p.card) card.appendChild(workoutCardEl(p.card, true));\n      if (p.ch) card.appendChild(chCardEl(p.ch, true));')
# open the share sheet right after a submit
rep('''      proofKeep(c.id, []); chalForm = null; chalAgain = null; chalSave(c.id, list, "Submitted. " + (c.scoredBy === "completion" || a.mode !== "standard" ? "Well done." : "Your best attempt counts."));''',
    '''      proofKeep(c.id, []); chalForm = null; chalAgain = null; chalSave(c.id, list, "Submitted. " + (c.scoredBy === "completion" || a.mode !== "standard" ? "Well done." : "Your best attempt counts."));
      openChalShare(c, w, a);''')
# and a Post to Rally button on his latest submission
rep('''        if (acts.childNodes.length) r.appendChild(acts);
        ps.appendChild(r);''', '''        if (ri === 0 && state.me && state.canWrite && B.db) { var shb = el("button", "mini ch-share-btn"); shb.type = "button"; shb.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v11H11l-5 4v-4H4z"/></svg>'; shb.appendChild(document.createTextNode("Post to Rally")); shb.addEventListener("click", function () { openChalShare(c, w, a); }); acts.insertBefore(shb, acts.firstChild); }
        if (acts.childNodes.length) r.appendChild(acts);
        ps.appendChild(r);''')
rep('.wcard.big { border-left-width: 1px; }', '''.wcard.big { border-left-width: 1px; }
.chcard { display: grid; grid-template-columns: 52px minmax(0, 1fr); gap: 12px; align-items: center; width: 100%; margin-top: 8px; padding: 10px 12px; text-align: left; color: inherit; font: inherit; border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: var(--radius, 4px); background: var(--surface); cursor: pointer; }
.chcard:disabled { cursor: default; opacity: 1; }
.chcard.big { grid-template-columns: 64px minmax(0, 1fr); border-left-width: 1px; }
.chcard .chc-b { width: 52px; height: 52px; } .chcard.big .chc-b { width: 64px; height: 64px; }
.chcard .chc-t { display: grid; gap: 2px; min-width: 0; }
.chcard .chc-k { font-family: var(--f-label); font-weight: 700; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--muted); }
.chcard .chc-n { font-family: var(--f-label); font-weight: 800; font-size: 18px; line-height: 1.1; text-transform: uppercase; overflow-wrap: anywhere; }
.chcard .chc-r { font-weight: 700; font-size: 15px; color: var(--accent); font-variant-numeric: tabular-nums; }
.chs-proof { display: flex; align-items: center; gap: 10px; margin: 2px 0; font-size: 15px; }
.chs-proof input { width: 22px; height: 22px; accent-color: var(--accent); }
.chs-strip { display: flex; gap: 6px; flex-wrap: wrap; }
.chs-th { width: 56px; height: 56px; border-radius: 4px; overflow: hidden; background: #000; display: grid; place-items: center; border: 1px solid var(--line); }
.chs-th img { width: 100%; height: 100%; object-fit: cover; }
.chs-th svg { width: 22px; height: 22px; fill: #fff; }
.ch-share-btn { display: inline-flex; align-items: center; gap: 5px; }
.ch-share-btn svg { width: 15px; height: 15px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linejoin: round; }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
