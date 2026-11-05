#!/usr/bin/env python3
"""Paul & Timothy mentoring (stage 1). Decided by Curtis 2026-11-02:
- Pairs can form any time. A brother who invited you is automatically your Paul (both sides), unless either ended it.
- Any brother can ask another to be his Paul, or to be his Timothy; the other accepts or declines. Either can end it.
- The owner sees every pair in Owner tools and can assign or clear a brother's Paul.
- Weekly check-in, stage 1: how the week went (Strong / Steady / Struggling), a prayer request line and "I need to
  talk". Only the Paul is shown it in the app, but the prototype can't lock it to him, so sensitive questions and a
  private thread wait for Firebase (logged).
Data: mentor/{uid} = { paul, timothys[], declined[], share{}, chk{week:{at,how,pray,talk}}, nudged{timothyUid: at} } (each brother writes only his own doc; a Paul's nudge lives in his doc).
A pair is active when both sides name each other. Usage: patch_mentor.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

rep('''    <div class="cmp-today-wrap" id="camp-today" hidden></div>''', '''    <div class="cmp-today-wrap" id="camp-today" hidden></div>
    <div id="mentor-today"></div>''')
rep('''  <div class="page" id="page-owner" hidden>''', '''  <div class="page" id="page-mentor" hidden>
    <div class="pbar">
      <button class="mini" type="button" id="men-back">&lsaquo; Today</button>
      <span class="date label-caps">Iron sharpens iron</span>
    </div>
    <h1 class="pg">Paul &amp; Timothy</h1>
    <div id="men-body"></div>
  </div>

  <div class="page" id="page-owner" hidden>''')
rep('''    <section aria-labelledby="h-o-rep">''', '''    <section aria-labelledby="h-o-pairs">
      <div class="section-head"><h2 class="label-caps" id="h-o-pairs" data-sub="Who is walking with whom. Assign or clear a brother’s Paul.">Paul &amp; Timothy pairs</h2></div>
      <div id="o-pairs"></div>
    </section>

    <section aria-labelledby="h-o-rep">''')
rep('''"h-s-legal", "h-s-acct", "h-o-rep"].forEach''', '''"h-s-legal", "h-s-acct", "h-o-rep", "h-o-pairs"].forEach''')
rep('''"chal", "ideas", "team", "camp", "owner"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''', '''"chal", "ideas", "team", "camp", "owner", "mentor"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''')
rep('''p === "ideas" ? "fuel" : p === "team"''', '''p === "ideas" ? "fuel" : p === "mentor" ? "today" : p === "team"''')
rep('''    if (p === "owner") { ownerWatch(); drawOwner(); }''', '''    if (p === "owner") { ownerWatch(); drawOwner(); drawOwnerPairs(); }
    if (p === "mentor") drawMentorPage();''')
rep('''    drawDevo(); if (state.page === "camp") drawCampPage();''', '''    drawDevo(); if (state.page === "camp") drawCampPage(); drawMentorToday(); if (state.page === "mentor") drawMentorPage(); if (state.page === "owner") drawOwnerPairs();''')
rep('''    B.watchProfiles(function (map) { state.pubProfiles = map; drawAll(); loadProfiles(); });''', '''    B.watchProfiles(function (map) { state.pubProfiles = map; drawAll(); loadProfiles(); });
    try { B.db.collection("mentor").onSnapshot(function (s) { var m = {}; s.docs.forEach(function (d) { m[d.id] = normMentor(d.data()); }); state.mentor = m; state.mentorLoaded = true; mentorAuto(); drawAll(); }, noop); } catch (e) {}''')
rep('''    $("own-back").addEventListener("click", function () { go("settings"); });''', '''    $("own-back").addEventListener("click", function () { go("settings"); });
    $("men-back").addEventListener("click", function () { go("today"); });''')

JS = r'''
  /* ---------- Paul & Timothy mentoring ---------- */
  var MEN_HOW = [["strong", "Strong"], ["steady", "Steady"], ["struggling", "Struggling"]];
  function uidOk(u) { return /^[A-Za-z0-9_-]{1,80}$/.test(String(u || "")); }
  function normMentor(x) {
    x = x || {}; var arr = function (a) { return (Array.isArray(a) ? a : []).filter(uidOk).slice(0, 40); };
    var chk = {}; if (x.chk && typeof x.chk === "object") Object.keys(x.chk).sort().slice(-12).forEach(function (k) { var c = x.chk[k] || {}; if (/^\d{4}-\d{2}-\d{2}$/.test(k)) chk[k] = { at: Number(c.at) || 0, how: ["strong", "steady", "struggling"].indexOf(c.how) >= 0 ? c.how : "", pray: String(c.pray || "").slice(0, 280), talk: !!c.talk }; });
    var sh = x.share && typeof x.share === "object" ? x.share : {};
    return { paul: uidOk(x.paul) ? String(x.paul) : "", timothys: arr(x.timothys), declined: arr(x.declined), share: { stats: sh.stats !== false, checkin: sh.checkin !== false }, chk: chk, nudged: (function () { var o = {}; if (x.nudged && typeof x.nudged === "object") Object.keys(x.nudged).forEach(function (k) { if (uidOk(k)) o[k] = Number(x.nudged[k]) || 0; }); return o; })() };
  }
  function menOf(u) { return (state.mentor || {})[u] || normMentor({}); }
  function menSave(u, m) { (state.mentor = state.mentor || {})[u] = m; return B.db.doc("mentor/" + u).set(JSON.parse(JSON.stringify(m))).catch(noop); }
  function pairOn(p, t) { return !!p && !!t && p !== t && menOf(t).paul === p && menOf(p).timothys.indexOf(t) >= 0; }
  function myPaul() { var me = state.me, p = menOf(me).paul; return p && pairOn(p, me) ? p : ""; }
  function myTimothys() { var me = state.me; return menOf(me).timothys.filter(function (t) { return pairOn(me, t); }); }
  function menWeek() { return mondayKey(todayKey()); }
  // Requests waiting on me: brothers who named me as Paul (I haven't added them), or added me as Timothy (I haven't named them).
  function menRequests() {
    var me = state.me, M = state.mentor || {}, mine = menOf(me), out = [];
    Object.keys(M).forEach(function (u) { if (u === me) return; var m = M[u];
      if (m.paul === me && mine.timothys.indexOf(u) < 0 && mine.declined.indexOf(u) < 0) out.push({ uid: u, role: "timothy" });
      if (m.timothys.indexOf(me) >= 0 && mine.paul !== u && mine.declined.indexOf(u) < 0) out.push({ uid: u, role: "paul" }); });
    return out;
  }
  // A brother you invited is your Timothy automatically (both sides), unless either of you ended it.
  function mentorAuto() {
    var me = state.me; if (!me || !state.canWrite || !state.mentorLoaded || !B.db) return;
    var mine = menOf(me), changed = false, P = state.pubProfiles || {}, inv = (P[me] || {}).invitedBy;
    var m2 = JSON.parse(JSON.stringify(mine));
    if (!m2.paul && uidOk(inv) && m2.declined.indexOf(inv) < 0 && menOf(inv).declined.indexOf(me) < 0) { m2.paul = inv; changed = true; }
    Object.keys(P).forEach(function (u) { if (u === me || (P[u] || {}).invitedBy !== me) return; var t = menOf(u);
      if ((t.paul === me || !t.paul) && m2.timothys.indexOf(u) < 0 && m2.declined.indexOf(u) < 0 && t.declined.indexOf(me) < 0) { m2.timothys.push(u); changed = true; } });
    if (changed) menSave(me, m2);
  }
  function menStats(u) {
    var dt = devoTask(), wt = taskOfKind("workout"), t = todayKey(), o = { devo: 0, wk: 0, days: 0 };
    for (var i = 0; i < 7; i++) { var k = addDays(t, -i), r = (state.checks || []).filter(function (c) { return c.uid === u && c.date === k; })[0]; if (!r) continue; o.days++; if (dt && r.done[dt.id]) o.devo++; if (wt && r.done[wt.id]) o.wk++; }
    return o;
  }
  function menAv(u) { var a = el("span", "men-av"); var src = avatarSrc(u); if (src) { var im = el("img"); im.alt = ""; im.src = src; a.appendChild(im); } else a.textContent = String(nameOf(u) || "?").charAt(0).toUpperCase(); return a; }
  function menRow(u, sub, tag, tagCls, onClick) {
    var b = el("button", "men-row"); b.type = "button"; b.appendChild(menAv(u));
    var tx = el("span", "men-tx"); tx.appendChild(el("b", null, nameOf(u))); tx.appendChild(el("small", null, sub)); b.appendChild(tx);
    if (tag) b.appendChild(el("span", "men-tag " + (tagCls || ""), tag)); if (onClick) b.addEventListener("click", onClick); return b;
  }
  function timStatus(t) { var c = menOf(t).chk[menWeek()]; if (c && c.talk) return ["Asked to talk", "Reach out", "hot"]; if (c) return ["Checked in " + new Date(c.at).toLocaleDateString(undefined, { weekday: "short" }), "✓ Done", "ok"]; return ["No check-in yet this week", "", ""]; }
  function drawMentorToday() {
    var box = $("mentor-today"); if (!box) return; box.textContent = ""; if (!state.me || !state.mentorLoaded) return;
    var me = state.me, p = myPaul(), ts = myTimothys(), req = menRequests(), mine = menOf(me), wk = mine.chk[menWeek()];
    var card = el("section", "men-card"); card.appendChild(el("div", "label-caps men-k", "Walk with your brothers"));
    var nAt = p ? (menOf(p).nudged || {})[me] || 0 : 0; if (nAt && Date.now() - nAt < 3 * 86400000) card.appendChild(el("p", "men-nudge", nameOf(p) + " is checking on you, brother."));
    if (p) card.appendChild(menRow(p, wk ? "You checked in this week" : "Your Paul · weekly check-in due by Sunday", wk ? "✓ Done" : "Check in", wk ? "ok" : "acc", function () { state.menView = ""; state.menCheck = !wk; go("mentor"); }));
    ts.forEach(function (t) { var st = timStatus(t); card.appendChild(menRow(t, "Your Timothy · " + st[0], st[1], st[2], function () { state.menView = t; go("mentor"); })); });
    if (req.length) card.appendChild(menRow(req[0].uid, req[0].role === "timothy" ? "Asked you to be his Paul" : "Asked to be your Paul", req.length > 1 ? req.length + " requests" : "Answer", "acc", function () { state.menView = ""; go("mentor"); }));
    if (!p && !ts.length && !req.length) { var e = el("button", "men-empty"); e.type = "button"; e.appendChild(el("b", null, "Find a Paul. Walk with a Timothy.")); e.appendChild(el("small", null, "A Paul walks with a newer brother. Tap to start.")); e.addEventListener("click", function () { state.menView = ""; go("mentor"); }); card.appendChild(e); }
    box.appendChild(card);
  }
  function menPick(title, exclude, onPick) {
    var old = $("cdlg"); if (old) old.remove(); var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box men-pick"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true");
    box.appendChild(el("h2", null, title)); var q = el("input", "field"); q.type = "search"; q.placeholder = "Search brothers"; q.setAttribute("aria-label", "Search brothers"); box.appendChild(q);
    var list = el("div", "men-plist"); box.appendChild(list);
    function paint() { list.textContent = ""; var term = q.value.trim().toLowerCase();
      Object.keys(state.pubProfiles || {}).filter(function (u) { return u !== state.me && exclude.indexOf(u) < 0 && (!term || String(nameOf(u)).toLowerCase().indexOf(term) >= 0); }).sort(function (a, b) { return String(nameOf(a)).localeCompare(String(nameOf(b))); }).slice(0, 60)
        .forEach(function (u) { list.appendChild(menRow(u, "@" + (((state.pubProfiles[u] || {}).handle) || ""), "Ask", "acc", function () { back.remove(); onPick(u); })); }); }
    q.addEventListener("input", paint); paint();
    var cl = el("button", "btn ghost", "Cancel"); cl.type = "button"; cl.addEventListener("click", function () { back.remove(); }); box.appendChild(cl);
    back.appendChild(box); back.addEventListener("click", function (ev) { if (ev.target === back) back.remove(); }); document.body.appendChild(back); q.focus();
  }
  function menEnd(other, iAmPaul) {
    confirmDelete({ neutral: true, title: "End this pairing?", message: "You and " + nameOf(other) + " will no longer be paired. You can pair again later.", yes: "End it" }, function () {
      var m = JSON.parse(JSON.stringify(menOf(state.me)));
      if (iAmPaul) m.timothys = m.timothys.filter(function (x) { return x !== other; }); else if (m.paul === other) m.paul = "";
      if (m.declined.indexOf(other) < 0) m.declined.push(other); menSave(state.me, m).then(function () { state.menView = ""; drawAll(); });
    });
  }
  function drawMentorPage() {
    var box = $("men-body"); if (!box) return; box.textContent = ""; var me = state.me; if (!me) return;
    var mine = menOf(me), p = myPaul(), ts = myTimothys(), req = menRequests(), off = !state.canWrite;
    var view = state.menView;
    if (view && pairOn(me, view)) { drawTimothy(box, view); return; }
    box.appendChild(el("p", "note", "A Paul walks with a newer brother (2 Timothy 2:2). A Timothy is the brother you walk with. One Paul, a few Timothys."));
    if (req.length) { var rs = el("section", "men-sec"); rs.appendChild(el("h2", "label-caps", "Requests"));
      req.forEach(function (r) { var row = el("div", "men-req"); row.appendChild(menAv(r.uid)); var tx = el("span", "men-tx"); tx.appendChild(el("b", null, nameOf(r.uid))); tx.appendChild(el("small", null, r.role === "timothy" ? "Asked you to be his Paul" : "Asked to be your Paul")); row.appendChild(tx);
        var a = el("button", "mini on", "Accept"), d = el("button", "mini", "Decline"); a.type = d.type = "button"; a.disabled = d.disabled = off;
        a.addEventListener("click", function () { var m = JSON.parse(JSON.stringify(menOf(me))); if (r.role === "timothy") { if (m.timothys.indexOf(r.uid) < 0) m.timothys.push(r.uid); } else m.paul = r.uid; menSave(me, m).then(drawAll); });
        d.addEventListener("click", function () { var m = JSON.parse(JSON.stringify(menOf(me))); if (m.declined.indexOf(r.uid) < 0) m.declined.push(r.uid); menSave(me, m).then(drawAll); });
        row.appendChild(a); row.appendChild(d); rs.appendChild(row); });
      box.appendChild(rs); }
    // My Paul + weekly check-in
    var ps = el("section", "men-sec"); ps.appendChild(el("h2", "label-caps", "My Paul"));
    if (p) {
      ps.appendChild(menRow(p, (((state.pubProfiles || {})[me] || {}).invitedBy === p ? "Invited you · " : "") + "Walking with you", "End", "", function () { menEnd(p, false); }));
      var wk = menWeek(), c = mine.chk[wk] || null, f = el("div", "men-chk"); f.appendChild(el("div", "label-caps men-k", "Weekly check-in · week of " + shortDate(wk)));
      f.appendChild(el("p", "men-priv", "🔒︎ Shown only to " + nameOf(p) + " in the app. Keep details for your conversation; private written check-ins come with the next version of the app."));
      var S = state.menDraft = state.menDraft && state.menDraft.wk === wk ? state.menDraft : { wk: wk, how: c ? c.how : "", pray: c ? c.pray : "", talk: c ? c.talk : false };
      f.appendChild(el("b", "men-q", "How was your week?")); var hw = el("div", "men-how");
      MEN_HOW.forEach(function (h) { var b = el("button", "mini" + (S.how === h[0] ? " on" : ""), h[1]); b.type = "button"; b.setAttribute("aria-pressed", String(S.how === h[0])); b.disabled = off; b.addEventListener("click", function () { S.how = h[0]; drawMentorPage(); }); hw.appendChild(b); }); f.appendChild(hw);
      f.appendChild(el("b", "men-q", "How can " + nameOf(p) + " pray for you?")); var pr = el("input", "field"); pr.maxLength = 280; pr.placeholder = "One line is enough"; pr.value = S.pray; pr.disabled = off; pr.addEventListener("input", function () { S.pray = pr.value; }); f.appendChild(pr);
      var tl = el("label", "men-talk"), cb = el("input"); cb.type = "checkbox"; cb.checked = S.talk; cb.disabled = off; cb.addEventListener("change", function () { S.talk = cb.checked; }); tl.appendChild(cb); var tt = el("span"); tt.appendChild(el("b", null, "I need to talk")); tt.appendChild(el("small", null, nameOf(p) + " gets a nudge to reach out today")); tl.appendChild(tt); f.appendChild(tl);
      if (c) f.appendChild(el("p", "men-sent", "\u2713 Sent to " + nameOf(p) + " " + new Date(c.at).toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" }) + ". You can update it until Sunday."));
      var sv = el("button", "btn", c ? "Update check-in" : "Send to " + nameOf(p)); sv.type = "button"; sv.disabled = off;
      var msg = el("p", "note"); msg.setAttribute("role", "status");
      sv.addEventListener("click", function () { if (!S.how) { msg.textContent = "Pick how your week went first."; return; } var m = JSON.parse(JSON.stringify(menOf(me))); m.chk[wk] = { at: Date.now(), how: S.how, pray: String(S.pray || "").trim().slice(0, 280), talk: !!S.talk }; menSave(me, m).then(function () { state.menCheck = false; msg.textContent = "✓ Sent to " + nameOf(p) + "."; drawMentorToday(); }); });
      f.appendChild(sv); f.appendChild(msg); ps.appendChild(f);
      if (state.menCheck) setTimeout(function () { f.scrollIntoView({ block: "start", behavior: "smooth" }); }, 60);
    } else {
      var pend = mine.paul && !pairOn(mine.paul, me) ? mine.paul : "";
      if (pend) ps.appendChild(menRow(pend, "Waiting for him to accept", "Cancel", "", function () { var m = JSON.parse(JSON.stringify(menOf(me))); m.paul = ""; menSave(me, m).then(drawAll); }));
      else { var ab = el("button", "btn ghost men-wide", "Ask a brother to be your Paul"); ab.type = "button"; ab.disabled = off; ab.addEventListener("click", function () { menPick("Who should be your Paul?", ts, function (u) { var m = JSON.parse(JSON.stringify(menOf(me))); m.paul = u; m.declined = m.declined.filter(function (x) { return x !== u; }); menSave(me, m).then(drawAll); }); }); ps.appendChild(ab); }
    }
    box.appendChild(ps);
    // My Timothys
    var tsec = el("section", "men-sec"); tsec.appendChild(el("h2", "label-caps", "My Timothys · " + ts.length));
    ts.forEach(function (t) { var st = timStatus(t); tsec.appendChild(menRow(t, st[0], st[1] || "Open", st[2], function () { state.menView = t; drawMentorPage(); })); });
    mine.timothys.filter(function (t) { return !pairOn(me, t); }).forEach(function (t) { tsec.appendChild(menRow(t, "Waiting for him to accept", "Cancel", "", function () { var m = JSON.parse(JSON.stringify(menOf(me))); m.timothys = m.timothys.filter(function (x) { return x !== t; }); menSave(me, m).then(drawAll); })); });
    var at = el("button", "btn ghost men-wide", "Ask a brother to be your Timothy"); at.type = "button"; at.disabled = off;
    at.addEventListener("click", function () { menPick("Who will you walk with?", mine.timothys.concat(p ? [p] : []), function (u) { var m = JSON.parse(JSON.stringify(menOf(me))); if (m.timothys.indexOf(u) < 0) m.timothys.push(u); m.declined = m.declined.filter(function (x) { return x !== u; }); menSave(me, m).then(drawAll); }); });
    tsec.appendChild(at); tsec.appendChild(el("p", "fnote", "Brothers you invite become your Timothys automatically.")); box.appendChild(tsec);
  }
  function drawTimothy(box, t) {
    var tm = menOf(t), c = tm.chk[menWeek()], st = menStats(t), back = el("button", "mini", "‹ Paul & Timothy"); back.type = "button"; back.addEventListener("click", function () { state.menView = ""; drawMentorPage(); }); box.appendChild(back);
    var hd = el("div", "men-head"); hd.appendChild(menAv(t)); var ht = el("span"); ht.appendChild(el("span", "label-caps men-k", "Your Timothy")); ht.appendChild(el("h2", "men-name", nameOf(t))); hd.appendChild(ht); box.appendChild(hd);
    if (c && c.talk) box.appendChild(el("div", "men-alert", nameOf(t) + " asked to talk. Reach out today: call or text him from your phone."));
    if (tm.share.stats) { var g = el("div", "men-stats"); [[st.days + "/7", "Days checked in"], [st.devo + "/7", "Devotional"], [String(st.wk), "Workouts"]].forEach(function (x) { var d = el("div"); d.appendChild(el("b", null, x[0])); d.appendChild(el("small", null, x[1])); g.appendChild(d); }); box.appendChild(g); }
    var cc = el("div", "men-chk"); cc.appendChild(el("div", "label-caps men-k", "Check-in · week of " + shortDate(menWeek())));
    if (c) { cc.appendChild(el("p", "men-howv", "Week: " + ((MEN_HOW.filter(function (h) { return h[0] === c.how; })[0] || ["", "—"])[1]))); if (c.pray) cc.appendChild(el("p", "men-quote", "Prayer request: " + c.pray)); }
    else cc.appendChild(el("p", "note", "No check-in yet this week."));
    box.appendChild(cc);
    var sentN = Date.now() - ((menOf(state.me).nudged || {})[t] || 0) < 86400000;
    var nb = el("button", "btn men-wide", sentN ? "\u2713 Nudge sent today" : "Send “Checking on you, brother”"); nb.type = "button"; nb.disabled = !state.canWrite || sentN;
    var nm = el("p", "note"); nm.setAttribute("role", "status");
    nb.addEventListener("click", function () { var m = JSON.parse(JSON.stringify(menOf(state.me))); m.nudged = m.nudged || {}; m.nudged[t] = Date.now(); menSave(state.me, m).then(function () { drawAll(); }); });
    box.appendChild(nb); box.appendChild(nm);
    var en = el("button", "linkish men-end", "End this pairing"); en.type = "button"; en.addEventListener("click", function () { menEnd(t, true); }); box.appendChild(en);
  }
  function drawOwnerPairs() {
    var box = $("o-pairs"); if (!box || !state.isOwner) return; box.textContent = ""; var M = state.mentor || {}, pairs = [], pend = [];
    Object.keys(M).forEach(function (t) { var p = M[t].paul; if (!p) return; (pairOn(p, t) ? pairs : pend).push([p, t]); });
    Object.keys(M).forEach(function (p) { M[p].timothys.forEach(function (t) { if (!pairOn(p, t)) pend.push([p, t]); }); });
    if (!pairs.length) box.appendChild(el("p", "note", "No pairs yet."));
    var byP = {}; pairs.forEach(function (x) { (byP[x[0]] = byP[x[0]] || []).push(x[1]); });
    Object.keys(byP).sort(function (a, b) { return String(nameOf(a)).localeCompare(String(nameOf(b))); }).forEach(function (p) { var r = el("div", "o-pair"); r.appendChild(el("b", null, nameOf(p))); r.appendChild(el("span", null, "Paul to " + byP[p].map(nameOf).join(", "))); box.appendChild(r); });
    if (pend.length) { box.appendChild(el("p", "fnote", "Waiting to accept: " + pend.map(function (x) { return nameOf(x[0]) + " → " + nameOf(x[1]); }).filter(function (v, i, a) { return a.indexOf(v) === i; }).join(" · "))); }
    var asg = el("div", "o-assign"); asg.appendChild(el("div", "label-caps men-k", "Assign a Paul"));
    var ids = Object.keys(state.pubProfiles || {}).sort(function (a, b) { return String(nameOf(a)).localeCompare(String(nameOf(b))); });
    function sel(lbl) { var l = el("label", "flabel", lbl), s2 = el("select", "field"); var o0 = el("option", null, "Pick a brother"); o0.value = ""; s2.appendChild(o0); ids.forEach(function (u) { var o = el("option", null, nameOf(u)); o.value = u; s2.appendChild(o); }); l.appendChild(s2); asg.appendChild(l); return s2; }
    var sp = sel("Paul"), st2 = sel("Timothy"), go2 = el("button", "btn", "Pair them"), clr = el("button", "btn ghost", "Clear Timothy’s Paul"), om = el("p", "note"); go2.type = clr.type = "button";
    go2.addEventListener("click", function () { var p = sp.value, t = st2.value; if (!p || !t || p === t) { om.textContent = "Pick two different brothers."; return; }
      var mt = JSON.parse(JSON.stringify(menOf(t))), mp = JSON.parse(JSON.stringify(menOf(p))); var oldP = mt.paul; mt.paul = p; mt.declined = mt.declined.filter(function (x) { return x !== p; }); if (mp.timothys.indexOf(t) < 0) mp.timothys.push(t); mp.declined = mp.declined.filter(function (x) { return x !== t; });
      var ws = [menSave(t, mt), menSave(p, mp)]; if (oldP && oldP !== p) { var mo = JSON.parse(JSON.stringify(menOf(oldP))); mo.timothys = mo.timothys.filter(function (x) { return x !== t; }); ws.push(menSave(oldP, mo)); }
      Promise.all(ws).then(function () { om.textContent = "✓ " + nameOf(p) + " is now " + nameOf(t) + "’s Paul."; drawAll(); }); });
    clr.addEventListener("click", function () { var t = st2.value; if (!t) { om.textContent = "Pick the Timothy."; return; } var mt = JSON.parse(JSON.stringify(menOf(t))), p = mt.paul; mt.paul = ""; var ws = [menSave(t, mt)]; if (p) { var mp = JSON.parse(JSON.stringify(menOf(p))); mp.timothys = mp.timothys.filter(function (x) { return x !== t; }); ws.push(menSave(p, mp)); } Promise.all(ws).then(function () { om.textContent = "✓ Cleared."; drawAll(); }); });
    var rw = el("div", "cdlg-btns"); rw.appendChild(go2); rw.appendChild(clr); asg.appendChild(rw); asg.appendChild(om); box.appendChild(asg);
  }
'''
rep('''  /* ---------- Owner tools ---------- */''', JS + '''  /* ---------- Owner tools ---------- */''')
CSS = '''
#mentor-today:empty { display: none; }
.men-card { border: 1px solid var(--accent); border-radius: 10px; background: var(--surface); padding: 10px 12px; margin: 0 0 14px; }
.men-k { color: var(--accent); font-size: 12px; }
.men-row { width: 100%; display: grid; grid-template-columns: 42px minmax(0, 1fr) auto; gap: 10px; align-items: center; padding: 9px 0; background: none; border: 0; border-top: 1px solid var(--line); color: var(--ink); font: inherit; text-align: left; cursor: pointer; }
.men-card .men-row:first-of-type, .men-sec h2 + .men-row { border-top: 0; }
.men-av { width: 40px; height: 40px; border-radius: 50%; border: 2px solid var(--accent); background: var(--surface-2); display: grid; place-items: center; overflow: hidden; font-family: var(--f-label); font-weight: 800; }
.men-av img { width: 100%; height: 100%; object-fit: cover; }
.men-tx { display: grid; gap: 1px; min-width: 0; } .men-tx b { font-size: 15px; } .men-tx small { color: var(--muted); font-size: 12.5px; }
.men-tag { font-family: var(--f-label); font-weight: 700; font-size: 11.5px; letter-spacing: .08em; text-transform: uppercase; padding: 3px 9px; border-radius: 10px; border: 1px solid var(--line); color: var(--muted); white-space: nowrap; }
.men-tag.ok, .men-tag.acc { color: var(--accent); border-color: var(--accent); } .men-tag.hot { background: #c0392b; border-color: #c0392b; color: #fff; }
.men-nudge { margin: 6px 0 2px; padding: 8px 10px; border-radius: 8px; background: color-mix(in srgb, var(--accent) 14%, transparent); font-size: 14px; }
.men-empty { width: 100%; display: grid; gap: 2px; padding: 8px 0 2px; background: none; border: 0; color: var(--ink); font: inherit; text-align: left; cursor: pointer; } .men-empty small { color: var(--muted); }
.men-sec { margin-top: 16px; } .men-sec h2 { margin: 0 0 6px; }
.men-req { display: grid; grid-template-columns: 42px minmax(0, 1fr) auto auto; gap: 8px; align-items: center; padding: 8px 0; border-top: 1px solid var(--line); }
.men-wide { width: 100%; margin-top: 8px; }
.men-chk { border: 1px solid var(--line); border-radius: 10px; background: var(--surface); padding: 12px; margin-top: 10px; display: grid; gap: 8px; }
.men-priv { margin: 0; padding: 8px 10px; border: 1px dashed var(--accent); border-radius: 8px; font-size: 13px; }
.men-q { font-size: 14.5px; } .men-how { display: flex; gap: 8px; flex-wrap: wrap; }
.men-talk { display: grid; grid-template-columns: 24px 1fr; gap: 10px; align-items: center; padding: 10px; border: 1px solid var(--line); border-radius: 8px; cursor: pointer; } .men-talk input { width: 22px; height: 22px; margin: 0; accent-color: var(--accent); } .men-talk span { display: grid; } .men-talk small { color: var(--muted); font-size: 12.5px; }
.men-head { display: flex; gap: 12px; align-items: center; margin: 12px 0 6px; } .men-head .men-av { width: 56px; height: 56px; font-size: 22px; } .men-name { margin: 2px 0 0; font-family: var(--f-label); font-weight: 800; text-transform: uppercase; font-size: 24px; }
.men-alert { margin: 8px 0; padding: 10px 12px; border: 1px solid #c0392b; background: color-mix(in srgb, #c0392b 18%, transparent); border-radius: 10px; font-size: 14.5px; }
.men-stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; margin-top: 8px; } .men-stats div { border: 1px solid var(--line); border-radius: 8px; padding: 8px; text-align: center; background: var(--surface); } .men-stats b { display: block; font-family: var(--f-label); font-size: 22px; } .men-stats small { color: var(--muted); font-size: 11px; text-transform: uppercase; letter-spacing: .06em; }
.men-howv { margin: 0; font-weight: 600; }
.men-sent { margin: 0; color: var(--accent); font-weight: 600; font-size: 14px; } .men-quote { margin: 0; padding: 4px 10px; border-left: 3px solid var(--line); }
.men-end { margin-top: 14px; display: block; }
.men-pick { max-height: 85vh; display: flex; flex-direction: column; gap: 8px; } .men-plist { overflow-y: auto; flex: 1; min-height: 120px; }
.o-pair { display: grid; gap: 1px; padding: 8px 0; border-top: 1px solid var(--line); } .o-pair span { color: var(--muted); font-size: 13.5px; }
.o-assign { margin-top: 12px; display: grid; gap: 8px; }
'''
rep('''.set-ownrow { width: 100%;''', CSS.strip() + '''\n.set-ownrow { width: 100%;''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
