#!/usr/bin/env python3
"""Campaign tab: a bottom-bar button that always shows. It houses everything about campaigns except points and
standings, which stay on the Board. Between campaigns it says the next one is to be announced (with the last
champion). During sign-ups: invites, Raise a team, the teams forming. Live: your team, this week's double, Wall Held,
team chat, and a button to the standings on the Board. Today's campaign card, "See the teams" and the team page's back
button now lead here. Requested by Curtis 2026-11-01.
Usage: patch_camptab.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new, count=1):
    global s
    assert s.count(old) == count, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

BANNER_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3h14v12.6L12 21l-7-5.4Z"/><path d="M9 8.6h6M12 6v8"/></svg>'
rep('''  <button type="button" data-page="checkin">''', '''  <button type="button" data-page="camp">''' + BANNER_ICON + '''Campaign</button>
  <button type="button" data-page="checkin">''')
rep('''  display: grid; grid-template-columns: repeat(6, minmax(0, 1fr));''', '''  display: grid; grid-template-columns: repeat(7, minmax(0, 1fr));''')
rep('''  <div class="page" id="page-team" hidden>''', '''  <div class="page" id="page-camp" hidden>
    <header>
      <div class="topline"><span class="date label-caps">Iron sharpens iron</span><button type="button" class="me-btn" data-open="me" aria-label="Your profile"></button></div>
      <h1 class="pg">Campaign</h1>
    </header>
    <div id="camp-page"></div>
  </div>

  <div class="page" id="page-team" hidden>''')
# routing
rep('''"chal", "ideas", "team"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''', '''"chal", "ideas", "team", "camp"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''')
rep('''p === "team" || (p === "checkin" && state.chan) ? "board" : p)) b.setAttribute("aria-current", "page");''', '''p === "team" || (p === "checkin" && state.chan) ? "camp" : p)) b.setAttribute("aria-current", "page");''')
rep('''    if (p === "team") drawTeamPage();
''', '''    if (p === "team") drawTeamPage();
    if (p === "camp") drawCampPage();
''')
rep('''    drawDevo();
  }''', '''    drawDevo(); if (state.page === "camp") drawCampPage();
  }''')
# team page origin
rep('''    state.teamFrom = state.page === "today" ? "today" : (state.page === "team" || state.page === "checkin") ? (state.teamFrom || "board") : "board";
    var fromToday = state.teamFrom === "today";
    $("team-back").textContent = fromToday ? "\\u2039 Today" : "\\u2039 Campaign"; $("team-camp").hidden = !fromToday;''',
'''    state.teamFrom = state.page === "today" ? "today" : state.page === "camp" ? "camp" : (state.page === "team" || state.page === "checkin") ? (state.teamFrom || "camp") : "board";
    var fromToday = state.teamFrom === "today";
    $("team-back").textContent = fromToday ? "\\u2039 Today" : state.teamFrom === "board" ? "\\u2039 Standings" : "\\u2039 Campaign"; $("team-camp").hidden = !fromToday;''')
rep('''    $("team-back").addEventListener("click", function () { if (state.teamFrom === "today") go("today"); else openCampBoard(); });''',
    '''    $("team-back").addEventListener("click", function () { if (state.teamFrom === "today") go("today"); else if (state.teamFrom === "board") openCampBoard(); else go("camp"); });''')
rep('''    $("team-camp").addEventListener("click", openCampBoard);''', '''    $("team-camp").addEventListener("click", function () { go("camp"); });''')
# Today card + "See the teams" go to the Campaign tab
rep('''    b.appendChild(tx); b.addEventListener("click", openCampBoard); box.appendChild(b); box.hidden = false;''', '''    b.appendChild(tx); b.addEventListener("click", function () { go("camp"); }); box.appendChild(b); box.hidden = false;''')
rep('''sb.addEventListener("click", openCampBoard); two.appendChild(rb);''', '''sb.addEventListener("click", function () { go("camp"); }); two.appendChild(rb);''')
# drawCampToday can render into another box (the Campaign tab's sign-up card)
rep('''  function drawCampToday() {
    var box = $("camp-today"); if (!box) return; box.textContent = ""; box.hidden = true;''', '''  function drawCampToday(into) {
    var box = into || $("camp-today"); if (!box) return; box.textContent = ""; box.hidden = true;''')

JS = r'''
  /* Campaign tab: everything about campaigns except points and standings (those stay on the Board). */
  function campHowItWorks(box) {
    var sec = el("section", "cpg-sec"); sec.appendChild(el("h2", "label-caps", "How a campaign works"));
    var ul = el("ul", "cpg-how");
    ["A brother raises a banner and invites " + (CAMP_MIN - 1) + " to " + (CAMP_MAX - 1) + " men. Teams of " + CAMP_MIN + " to " + CAMP_MAX + " march.",
     CAMP_WEEKS + " weeks, Monday to Sunday. Rosters lock on the first day.",
     "Team score is the average Kingdom Warrior points per man each week. A brother who sits out a week doesn’t count against his team.",
     "One box counts double each week for every man in the battle.",
     "Wall Held: every man checks every box all 7 days and the team earns +" + WALL_BONUS + ".",
     "The prize is bragging rights. Standings live on the Board."].forEach(function (t) { ul.appendChild(el("li", null, t)); });
    sec.appendChild(ul); box.appendChild(sec);
  }
  function drawCampPage() {
    var box = $("camp-page"); if (!box) return; box.textContent = "";
    var ix = campIndex(), c = ix.c, ph = campPhase(c), n = c ? (c.n || 1) : 0, mine = c ? myTeam() : null;
    if (!c || ph === "done" || ph === "soon") {
      var tba = el("div", "cpg-hero"); tba.appendChild(bannerEl("trumpet", "big"));
      var tx = el("div");
      if (ph === "soon") { tx.appendChild(el("div", "label-caps cmp-k acc", "Campaign " + n)); tx.appendChild(el("h2", "cpg-h", "Sign-ups open " + campDateText(c.signup || c.start))); tx.appendChild(el("p", "note", "Starts " + longDate(c.start) + ". Start thinking about who you’ll march with.")); }
      else { tx.appendChild(el("div", "label-caps cmp-k acc", "Next campaign")); tx.appendChild(el("h2", "cpg-h", "To be announced")); tx.appendChild(el("p", "note", "The next campaign date will be announced. Sign-ups will show here and on Today.")); }
      tba.appendChild(tx); box.appendChild(tba);
      if (c && ph === "done") {
        var win = campStandings().filter(function (y) { return y.t.ok; })[0];
        if (win) { var ch = el("button", "cpg-champ"); ch.type = "button"; ch.appendChild(bannerEl(win.t.banner)); var ct = el("span"); ct.appendChild(el("span", "label-caps cmp-k", "Campaign " + n + " champions")); ct.appendChild(el("b", null, win.t.name)); ct.appendChild(el("small", null, "Final standings are on the Board.")); ch.appendChild(ct); ch.addEventListener("click", openCampBoard); box.appendChild(ch); }
      }
    } else if (ph === "signup") {
      var sg = el("div"); drawCampToday(sg); sg.hidden = false; Array.prototype.forEach.call(sg.querySelectorAll("button"), function (b) { if (b.textContent === "See the teams") b.remove(); }); box.appendChild(sg);
      var teams = ix.teams || [];
      var ts = el("section", "cpg-sec"); ts.appendChild(el("h2", "label-caps", "Teams forming · " + teams.length));
      if (!teams.length) ts.appendChild(el("p", "note", "No banners raised yet. Be the first."));
      teams.forEach(function (t) { var r = el("button", "cpg-team" + (mine && mine.id === t.id ? " me" : "")); r.type = "button"; r.appendChild(bannerEl(t.banner)); var rt = el("span"); rt.appendChild(el("b", null, t.name)); rt.appendChild(el("small", null, t.men.length + " of " + CAMP_MAX + " men" + (t.ok ? " · ready to march" : " · needs " + (CAMP_MIN - t.men.length) + " more") + " · Captain " + nameOf(t.cap))); r.appendChild(rt); r.appendChild(el("span", "chev", "›")); r.addEventListener("click", function () { openTeam(t.id); }); ts.appendChild(r); });
      box.appendChild(ts);
    } else {
      var w = campWeekIdx(c, todayKey());
      box.appendChild(el("p", "label-caps cpg-wk", "Campaign " + n + " · Week " + (w + 1) + " of " + CAMP_WEEKS + " · " + campDateText(c.start) + " – " + campDateText(campEnd(c))));
      if (mine) {
        var st = campStandings(), x = st.filter(function (y) { return y.t.id === mine.id; })[0] || {};
        var yt = el("div", "cpg-mine"), top = el("button", "cpg-mtop"); top.type = "button"; top.appendChild(bannerEl(mine.banner, "big"));
        var mt = el("span"); mt.appendChild(el("span", "label-caps cmp-k acc", "Your team")); mt.appendChild(el("b", "cpg-mn", mine.name)); mt.appendChild(el("small", null, mine.men.length + " men · Captain " + nameOf(mine.cap))); top.appendChild(mt); top.appendChild(el("span", "chev", "›"));
        top.addEventListener("click", function () { openTeam(mine.id); }); yt.appendChild(top);
        if (x.cur) { var wl = el("div", "cpg-wall"); var dots = el("span", "cpg-dots"); for (var i = 0; i < 7; i++) dots.appendChild(el("i", i < x.cur.wallDays ? "on" : "")); wl.appendChild(el("span", null, "Wall held " + x.cur.wallDays + " of 7 days")); wl.appendChild(dots); yt.appendChild(wl); }
        var un = teamUnread(mine.id), chb = el("button", "btn ghost cpg-chat", "Team chat" + (un ? " · " + un + " new" : "")); chb.type = "button"; chb.addEventListener("click", function () { openTeamChat(mine.id); }); yt.appendChild(chb);
        box.appendChild(yt);
      } else {
        var nt = el("div", "cpg-hero"); nt.appendChild(bannerEl("trumpet", "big")); var ntx = el("div"); ntx.appendChild(el("div", "label-caps cmp-k acc", "Not on a team")); ntx.appendChild(el("h2", "cpg-h", "The battle is on")); ntx.appendChild(el("p", "note", "You compete on the Individual board this campaign. Sign-ups for the next one show here.")); nt.appendChild(ntx); box.appendChild(nt);
      }
      if (campDoubleLabel(c, w)) box.appendChild(campDoubleCard(c, w));
    }
    var sb = el("button", "btn ghost cpg-stand", "Standings and points on the Board ›"); sb.type = "button"; sb.disabled = !c; sb.addEventListener("click", openCampBoard); if (c) box.appendChild(sb);
    campHowItWorks(box);
    if (state.isOwner) { var ow = el("button", "mini cpg-owner", "Owner settings"); ow.type = "button"; ow.addEventListener("click", function () { openSettingsSection("h-s-owner"); }); box.appendChild(ow); }
  }
'''
rep('''  /* Team page */''', JS + '''  /* Team page */''')
CSS = '''
.cpg-hero { display: grid; grid-template-columns: 72px minmax(0, 1fr); gap: 14px; align-items: center; padding: 16px; margin: 0 0 12px; border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 10px; background: var(--surface); }
.cpg-h { font-family: var(--f-label); font-weight: 800; text-transform: uppercase; letter-spacing: .05em; font-size: 24px; margin: 2px 0 4px; }
.cpg-hero .note { margin: 0; }
.cpg-champ, .cpg-team, .cpg-mtop { width: 100%; display: grid; grid-template-columns: 46px minmax(0, 1fr) auto; gap: 12px; align-items: center; padding: 12px; text-align: left; font: inherit; color: var(--ink); border: 1px solid var(--line); border-radius: 10px; background: var(--surface); cursor: pointer; }
.cpg-champ { margin-bottom: 12px; grid-template-columns: 46px minmax(0, 1fr); }
.cpg-champ span, .cpg-team span, .cpg-mtop > span:not(.chev) { display: grid; gap: 2px; min-width: 0; }
.cpg-champ b, .cpg-team b { font-family: var(--f-label); font-weight: 800; text-transform: uppercase; letter-spacing: .04em; font-size: 17px; }
.cpg-champ small, .cpg-team small, .cpg-mtop small { color: var(--muted); font-size: 13px; }
.cpg-team { margin-top: 8px; } .cpg-team.me { border-color: var(--accent); }
.cpg-sec { margin: 18px 0 0; } .cpg-sec h2 { margin: 0 0 8px; }
.cpg-how { margin: 0; padding: 0; list-style: none; display: grid; gap: 8px; }
.cpg-how li { position: relative; padding-left: 20px; font-size: 14.5px; line-height: 1.45; } .cpg-how li::before { content: "\\2022"; position: absolute; left: 4px; color: var(--accent); font-weight: 700; }
.cpg-wk { color: var(--muted); margin: 0 0 10px; }
.cpg-mine { border: 1px solid var(--accent); border-radius: 12px; background: var(--surface); padding: 6px; margin-bottom: 12px; }
.cpg-mine .cpg-mtop { border: 0; grid-template-columns: 72px minmax(0, 1fr) auto; }
.cpg-mn { font-family: var(--f-label); font-weight: 800; text-transform: uppercase; letter-spacing: .04em; font-size: 22px; }
.cpg-wall { display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 10px 12px; border-top: 1px solid var(--line); font-size: 14.5px; }
.cpg-dots { display: flex; gap: 5px; } .cpg-dots i { width: 12px; height: 12px; border-radius: 3px; border: 1px solid var(--line); } .cpg-dots i.on { background: var(--accent); border-color: var(--accent); }
.cpg-chat { width: calc(100% - 12px); margin: 4px 6px 6px; }
.cpg-stand { width: 100%; margin-top: 12px; }
.cpg-owner { margin-top: 16px; }
.tabbar button { min-width: 0; }
.tabbar { padding-left: max(2px, env(safe-area-inset-left, 0px)); padding-right: max(2px, env(safe-area-inset-right, 0px)); }
.tabbar.tabbar button { padding-left: 0; padding-right: 0; overflow: hidden; }
@media (max-width: 430px) { .tabbar.tabbar button { font-size: 9.5px; letter-spacing: 0; } .tabbar.tabbar svg { width: 22px; height: 22px; } }
'''
rep('''.lg-ib { display: flex; gap: 8px; margin-bottom: 10px; }''', '''.lg-ib { display: flex; gap: 8px; margin-bottom: 10px; }''' + CSS)
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
