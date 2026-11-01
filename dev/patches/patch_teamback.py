#!/usr/bin/env python3
"""Team page: don't force a brother onto the Campaign board. Opened from Today, the back button says "‹ Today" and goes
back to Today, with a "Campaign ›" button beside it to jump into the standings. Opened from the Board it still says
"‹ Campaign". Coming back from team chat keeps where he started.
Usage: patch_teamback.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''      <button class="mini" type="button" id="team-back">&lsaquo; Campaign</button>
      <span class="date label-caps">Your team</span>''',
'''      <button class="mini" type="button" id="team-back">&lsaquo; Campaign</button>
      <span class="date label-caps">Your team</span>
      <button class="mini team-camp" type="button" id="team-camp" hidden>Campaign &rsaquo;</button>''')
rep('''  function openTeam(id) { state.teamId = id; go("team"); drawTeamPage(); }''',
'''  function openTeam(id) {
    state.teamFrom = state.page === "today" ? "today" : (state.page === "team" || state.page === "checkin") ? (state.teamFrom || "board") : "board";
    var fromToday = state.teamFrom === "today";
    $("team-back").textContent = fromToday ? "\\u2039 Today" : "\\u2039 Campaign"; $("team-camp").hidden = !fromToday;
    state.teamId = id; go("team"); drawTeamPage();
  }''')
rep('''    $("team-back").addEventListener("click", openCampBoard);''',
'''    $("team-back").addEventListener("click", function () { if (state.teamFrom === "today") go("today"); else openCampBoard(); });
    $("team-camp").addEventListener("click", openCampBoard);''')
rep('''.bd-seg { display: grid;''', '''.team-camp { margin-left: auto; }
.bd-seg { display: grid;''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
