#!/usr/bin/env python3
"""Campaigns, stage 1 (Request Log #278, decided by Curtis 2026-10-31).
Teams of 6-8 men compete for 6 weeks. A brother raises a team (he is captain), names it (Scripture ideas offered),
picks a banner and invites brothers; they join from Today. Rosters lock at the start; a team needs 6 men to march.
Team score each week = average Kingdom Warrior points per man (a man who sat out that week isn't counted)
+ 25 (Wall Held) when every counted man checked every daily box all 7 days. Each week the owner picks one box that
counts double; the double counts on each man's own points everywhere, only for men on a marching team.
Board gets a Campaign view; each team has a team page; Today shows a campaign card; Settings > Owner (owner only)
sets dates and the weekly double, renames teams, and closes a campaign.
Data: camps/current (owner), teams/{captainUid} (captain), tmembers/{uid} (each man). New db rules required.
Usage: patch_camp1.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new, cnt=1):
    global s
    assert s.count(old) == cnt, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---------------- backend adapter ----------------
rep('    addPost: function (p) { return this.db.collection("posts").add(p); },',
    '''    addPost: function (p) { return this.db.collection("posts").add(p); },
    watchCamps: function (cb) { return this.db.collection("camps").onSnapshot(function (s) { var m = {}; s.docs.forEach(function (d) { m[d.id] = d.data() || {}; }); cb(m); }, noop); },
    saveCamp: function (id, o) { return this.db.doc("camps/" + id).set(o); },
    watchTeams: function (cb) { return this.db.collection("teams").onSnapshot(function (s) { var m = {}; s.docs.forEach(function (d) { m[d.id] = d.data() || {}; }); cb(m); }, noop); },
    saveTeam: function (id, o) { return this.db.doc("teams/" + id).set(o); },
    updateTeam: function (id, o) { return this.db.doc("teams/" + id).update(o); },
    deleteTeam: function (id) { return this.db.doc("teams/" + id).delete(); },
    watchTMembers: function (cb) { return this.db.collection("tmembers").onSnapshot(function (s) { var m = {}; s.docs.forEach(function (d) { m[d.id] = d.data() || {}; }); cb(m); }, noop); },
    saveTMember: function (id, o) { return this.db.doc("tmembers/" + id).set(o); },
    deleteTMember: function (id) { return this.db.doc("tmembers/" + id).delete(); },''')

# ---------------- points: the weekly double ----------------
rep('''    var done = rec.done || {}; var p = customDone(done) + bonusOf(rec);
    state.tasks.forEach(function (t) { if (done[t.id]) p += t.points; });
    return p;''', '''    var done = rec.done || {}; var p = customDone(done) + bonusOf(rec) + campDoubleExtra(rec);
    state.tasks.forEach(function (t) { if (done[t.id]) p += t.points; });
    return p;''')
rep('    var t = { boxes: 0, habits: 0, steps: 0, protein: 0, prs: 0, opt: 0 }, prList = [];', '    var t = { boxes: 0, habits: 0, steps: 0, protein: 0, prs: 0, opt: 0, dbl: 0 }, prList = [];')
rep('t.opt += c.obonus ? OPT_BONUS : 0;', 't.opt += c.obonus ? OPT_BONUS : 0; t.dbl += campDoubleExtra(c);')
rep('    var kw = t.boxes + t.habits + t.steps + t.protein + t.prs + t.opt + rcPts;', '    var kw = t.boxes + t.habits + t.steps + t.protein + t.prs + t.opt + t.dbl + rcPts;')
rep('["Optional workout bonus", t.opt], ["PRs', '["Optional workout bonus", t.opt], ["Campaign double points", t.dbl], ["PRs')

CAMP = r'''  /* ---------- Campaigns: teams of 6-8 men, 6 weeks, average points per man. ---------- */
  var CAMP_MIN = 6, CAMP_MAX = 8, CAMP_WEEKS = 6, WALL_BONUS = 25;
  var CAMP_NAMES = [["Gideon’s 300", "Judges 7"], ["The Thirty", "2 Samuel 23"], ["Shammah’s Field", "2 Samuel 23:11"], ["Benaiah’s Pit", "2 Samuel 23:20"], ["Nehemiah’s Wall", "Nehemiah 4"], ["Sons of Issachar", "1 Chronicles 12:32"], ["Caleb’s Mountain", "Joshua 14:12"], ["Valley of Elah", "1 Samuel 17"], ["Jericho Marchers", "Joshua 6"], ["The Watchmen", "Ezekiel 33"], ["Lions of Judah", "Genesis 49:9"], ["Jonathan’s Armor", "1 Samuel 14"]];
  var CAMP_BANNERS = [["trumpet", "Trumpet", "#e8742f"], ["sword", "Sword", "#8f9f50"], ["sling", "Sling", "#d0642f"], ["shield", "Shield", "#e0c46c"], ["wall", "Wall", "#e0c46c"], ["lion", "Lion", "#e8742f"], ["mountain", "Mountain", "#8f9f50"], ["torch", "Torch", "#d0642f"], ["crown", "Crown", "#e0c46c"], ["star", "Star", "#8f9f50"]];
  var CB_G = {
    trumpet: 'o:M3 9.5V14.5H6L17.5 20V4L6 9.5H3Z|o:M17.5 8.5Q21 12 17.5 15.5',
    sling: 'o:M4 4Q8 16 12 17Q16 16 20 4|f:c12,17.4,2.6|o:M4 4 2.6 2.6M20 4 21.4 2.6',
    sword: 'o:M12 2.6V16|o:M8 16H16|o:M12 16V21|o:M10.6 21H13.4|o:M10.4 4.2 12 2.6 13.6 4.2',
    shield: 'o:M12 3 19.4 5.8V11.4C19.4 16 16.4 19.4 12 21 7.6 19.4 4.6 16 4.6 11.4V5.8Z|o:M12 6V18M7.6 11H16.4',
    wall: 'o:M3 7H21V20H3Z|o:M3 11.4H21M3 15.8H21|o:M8 7V11.4M15 7V11.4M11.6 11.4V15.8M6 15.8V20M17.4 15.8V20|o:M3 7V4.6H6V7M10.5 7V4.6H13.5V7M18 7V4.6H21V7',
    crown: 'o:M3.6 17.6 2.8 7.4 8 11.6 12 4.6 16 11.6 21.2 7.4 20.4 17.6Z|o:M4 20.4H20',
    mountain: 'o:M2 20 9 7.4 13 13.6 15.6 10 22 20Z|o:M15.6 3V8.4|o:M15.6 3.4H19.6L18.4 4.8 19.6 6.2H15.6',
    torch: 'o:M10.4 11H13.6L12.8 21.2H11.2Z|f:M12 2.4C15.2 5.4 15.6 8 14 10.2H10C8.4 8 8.8 5.4 12 2.4Z',
    lion: 'o:M12 4.2C7.6 4.2 5 7.6 5 11.6 5 15.8 8 19.6 12 19.6 16 19.6 19 15.8 19 11.6 19 7.6 16.4 4.2 12 4.2Z|o:M3.4 9.6 5.2 8.2M20.6 9.6 18.8 8.2M3.6 14.2 5.4 13.6M20.4 14.2 18.6 13.6|f:c9.6,11,1|f:c14.4,11,1|o:M10.6 15.2Q12 16.6 13.4 15.2|o:M12 13V15.2',
    star: 'o:M12 2.8 14.7 8.6 21 9.3 16.3 13.6 17.6 19.8 12 16.6 6.4 19.8 7.7 13.6 3 9.3 9.3 8.6Z'
  };
  function bannerSvg(key) {
    var b = CAMP_BANNERS.filter(function (x) { return x[0] === key; })[0] || CAMP_BANNERS[0];
    var g = (CB_G[b[0]] || CB_G.star).split("|").map(function (p) { var d = p.slice(2), m = /^c([\d.]+),([\d.]+),([\d.]+)$/.exec(d); return m ? '<circle cx="' + m[1] + '" cy="' + m[2] + '" r="' + m[3] + '" class="cbn-f"/>' : '<path d="' + d + '" class="' + (p[0] === "f" ? "cbn-f" : "cbn-o") + '"/>'; }).join("");
    return '<svg class="cbn" viewBox="0 0 64 72" aria-hidden="true" style="--c:' + b[2] + '"><path d="M10 4H54V54L32 68 10 54Z" class="cbn-fr"/><path d="M14.5 8.5H49.5V51.6L32 62.6 14.5 51.6Z" class="cbn-st"/><g transform="translate(14 13) scale(1.5)">' + g + '</g></svg>';
  }
  function bannerEl(key, cls) { var s = el("span", "cbn-w" + (cls ? " " + cls : "")); s.innerHTML = bannerSvg(key); return s; }
  function campCfg() { var c = (state.camps || {}).current; return c && c.id && /^\d{4}-\d{2}-\d{2}$/.test(String(c.start || "")) ? c : null; }
  function campEnd(c) { return addDays(c.start, CAMP_WEEKS * 7 - 1); }
  function campPhase(c, k) { k = k || todayKey(); if (!c) return ""; if (k > campEnd(c)) return "done"; if (k >= c.start) return "live"; if (c.signup && k >= c.signup) return "signup"; return "soon"; }
  function campWeekIdx(c, k) { var d = dayDiff(c.start, k); return d < 0 ? -1 : Math.floor(d / 7); }
  function campNameRef(name) { var m = CAMP_NAMES.filter(function (x) { return x[0].toLowerCase() === String(name || "").trim().toLowerCase(); })[0]; return m ? m[1] : ""; }
  var campMemo = null;
  function campDirty() { campMemo = null; }
  /* Teams for the campaign. A man is on a team when his tmembers doc names it and the captain invited him (or he is
     the captain). Once it starts, rosters lock: only men who joined before the first day count, up to 8. */
  function campIndex() {
    if (campMemo) return campMemo;
    var c = campCfg(), teams = [], byUid = {}, onAny = {};
    if (c) {
      var ph = campPhase(c), startMs = parseKey(c.start).getTime();
      Object.keys(state.teams || {}).forEach(function (cap) {
        var t = state.teams[cap]; if (!t || t.camp !== c.id) return;
        var inv = Array.isArray(t.invites) ? t.invites.map(String) : [], men = [];
        Object.keys(state.tmem || {}).forEach(function (u) {
          var m = state.tmem[u]; if (!m || m.camp !== c.id || m.team !== cap || !(u === cap || inv.indexOf(u) >= 0)) return;
          var at = Number(m.at) || 0; if ((ph === "live" || ph === "done") && u !== cap && at >= startMs) return;
          men.push({ uid: u, at: at });
        });
        if (!men.some(function (m) { return m.uid === cap; })) return;
        men.sort(function (a, b) { return a.uid === cap ? -1 : b.uid === cap ? 1 : a.at - b.at; });
        men = men.slice(0, CAMP_MAX).map(function (m) { return m.uid; });
        var tt = { id: cap, name: String(t.name || "Unnamed").slice(0, 40), banner: String(t.banner || "trumpet"), cap: cap, invites: inv, men: men, ok: men.length >= CAMP_MIN };
        teams.push(tt); men.forEach(function (u) { onAny[u] = cap; if (tt.ok) byUid[u] = cap; });
      });
    }
    campMemo = { c: c, teams: teams, byUid: byUid, onAny: onAny };
    return campMemo;
  }
  function teamById(id) { return campIndex().teams.filter(function (t) { return t.id === id; })[0] || null; }
  function myTeam() { var ix = campIndex(); return state.me && ix.onAny[state.me] ? teamById(ix.onAny[state.me]) : null; }
  /* The weekly double: only for men on a marching team, only on days inside the campaign. */
  function campDoubleExtra(rec) {
    var ix = campIndex(), c = ix.c; if (!c || !rec || !rec.uid || !ix.byUid[rec.uid]) return 0;
    if (rec.date < c.start || rec.date > campEnd(c)) return 0;
    var kind = (c.doubles || [])[campWeekIdx(c, rec.date)]; if (!kind) return 0;
    var d = rec.done || {}, x = 0;
    state.tasks.forEach(function (t) { if (t.kind === kind && d[t.id]) x += t.points; });
    if (kind === "steps") x += stepBonus(rec.steps);
    return x;
  }
  function campDoubleLabel(c, w) { var k = (c.doubles || [])[w], t = state.tasks.filter(function (x) { return x.kind === k; })[0]; return k ? (t ? t.title : k) : ""; }
  function fullRec(r) { var daily = state.tasks.filter(function (t) { return t.kind !== "weigh" && t.kind !== "photos"; }); return !!daily.length && daily.every(function (t) { return r.done && r.done[t.id]; }); }
  function campRows() {
    var seen = {}, rows = [];
    state.checks.forEach(function (r) { seen[r.date + "_" + r.uid] = true; rows.push(r); });
    (state.campChecks || []).forEach(function (r) { if (!seen[r.date + "_" + r.uid]) rows.push(r); });
    return rows;
  }
  function teamWeek(t, c, w, rows) {
    var ws = addDays(c.start, w * 7), we = addDays(ws, 6), today = todayKey(), last = we < today ? we : today, per = {}, full = {};
    t.men.forEach(function (u) { per[u] = 0; });
    rows.forEach(function (r) { if (r.date < ws || r.date > we || !(r.uid in per) || r.date > today) return; per[r.uid] += pointsOf(r); if (fullRec(r)) (full[r.date] = full[r.date] || {})[r.uid] = true; });
    var counted = t.men.filter(function (u) { for (var k = ws; k <= we; k = addDays(k, 1)) if (isOut(u, k)) return false; return true; });
    var sum = 0; counted.forEach(function (u) { sum += per[u]; });
    var avg = counted.length ? sum / counted.length : 0, wallDays = 0;
    if (last >= ws) for (var k2 = ws; k2 <= last; k2 = addDays(k2, 1)) if (counted.length && counted.every(function (u) { return full[k2] && full[k2][u]; })) wallDays++;
    var wall = wallDays === 7 ? WALL_BONUS : 0;
    return { ws: ws, we: we, avg: avg, wallDays: wallDays, wall: wall, score: avg + wall, counted: counted, full: full };
  }
  function campStandings() {
    var ix = campIndex(), c = ix.c; if (!c) return [];
    var ph = campPhase(c), rows = campRows(), cw = ph === "done" ? CAMP_WEEKS - 1 : ph === "live" ? campWeekIdx(c, todayKey()) : -1;
    var list = ix.teams.map(function (t) {
      var total = 0, cur = null;
      for (var w = 0; w <= cw; w++) { var tw = teamWeek(t, c, w, rows); total += tw.score; if (w === cw) cur = tw; }
      return { t: t, total: total, cur: cur };
    });
    list.sort(function (a, b) { return (b.t.ok - a.t.ok) || (b.total - a.total) || (b.t.men.length - a.t.men.length) || (a.t.name < b.t.name ? -1 : 1); });
    var r = 0, prev = null; list.forEach(function (x, i) { if (!x.t.ok) { x.rank = 0; return; } if (x.total !== prev) { r = i + 1; prev = x.total; } x.rank = r; });
    return list;
  }
  var campSub = "";
  function campWatchChecks() {
    var c = campCfg(); if (!c || !B.db) return; var ph = campPhase(c); if (ph !== "live" && ph !== "done") return;
    if (campSub === c.start) return; campSub = c.start;
    B.watchChecks(c.start, function (rows) { state.campChecks = rows; campDirty(); drawAll(); if (state.page === "team") drawTeamPage(); });
  }
  function r1c(v) { return (Math.round(v * 10) / 10).toLocaleString(); }
  function campDateText(k) { return parseKey(k).toLocaleDateString(undefined, { month: "short", day: "numeric" }); }
  function openCampBoard() { go("board"); state.boardView = "camp"; drawBoard(); }
  function openTeam(id) { state.teamId = id; go("team"); drawTeamPage(); }

  /* Board: Campaign standings */
  function drawCampBoard() {
    var box = $("board"); box.textContent = ""; $("board-tabs").hidden = true;
    var ix = campIndex(), c = ix.c; if (!c) { $("h-board").textContent = "Campaign"; box.appendChild(el("p", "note", "No campaign set up yet.")); return; }
    var ph = campPhase(c), w = campWeekIdx(c, todayKey()), mine = myTeam();
    $("h-board").textContent = "Campaign " + (c.n || 1);
    var hd = el("div", "cmp-head");
    hd.appendChild(el("div", "label-caps cmp-k", ph === "live" ? "Week " + (w + 1) + " of " + CAMP_WEEKS + " · " + campDateText(c.start) + " – " + campDateText(campEnd(c)) : ph === "signup" ? "Sign-ups open · starts " + longDate(c.start).split(",").slice(0, 2).join(",") : ph === "done" ? "Final · " + campDateText(c.start) + " – " + campDateText(campEnd(c)) : "Opens " + (c.signup ? longDate(c.signup).split(",").slice(0, 2).join(",") : "soon")));
    if (state.isOwner) { var gear = el("button", "mini cmp-gear", "Owner settings"); gear.type = "button"; gear.addEventListener("click", function () { openSettingsSection("h-s-owner"); }); hd.appendChild(gear); }
    box.appendChild(hd);
    if (ph === "live" && campDoubleLabel(c, w)) box.appendChild(campDoubleCard(c, w));
    if ((ph === "signup" || ph === "soon") && !mine && state.me && state.canWrite && ph === "signup") { var rb = el("button", "btn", "Raise a team"); rb.type = "button"; rb.addEventListener("click", openRaiseTeam); box.appendChild(rb); }
    var st = campStandings();
    if (!st.length) box.appendChild(el("p", "note", ph === "signup" || ph === "soon" ? "No teams yet. Raise a banner and invite 5 to 7 brothers." : "No teams marched in this campaign."));
    st.forEach(function (x, i) {
      var t = x.t, row = el("button", "cmp-row" + (mine && mine.id === t.id ? " me" : "") + (!t.ok && (ph === "live" || ph === "done") ? " out" : "")); row.type = "button";
      row.appendChild(el("span", "cmp-rk", ph === "live" || ph === "done" ? (x.rank ? String(x.rank) : "–") : "•"));
      row.appendChild(bannerEl(t.banner));
      var tx = el("span", "cmp-tx"), nm = el("span", "cmp-nm", t.name); if (mine && mine.id === t.id) nm.appendChild(el("em", "cmp-you", "Your team")); tx.appendChild(nm);
      var sub = t.men.length + (t.men.length === 1 ? " man" : " men");
      if (ph === "live" || ph === "done") { if (!t.ok) sub += " · short of men, not ranked"; else { if (x.cur && ph === "live") sub += " · this week " + r1c(x.cur.score); var ahead = st[i - 1]; if (i > 0 && ahead && ahead.t.ok) sub += " · " + r1c(ahead.total - x.total) + " behind"; else if (i === 0) sub += ph === "done" ? " · champions" : " · leading"; } }
      else sub += t.ok ? " · ready to march" : " · needs " + (CAMP_MIN - t.men.length) + " more";
      tx.appendChild(el("span", "cmp-sub", sub)); row.appendChild(tx);
      if ((ph === "live" || ph === "done") && t.ok) { var sc = el("span", "cmp-sc"); sc.appendChild(el("b", null, r1c(x.total))); sc.appendChild(el("small", null, "total")); row.appendChild(sc); }
      row.addEventListener("click", function () { openTeam(t.id); });
      box.appendChild(row);
    });
    $("board-note").textContent = "Team score is the average Kingdom Warrior points per man each week, so 6 men compete evenly with 8. A week a man sits out doesn’t count against his team. Wall Held: +" + WALL_BONUS + " for the week when every man checks all his boxes all 7 days. Not on a team? You still compete on Kingdom Warrior.";
  }
  function campDoubleCard(c, w) {
    var d = el("div", "cmp-dbl"); d.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M13.4 2.2 5.4 13H11.2L10.2 21.8 18.6 10.6H12.8Z"/></svg>';
    var tx = el("span"); tx.appendChild(el("span", "label-caps cmp-k", "Double points this week")); tx.appendChild(el("b", null, campDoubleLabel(c, w) + " ×2"));
    tx.appendChild(el("small", null, "Counts double for every man in the battle, on his team and on his own Kingdom Warrior points.")); d.appendChild(tx); return d;
  }

  /* Team page */
  function drawTeamPage() {
    var body = $("team-body"); if (!body) return; body.textContent = "";
    var ix = campIndex(), c = ix.c, t = teamById(state.teamId); if (!c || !t) { body.appendChild(el("p", "note", "This team isn’t in the current campaign.")); return; }
    var ph = campPhase(c), st = campStandings(), me = state.me, isCap = me === t.cap, onIt = t.men.indexOf(me) >= 0, x = st.filter(function (y) { return y.t.id === t.id; })[0] || {};
    var hd = el("div", "tm-head"); hd.appendChild(bannerEl(t.banner, "big"));
    var ht = el("div"); ht.appendChild(el("div", "label-caps cmp-k acc", "Campaign " + (c.n || 1) + (x.rank ? " · Rank " + x.rank + " of " + st.filter(function (y) { return y.t.ok; }).length : "")));
    ht.appendChild(el("h1", "pg tm-nm", t.name)); var ref = campNameRef(t.name);
    ht.appendChild(el("p", "note tm-cap", (ref ? ref + " · " : "") + "Captain: " + nameOf(t.cap))); hd.appendChild(ht); body.appendChild(hd);
    if (ph === "live" || ph === "done") {
      var cur = x.cur || teamWeek(t, c, Math.max(0, Math.min(CAMP_WEEKS - 1, campWeekIdx(c, todayKey()))), campRows());
      var sts = el("div", "tm-stats");
      [[r1c(x.total || 0), "Total"], [r1c(cur.score), ph === "done" ? "Last week" : "This week"], [cur.wallDays + "/7", "Wall held. All 7 = +" + WALL_BONUS]].forEach(function (s0) { var b = el("div", "tm-stat"); b.appendChild(el("b", null, s0[0])); b.appendChild(el("span", null, s0[1])); sts.appendChild(b); });
      body.appendChild(sts);
      var w = campWeekIdx(c, todayKey()); if (ph === "live" && campDoubleLabel(c, w)) body.appendChild(campDoubleCard(c, w));
    } else body.appendChild(el("p", "note", ph === "signup" ? "Sign-ups are open. The campaign starts " + longDate(c.start) + ". Rosters lock then, and a team needs " + CAMP_MIN + " men to march." : "Campaign " + (c.n || 1) + " opens soon."));
    // The men
    body.appendChild(el("h2", "label-caps tm-h", ph === "live" ? "The men · this week" : "The men · " + t.men.length + " of " + CAMP_MAX));
    var list = el("div", "tm-men"), cw = ph === "live" ? teamWeek(t, c, campWeekIdx(c, todayKey()), campRows()) : null, dn = ["M", "T", "W", "T", "F", "S", "S"];
    t.men.forEach(function (u) {
      var r = el("div", "tm-man"), av = el("img", "avatar"); av.alt = ""; if (avatarSrc(u)) av.src = avatarSrc(u); makeLink(av, u); r.appendChild(av);
      var tx = el("div", "tm-mt"), nm = el("div", "tm-mn", nameOf(u)); makeLink(nm, u);
      if (u === t.cap) nm.appendChild(el("span", "tm-tag", "Captain")); if (u === me) nm.appendChild(el("em", null, "YOU"));
      if (cw && cw.counted.indexOf(u) < 0) nm.appendChild(el("span", "tm-tag", "Sat out"));
      tx.appendChild(nm);
      if (cw) { var ds = el("div", "tm-days"); for (var i = 0; i < 7; i++) { var k = addDays(cw.ws, i), on = cw.full[k] && cw.full[k][u]; var dd = el("span", "tm-day" + (on ? " on" : "") + (k === todayKey() ? " now" : ""), dn[i]); dd.title = longDate(k) + (on ? ": every box checked" : ""); ds.appendChild(dd); } tx.appendChild(ds); }
      r.appendChild(tx);
      if (isCap && u !== t.cap && ph === "signup") { var rm = el("button", "mini", "Remove"); rm.type = "button"; rm.addEventListener("click", function () { confirmDelete({ title: "Remove " + nameOf(u) + "?", message: "He comes off " + t.name + ".", yes: "Remove" }, function () { campSetInvites(t, t.invites.filter(function (v) { return v !== u; })); }); }); r.appendChild(rm); }
      list.appendChild(r);
    });
    var pending = t.invites.filter(function (u) { return t.men.indexOf(u) < 0; });
    if (ph === "signup" || ph === "soon") pending.forEach(function (u) {
      var r = el("div", "tm-man pend"), av = el("img", "avatar"); av.alt = ""; if (avatarSrc(u)) av.src = avatarSrc(u); r.appendChild(av);
      var tx = el("div", "tm-mt"); tx.appendChild(el("div", "tm-mn", nameOf(u))); tx.appendChild(el("div", "note", "Invited. Waiting on him to join from Today.")); r.appendChild(tx);
      if (isCap) { var cx = el("button", "mini", "Cancel"); cx.type = "button"; cx.addEventListener("click", function () { campSetInvites(t, t.invites.filter(function (v) { return v !== u; })); }); r.appendChild(cx); }
      list.appendChild(r);
    });
    body.appendChild(list);
    if (cw) body.appendChild(el("p", "note", "A filled day means he checked every daily box. Brothers see the days, never each man’s points."));
    // Actions
    if (isCap && (ph === "signup" || ph === "soon") && state.canWrite) {
      var left = CAMP_MAX - t.men.length;
      var ib = el("button", "btn", left > 0 ? "Invite a brother (" + left + (left === 1 ? " spot" : " spots") + " left)" : "Team is full"); ib.type = "button"; ib.disabled = left <= 0; ib.addEventListener("click", function () { openCampInvite(t); }); body.appendChild(ib);
      var eb = el("button", "btn ghost", "Change name or banner"); eb.type = "button"; eb.addEventListener("click", function () { openRaiseTeam(t); }); body.appendChild(eb);
      var db = el("button", "btn ghost", "Disband team"); db.type = "button"; db.addEventListener("click", function () { confirmDelete({ title: "Disband " + t.name + "?", message: "The team and its invites go away. Your men can join another team.", yes: "Disband" }, function () { B.deleteTeam(t.cap).catch(noop); B.deleteTMember(me).catch(noop); go("board"); }); }); body.appendChild(db);
    } else if (onIt && !isCap && (ph === "signup" || ph === "soon") && state.canWrite) {
      var lb = el("button", "btn ghost", "Leave team"); lb.type = "button"; lb.addEventListener("click", function () { confirmDelete({ title: "Leave " + t.name + "?", message: "You can join another team before the campaign starts.", yes: "Leave" }, function () { B.deleteTMember(me).catch(noop); go("board"); }); }); body.appendChild(lb);
    }
    if (!onIt && (ph === "live" || ph === "done")) body.appendChild(el("p", "note", "Rosters are locked for this campaign."));
  }
  function campSetInvites(t, inv) { inv = inv.filter(function (v, i) { return v && inv.indexOf(v) === i; }).slice(0, 16); B.updateTeam(t.cap, { invites: inv }).catch(function () { alertSoon("That didn’t save. Check your connection and try again."); }); }
  function alertSoon(m) { var n = $("team-body"); if (n) n.appendChild(el("p", "error", m)); }

  /* Raise (or edit) a team: name with Scripture ideas, banner. */
  function openRaiseTeam(edit) {
    var c = campCfg(); if (!c || !state.me || !state.canWrite) return;
    var t0 = edit && edit.cap ? edit : null, name = t0 ? t0.name : "", ban = t0 ? t0.banner : "trumpet";
    var old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("form", "cdlg-box nw-box rt-box"); box.noValidate = true; box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "rt-t");
    var h = el("h2", null, t0 ? "Your team" : "Raise a team"); h.id = "rt-t"; box.appendChild(h);
    if (!t0) box.appendChild(el("p", "note", "You’ll be the captain. Pick a name and a banner, then invite " + (CAMP_MIN - 1) + " to " + (CAMP_MAX - 1) + " brothers. A team needs " + CAMP_MIN + " men to march."));
    var lb = el("label", "flabel", "Team name"), inp = el("input", "field"); inp.maxLength = 32; inp.value = name; inp.placeholder = "Name your team"; lb.appendChild(inp); box.appendChild(lb);
    box.appendChild(el("p", "note", "Ideas from Scripture, or write your own:"));
    var chips = el("div", "rt-chips");
    CAMP_NAMES.forEach(function (n) { var b = el("button", "rt-chip"); b.type = "button"; b.appendChild(document.createTextNode(n[0])); b.appendChild(el("small", null, n[1])); b.addEventListener("click", function () { inp.value = n[0]; paint(); }); chips.appendChild(b); });
    box.appendChild(chips);
    box.appendChild(el("div", "flabel", "Banner"));
    var grid = el("div", "rt-grid");
    CAMP_BANNERS.forEach(function (b) { var bt = el("button", "rt-ban"); bt.type = "button"; bt.dataset.k = b[0]; bt.appendChild(bannerEl(b[0])); bt.appendChild(el("span", null, b[1])); bt.setAttribute("aria-label", b[1] + " banner"); bt.addEventListener("click", function () { ban = b[0]; paint(); }); grid.appendChild(bt); });
    box.appendChild(grid);
    function paint() {
      Array.prototype.forEach.call(chips.children, function (x) { x.classList.toggle("on", x.firstChild.textContent === inp.value.trim()); });
      Array.prototype.forEach.call(grid.children, function (x) { var on = x.dataset.k === ban; x.classList.toggle("on", on); x.setAttribute("aria-pressed", String(on)); });
    }
    inp.addEventListener("input", paint); paint();
    var err = el("p", "error"); err.hidden = true; box.appendChild(err);
    var go2 = el("button", "btn", t0 ? "Save" : "Raise the banner"); go2.type = "submit"; box.appendChild(go2);
    var no = el("button", "btn ghost", "Cancel"); no.type = "button"; box.appendChild(no);
    box.appendChild(el("p", "note", "The owner can rename a team if a name isn’t fitting."));
    function close() { back.remove(); }
    no.addEventListener("click", close);
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    box.addEventListener("submit", function (ev) {
      ev.preventDefault(); var nm = inp.value.replace(/\s+/g, " ").trim().slice(0, 32);
      if (nm.length < 2) { err.textContent = "Give your team a name."; err.hidden = false; return; }
      go2.disabled = true;
      var p = t0 ? B.updateTeam(state.me, { name: nm, banner: ban }) : B.saveTeam(state.me, { camp: c.id, name: nm, banner: ban, captain: state.me, invites: [], createdAt: Date.now() }).then(function () { return B.saveTMember(state.me, { camp: c.id, team: state.me, at: Date.now() }); });
      p.then(function () { close(); openTeam(state.me); }).catch(function () { go2.disabled = false; err.textContent = "That didn’t save. Check your connection and try again."; err.hidden = false; });
    });
    back.appendChild(box); document.body.appendChild(back); inp.focus();
  }

  /* Captain invites brothers who aren't on a team yet. */
  function openCampInvite(t) {
    var old = $("cdlg"); if (old) old.remove();
    var ix = campIndex(), back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box ci-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "ci-t");
    var h = el("h2", null, "Invite a brother"); h.id = "ci-t"; box.appendChild(h);
    box.appendChild(el("p", "note", "He’ll see your invite on Today and tap Join."));
    var q = el("input", "field"); q.type = "search"; q.placeholder = "Search by name or @handle"; q.setAttribute("aria-label", "Search brothers"); box.appendChild(q);
    var list = el("div", "ci-list"); box.appendChild(list);
    function draw() {
      list.textContent = ""; var qs = q.value.trim().toLowerCase().replace(/^@/, "");
      var ids = Object.keys(state.pubProfiles || {}).filter(function (u) { return u !== t.cap && !ix.onAny[u]; });
      ids.sort(function (a, b) { return nameOf(a).localeCompare(nameOf(b)); });
      ids = ids.filter(function (u) { var h2 = ((state.pubProfiles[u] || {}).handle || "").toLowerCase(); return !qs || nameOf(u).toLowerCase().indexOf(qs) >= 0 || h2.indexOf(qs) >= 0; });
      if (!ids.length) list.appendChild(el("p", "note", qs ? "No brother matches that." : "Every brother is already on a team."));
      ids.slice(0, 40).forEach(function (u) {
        var r = el("div", "ci-row"), av = el("img", "avatar"); av.alt = ""; if (avatarSrc(u)) av.src = avatarSrc(u); r.appendChild(av);
        var hd2 = (state.pubProfiles[u] || {}).handle; var tx = el("span", "ci-n", nameOf(u)); if (hd2) tx.appendChild(el("small", null, " @" + hd2)); r.appendChild(tx);
        var inv = t.invites.indexOf(u) >= 0, b = el("button", "mini" + (inv ? "" : " on"), inv ? "Invited" : "Invite"); b.type = "button"; b.disabled = inv || t.invites.filter(function (v) { return t.men.indexOf(v) < 0; }).length + t.men.length >= CAMP_MAX + 4;
        b.addEventListener("click", function () { t.invites = t.invites.concat([u]); campSetInvites(t, t.invites); draw(); }); r.appendChild(b);
        list.appendChild(r);
      });
    }
    q.addEventListener("input", draw); draw();
    var ok = el("button", "btn ghost", "Done"); ok.type = "button"; box.appendChild(ok);
    function close() { back.remove(); drawTeamPage(); }
    ok.addEventListener("click", close);
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back); q.focus();
  }

  /* Today: the campaign card (his team, or sign-ups and invites). */
  function drawCampToday() {
    var box = $("camp-today"); if (!box) return; box.textContent = ""; box.hidden = true;
    var ix = campIndex(), c = ix.c; if (!c || !state.me) return; var ph = campPhase(c); if (ph !== "live" && ph !== "signup") return;
    var t = myTeam(), w = campWeekIdx(c, todayKey());
    if (t) {
      var st = campStandings(), x = st.filter(function (y) { return y.t.id === t.id; })[0] || {}, b = el("button", "cmp-today"); b.type = "button";
      b.appendChild(bannerEl(t.banner)); var tx = el("span", "cmp-tx");
      tx.appendChild(el("span", "label-caps cmp-k", "Campaign " + (c.n || 1) + (ph === "live" ? " · Week " + (w + 1) + " of " + CAMP_WEEKS : " · Starts " + campDateText(c.start))));
      var nOk = st.filter(function (y) { return y.t.ok; }).length, rk = x.rank ? (x.rank <= 3 ? ["1st", "2nd", "3rd"][x.rank - 1] : x.rank + "th") + " of " + nOk : "";
      tx.appendChild(el("span", "cmp-nm", t.name + (ph === "live" && rk ? " \u00B7 " + rk : "")));
      var sub = el("span", "cmp-sub");
      if (ph === "live") { var dl = campDoubleLabel(c, w); if (dl && ix.byUid[state.me]) { sub.appendChild(el("b", null, dl + " ×2")); sub.appendChild(document.createTextNode(" this week. ")); } if (x.cur) sub.appendChild(document.createTextNode("Wall held " + x.cur.wallDays + " of 7 days. Hold all 7 for +" + WALL_BONUS + ".")); if (!t.ok) sub.textContent = "Your team didn’t muster " + CAMP_MIN + " men, so it isn’t ranked this campaign."; }
      else sub.textContent = t.men.length + " of " + CAMP_MAX + " men" + (t.ok ? ". Ready to march." : ". Needs " + (CAMP_MIN - t.men.length) + " more to march.");
      tx.appendChild(sub); b.appendChild(tx); b.addEventListener("click", function () { openTeam(t.id); }); box.appendChild(b); box.hidden = false; return;
    }
    if (ph !== "signup") return;
    var mm = (state.tmem || {})[state.me] || {}, declined = Array.isArray(mm.declined) ? mm.declined : [];
    var invs = ix.teams.filter(function (tt) { return tt.invites.indexOf(state.me) >= 0 && declined.indexOf(tt.id) < 0; });
    var card = el("div", "cmp-today col");
    card.appendChild(el("span", "label-caps cmp-k", "Campaign " + (c.n || 1) + " · Sign-ups open · starts " + campDateText(c.start)));
    invs.forEach(function (tt) {
      var r = el("div", "cmp-inv"); r.appendChild(bannerEl(tt.banner)); var tx2 = el("span", "cmp-tx"); tx2.appendChild(el("span", "cmp-nm", tt.name)); tx2.appendChild(el("span", "cmp-sub", nameOf(tt.cap) + " invited you · " + tt.men.length + " of " + CAMP_MAX + " men")); r.appendChild(tx2);
      var acts = el("span", "cmp-acts"), j = el("button", "mini on", "Join"), d = el("button", "mini", "Decline"); j.type = "button"; d.type = "button"; j.disabled = d.disabled = !state.canWrite || tt.men.length >= CAMP_MAX;
      j.addEventListener("click", function () { B.saveTMember(state.me, { camp: c.id, team: tt.id, at: Date.now(), declined: declined }).then(function () { openTeam(tt.id); }).catch(noop); });
      d.addEventListener("click", function () { B.saveTMember(state.me, { camp: c.id, team: "", at: 0, declined: declined.concat([tt.id]) }).catch(noop); });
      acts.appendChild(j); acts.appendChild(d); r.appendChild(acts); card.appendChild(r);
    });
    if (!invs.length) card.appendChild(el("span", "cmp-sub", "Teams of " + CAMP_MIN + " to " + CAMP_MAX + " battle for 6 weeks. Raise a team, or wait for a captain to invite you."));
    var two = el("div", "cmp-two"), rb = el("button", "btn ghost", "Raise a team"), sb = el("button", "btn ghost", "See the teams"); rb.type = "button"; sb.type = "button"; rb.disabled = !state.canWrite;
    rb.addEventListener("click", openRaiseTeam); sb.addEventListener("click", openCampBoard); two.appendChild(rb); two.appendChild(sb); card.appendChild(two);
    box.appendChild(card); box.hidden = false;
  }

  /* Settings > Owner (only the app's owner sees it). */
  function drawCampOwner() {
    var sec = $("s-owner-sec"); if (!sec) return; sec.hidden = !state.isOwner; if (!state.isOwner) return;
    var box = $("s-owner"); if (!box || (document.activeElement && box.contains(document.activeElement) && /INPUT|SELECT/.test(document.activeElement.tagName))) return;
    box.textContent = "";
    var all = state.camps || {}, cur = all.current || null, c = campCfg(), ph = c ? campPhase(c) : "";
    var d = { n: cur && cur.n ? cur.n : 1, id: cur && cur.id ? cur.id : "c1", signup: cur ? cur.signup || "" : "", start: cur ? cur.start || "" : "", doubles: (cur && Array.isArray(cur.doubles) ? cur.doubles : []).slice(0, CAMP_WEEKS) };
    box.appendChild(el("div", "label-caps cmp-k", "Campaign " + d.n + (ph ? " · " + { soon: "Not open yet", signup: "Sign-ups open", live: "In battle", done: "Finished" }[ph] : " · Not set up")));
    var f = el("form", "own-f"); f.noValidate = true;
    function row(label, input) { var l = el("label", "own-r"); l.appendChild(el("span", null, label)); l.appendChild(input); f.appendChild(l); return input; }
    var su = el("input", "field"); su.type = "date"; su.value = d.signup; row("Sign-ups open", su);
    var sa = el("input", "field"); sa.type = "date"; sa.value = d.start; row("Starts (a Monday; rosters lock)", sa);
    var en = el("span", "own-end", d.start ? longDate(addDays(d.start, CAMP_WEEKS * 7 - 1)) : "–"); row("Ends after 6 weeks", en);
    sa.addEventListener("input", function () { en.textContent = /^\d{4}-\d{2}-\d{2}$/.test(sa.value) ? longDate(addDays(sa.value, CAMP_WEEKS * 7 - 1)) : "–"; });
    f.appendChild(el("div", "label-caps own-h", "Double points each week"));
    var kinds = []; state.tasks.forEach(function (t) { if (t.kind !== "weigh" && t.kind !== "photos" && kinds.indexOf(t.kind) < 0) kinds.push(t.kind); });
    var sels = [];
    for (var w = 0; w < CAMP_WEEKS; w++) {
      var se = el("select", "field"); var o0 = el("option", null, "None"); o0.value = ""; se.appendChild(o0);
      kinds.forEach(function (k) { var tt = state.tasks.filter(function (x) { return x.kind === k; })[0], o = el("option", null, tt ? tt.title : k); o.value = k; se.appendChild(o); });
      se.value = d.doubles[w] || ""; sels.push(se); row("Week " + (w + 1), se);
    }
    f.appendChild(el("p", "note", "The chosen box counts double that week for every man on a marching team, on his team score and his own Kingdom Warrior points."));
    var err = el("p", "error"); err.hidden = true; f.appendChild(err);
    var ok = el("p", "note ok"); ok.hidden = true; f.appendChild(ok);
    var sv = el("button", "btn", "Save campaign"); sv.type = "submit"; f.appendChild(sv);
    f.addEventListener("submit", function (ev) {
      ev.preventDefault(); err.hidden = true; ok.hidden = true;
      if (!/^\d{4}-\d{2}-\d{2}$/.test(sa.value) || parseKey(sa.value).getDay() !== 1) { err.textContent = "Pick a Monday for the start, so campaign weeks match the Board’s Monday to Sunday weeks."; err.hidden = false; return; }
      if (su.value && su.value > sa.value) { err.textContent = "Sign-ups need to open before the start."; err.hidden = false; return; }
      var o = { id: d.id, n: d.n, signup: su.value || "", start: sa.value, weeks: CAMP_WEEKS, doubles: sels.map(function (x) { return x.value; }), updatedAt: Date.now() };
      B.saveCamp("current", o).then(function () { ok.textContent = "Saved."; ok.hidden = false; }).catch(function () { err.textContent = "That didn’t save. Only the app’s owner can change campaigns."; err.hidden = false; });
    });
    box.appendChild(f);
    // Teams: rename
    var ix = campIndex();
    box.appendChild(el("div", "label-caps own-h", "Teams · " + ix.teams.length));
    if (!ix.teams.length) box.appendChild(el("p", "note", "No teams yet."));
    ix.teams.forEach(function (t) {
      var r = el("div", "own-team"); r.appendChild(bannerEl(t.banner));
      var tx = el("div", "own-tt"); var nm = el("input", "field"); nm.value = t.name; nm.maxLength = 32; nm.setAttribute("aria-label", "Team name"); tx.appendChild(nm); tx.appendChild(el("small", null, t.men.length + " men · captain " + nameOf(t.cap))); r.appendChild(tx);
      var b = el("button", "mini", "Rename"); b.type = "button"; b.addEventListener("click", function () { var v = nm.value.replace(/\s+/g, " ").trim().slice(0, 32); if (v.length >= 2) B.updateTeam(t.cap, { name: v }).catch(noop); }); r.appendChild(b);
      box.appendChild(r);
    });
    if (ph === "done") {
      var nx = el("button", "btn ghost", "Close Campaign " + d.n + " and set up Campaign " + (d.n + 1)); nx.type = "button";
      nx.addEventListener("click", function () {
        var res = campStandings().filter(function (x) { return x.t.ok; }).map(function (x) { return { name: x.t.name, banner: x.t.banner, total: Math.round(x.total * 10) / 10, men: x.t.men.length }; });
        B.saveCamp("hist_" + d.id, { id: d.id, n: d.n, start: d.start, end: campEnd(c), results: res, closedAt: Date.now() }).then(function () { return B.saveCamp("current", { id: "c" + (d.n + 1), n: d.n + 1, signup: "", start: "", weeks: CAMP_WEEKS, doubles: [], updatedAt: Date.now() }); }).catch(noop);
      });
      box.appendChild(nx);
    }
  }
'''
rep('  function drawBoard() {', CAMP + '  function drawBoard() {')
# Board: a Campaign choice in the board picker
rep('''    if (state.boardView !== "kw" && !lifts.some(function (l) { return l.id === state.boardView; })) state.boardView = "kw";
    var sig = lifts.map(function (l) { return l.id + ":" + l.name; }).join("|");''', '''    var hasCamp = !!campCfg();
    if (state.boardView !== "kw" && !(state.boardView === "camp" && hasCamp) && !lifts.some(function (l) { return l.id === state.boardView; })) state.boardView = "kw";
    var sig = lifts.map(function (l) { return l.id + ":" + l.name; }).join("|") + (hasCamp ? "|camp" : "");''')
rep('''      sel.textContent = ""; var k = el("option", null, "Kingdom Warrior"); k.value = "kw"; sel.appendChild(k);''',
    '''      sel.textContent = ""; var k = el("option", null, "Kingdom Warrior"); k.value = "kw"; sel.appendChild(k);
      if (hasCamp) { var kc = el("option", null, "Campaign: team battle"); kc.value = "camp"; sel.appendChild(kc); }''')
rep('    if (state.boardView !== "kw") { drawLiftBoard(); return; }', '    if (state.boardView === "camp") { drawCampBoard(); return; }\n    if (state.boardView !== "kw") { drawLiftBoard(); return; }')

# ---------------- pages and wiring ----------------
rep('''  <div class="page" id="page-chal" hidden>''', '''  <div class="page" id="page-team" hidden>
    <div class="pbar">
      <button class="mini" type="button" id="team-back">&lsaquo; Campaign</button>
      <span class="date label-caps">Your team</span>
    </div>
    <article id="team-body"></article>
  </div>

  <div class="page" id="page-chal" hidden>''')
rep('"today", "fuel", "train", "board", "checkin", "profile", "settings", "devo", "workout", "video", "chal", "ideas"].forEach(function (n) { $("page-" + n).hidden = n !== p; });',
    '"today", "fuel", "train", "board", "checkin", "profile", "settings", "devo", "workout", "video", "chal", "ideas", "team"].forEach(function (n) { $("page-" + n).hidden = n !== p; });')
rep('''      if (b.dataset.page === (p === "workout" || p === "video" || p === "chal" ? "train" : p === "ideas" ? "fuel" : p))''',
    '''      if (b.dataset.page === (p === "workout" || p === "video" || p === "chal" ? "train" : p === "ideas" ? "fuel" : p === "team" ? "board" : p))''')
rep('    if (p === "ideas") drawIdeas();', '    if (p === "ideas") drawIdeas();\n    if (p === "team") drawTeamPage();')
rep('''    <section aria-labelledby="h-today">''', '''    <div class="cmp-today-wrap" id="camp-today" hidden></div>
    <section aria-labelledby="h-today">''')
rep('''  function drawAll() {
    drawHeader(); drawToday();''', '''  function drawAll() {
    campDirty(); campWatchChecks();
    drawHeader(); drawCampToday(); drawToday();''')
rep('''    paintTestCtl(); drawInviteSettings(); drawFoodMode();''', '''    paintTestCtl(); drawInviteSettings(); drawFoodMode(); drawCampOwner();''')
rep('''    <section aria-labelledby="h-s-tg">''', '''    <section aria-labelledby="h-s-owner" id="s-owner-sec" hidden>
      <div class="section-head"><h2 class="label-caps" id="h-s-owner" data-sub="Only you see this. Campaign dates, the weekly double, team names.">Owner</h2></div>
      <div id="s-owner"></div>
    </section>

    <section aria-labelledby="h-s-tg">''')
rep('["h-s-wk", "h-s-body", "h-s-goal", "h-s-food", "h-s-tg",', '["h-s-wk", "h-s-body", "h-s-goal", "h-s-food", "h-s-owner", "h-s-tg",')
rep('    B.watchLifts(function (rows) { state.lifts = rows; drawAll(); });', '''    B.watchLifts(function (rows) { state.lifts = rows; drawAll(); });
    try { state.isOwner = !!(B.user && B.user.isOwner && B.user.isOwner()); } catch (e) { state.isOwner = false; }
    B.watchCamps(function (m) { state.camps = m; campDirty(); drawAll(); if (state.page === "team") drawTeamPage(); });
    B.watchTeams(function (m) { state.teams = m; campDirty(); drawAll(); loadProfiles(); if (state.page === "team") drawTeamPage(); });
    B.watchTMembers(function (m) { state.tmem = m; campDirty(); drawAll(); if (state.page === "team") drawTeamPage(); });''')
rep('    $("adj-targets").addEventListener("click", function () { openSettingsSection("h-s-tg"); });',
    '    $("adj-targets").addEventListener("click", function () { openSettingsSection("h-s-tg"); });\n    $("team-back").addEventListener("click", openCampBoard);')

# ---------------- styles ----------------
rep('/* Devotional reading */', '''/* Campaigns */
.cbn-w { display: block; width: 46px; height: 52px; flex: none; } .cbn-w.big { width: 84px; height: 95px; }
.cbn { display: block; width: 100%; height: 100%; overflow: visible; }
.cbn-fr { fill: #1d140d; fill: color-mix(in srgb, var(--c) 16%, #14120d); stroke: var(--c); stroke-width: 2.6; stroke-linejoin: round; }
.cbn-st { fill: none; stroke: var(--c); stroke-width: 1; stroke-dasharray: 2.2 2; opacity: .55; }
.cbn-o { fill: none; stroke: #f1e9d2; stroke-width: 1.7; stroke-linecap: round; stroke-linejoin: round; } .cbn-f { fill: #f1e9d2; }
.cmp-head { position: relative; display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 6px 10px; margin: 0 0 10px; }
.cmp-k { color: var(--muted); font-size: 12px; } .cmp-k.acc { color: var(--accent); }
.cmp-dbl { display: flex; gap: 10px; align-items: center; padding: 10px 12px; margin: 0 0 10px; border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 8px; background: var(--surface); }
.cmp-dbl svg { width: 26px; height: 26px; flex: none; fill: none; stroke: var(--accent); stroke-width: 2; stroke-linejoin: round; }
.cmp-dbl b { display: block; font-family: var(--f-label); font-size: 18px; text-transform: uppercase; } .cmp-dbl small { display: block; color: var(--muted); font-size: 13px; }
.cmp-row { display: grid; grid-template-columns: 22px 46px minmax(0, 1fr) auto; gap: 10px; align-items: center; width: 100%; padding: 10px 12px; margin: 0 0 8px; text-align: left; font: inherit; color: var(--ink); border: 1px solid var(--line); border-radius: 8px; background: var(--surface); cursor: pointer; }
.cmp-row.me { border-color: var(--accent); box-shadow: inset 3px 0 0 var(--accent); } .cmp-row.out { opacity: .6; }
.cmp-rk { font-family: var(--f-label); font-weight: 800; font-size: 20px; color: var(--accent); text-align: center; }
.cmp-tx { display: grid; gap: 2px; min-width: 0; }
.cmp-nm { font-family: var(--f-label); font-weight: 800; font-size: 17px; line-height: 1.1; text-transform: uppercase; overflow-wrap: anywhere; }
.cmp-you { margin-left: 6px; font-style: normal; font-size: 10.5px; letter-spacing: .08em; padding: 1px 6px; border: 1px solid var(--accent); border-radius: 9px; color: var(--accent); vertical-align: middle; }
.cmp-sub { font-size: 13px; color: var(--muted); } .cmp-sub b { color: var(--accent); }
.cmp-sc { text-align: right; } .cmp-sc b { display: block; font-family: var(--f-label); font-size: 21px; } .cmp-sc small { font-size: 12px; color: var(--muted); }
.cmp-today-wrap { margin: 0 0 14px; }
.cmp-today { display: grid; grid-template-columns: 46px minmax(0, 1fr); gap: 12px; align-items: center; width: 100%; padding: 12px; text-align: left; font: inherit; color: var(--ink); border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 8px; background: var(--surface); cursor: pointer; }
.cmp-today.col { display: grid; grid-template-columns: 1fr; gap: 8px; cursor: default; }
.cmp-inv { display: grid; grid-template-columns: 46px minmax(0, 1fr); gap: 10px; align-items: center; padding: 6px 0; border-top: 1px solid var(--line); }
.cmp-acts { grid-column: 1 / -1; display: flex; gap: 8px; } .cmp-acts .mini { flex: 1; }
.cmp-two { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; } .cmp-two .btn { min-width: 0; padding-left: 6px; padding-right: 6px; }
.tm-head { display: grid; grid-template-columns: 84px minmax(0, 1fr); gap: 14px; align-items: center; margin: 4px 0 12px; }
.tm-nm { margin: 2px 0; overflow-wrap: anywhere; } .tm-cap { margin: 0; }
.tm-stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; margin: 0 0 10px; }
.tm-stat { padding: 10px 6px; text-align: center; border: 1px solid var(--line); border-radius: 8px; background: var(--surface); }
.tm-stat b { display: block; font-family: var(--f-label); font-size: 23px; } .tm-stat span { font-size: 11.5px; color: var(--muted); letter-spacing: .06em; text-transform: uppercase; }
.tm-h { margin: 14px 0 6px; }
.tm-men { border: 1px solid var(--line); border-radius: 8px; background: var(--surface); padding: 2px 12px; margin-bottom: 6px; }
.tm-man { display: grid; grid-template-columns: 36px minmax(0, 1fr) auto; gap: 10px; align-items: center; padding: 8px 0; border-top: 1px solid var(--line); }
.tm-man:first-child { border-top: 0; } .tm-man .avatar { width: 36px; height: 36px; } .tm-man.pend { opacity: .75; }
.tm-mn { font-weight: 700; overflow-wrap: anywhere; } .tm-mn em { margin-left: 6px; font-style: normal; font-size: 11px; color: var(--accent); }
.tm-tag { display: inline-block; margin-left: 6px; padding: 1px 7px; border: 1px solid var(--accent); border-radius: 9px; font-family: var(--f-label); font-weight: 700; font-size: 10.5px; letter-spacing: .08em; text-transform: uppercase; color: var(--accent); vertical-align: middle; }
.tm-days { display: flex; gap: 4px; margin-top: 4px; }
.tm-day { width: 22px; height: 22px; border: 1.5px solid var(--line); border-radius: 4px; display: grid; place-items: center; font-size: 10px; color: var(--muted); }
.tm-day.on { background: var(--accent); border-color: var(--accent); color: #111; } .tm-day.now { outline: 1.5px solid var(--ink); outline-offset: 1px; }
#team-body > .btn { width: 100%; margin-top: 8px; }
.rt-box { max-height: 88vh; overflow-y: auto; } .rt-box .btn { width: 100%; margin-top: 8px; }
.rt-chips { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 10px; }
.rt-chip { padding: 6px 10px; font: inherit; font-size: 13.5px; color: var(--ink); background: var(--surface); border: 1px solid var(--line); border-radius: 16px; cursor: pointer; text-align: left; }
.rt-chip small { margin-left: 5px; color: var(--muted); font-size: 11px; } .rt-chip.on { border-color: var(--accent); color: var(--accent); }
.rt-grid { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 6px; }
.rt-ban { display: grid; justify-items: center; gap: 3px; padding: 6px 0; font: inherit; font-size: 11px; color: var(--muted); background: none; border: 1px solid transparent; border-radius: 8px; cursor: pointer; }
.rt-ban .cbn-w { width: 40px; height: 45px; } .rt-ban.on { border-color: var(--accent); background: var(--surface); color: var(--ink); }
.ci-box { max-height: 86vh; overflow-y: auto; } .ci-box .btn { width: 100%; margin-top: 8px; }
.ci-list { display: grid; gap: 2px; margin-top: 8px; }
.ci-row { display: grid; grid-template-columns: 34px minmax(0, 1fr) auto; gap: 10px; align-items: center; padding: 6px 0; border-top: 1px solid var(--line); }
.ci-row .avatar { width: 34px; height: 34px; } .ci-n { overflow-wrap: anywhere; } .ci-n small { color: var(--muted); }
.own-f { display: grid; gap: 8px; }
.own-r { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 170px); gap: 10px; align-items: center; font-size: 14.5px; }
.own-r .field { width: 100%; max-width: 170px; min-width: 0; justify-self: end; } .own-r > span:first-child { min-width: 0; } .own-end { font-weight: 700; }
.own-h { margin-top: 12px; color: var(--brass); }
.own-team { display: grid; grid-template-columns: 46px minmax(0, 1fr) auto; gap: 10px; align-items: center; padding: 8px 0; border-top: 1px solid var(--line); }
.own-tt { display: grid; gap: 3px; min-width: 0; } .own-tt small { color: var(--muted); }
#s-owner .btn { width: 100%; margin-top: 8px; }
/* Devotional reading */''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
