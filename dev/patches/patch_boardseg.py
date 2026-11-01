#!/usr/bin/env python3
"""Board: two big buttons at the top, Individual and Campaign. Individual keeps the picker for Kingdom Warrior and the
lift PR boards; Campaign goes straight to the team standings. The Campaign button always shows; with no campaign set it says the next one is coming, and Today
carries a matching campaign card in every phase (coming soon, sign-ups soon, live but not on a team, finished).
Usage: patch_boardseg.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''      <label class="lb-pick"><select class="field" id="board-sel" aria-label="Choose a board"></select></label>''',
'''      <div class="bd-seg" id="bd-seg" role="group" aria-label="Which board" hidden>
        <button type="button" id="bd-ind" aria-pressed="true"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="7.6" r="3.6"/><path d="M4.6 20.4c.8-4.2 3.8-6.6 7.4-6.6s6.6 2.4 7.4 6.6"/></svg>Individual</button>
        <button type="button" id="bd-camp" aria-pressed="false"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3h14v12.6L12 21l-7-5.4Z"/><path d="M9 8.6h6M12 6v8"/></svg>Campaign</button>
      </div>
      <label class="lb-pick" id="board-pick"><select class="field" id="board-sel" aria-label="Choose a board"></select></label>''')
rep('''.lb-pick { display: block; margin-bottom: 10px; }''',
'''.lb-pick { display: block; margin-bottom: 10px; }
.bd-seg { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 12px; }
.bd-seg button { display: flex; align-items: center; justify-content: center; gap: 8px; min-height: 48px; padding: 10px; border: 1px solid var(--line); border-radius: 8px; background: var(--surface); color: var(--ink); font-family: var(--f-label); font-weight: 800; font-size: 15px; letter-spacing: .1em; text-transform: uppercase; cursor: pointer; }
.bd-seg button svg { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; flex: none; }
.bd-seg button[aria-pressed="true"] { background: var(--accent); border-color: var(--accent); color: #111; }''')
rep('''      if (hasCamp) { var kc = el("option", null, "Campaign: team battle"); kc.value = "camp"; sel.appendChild(kc); }
''', '')
rep('''    sel.value = state.boardView;
  }''', '''    var isCamp = state.boardView === "camp";
    $("bd-seg").hidden = false; $("board-pick").hidden = isCamp;
    $("bd-ind").setAttribute("aria-pressed", String(!isCamp)); $("bd-camp").setAttribute("aria-pressed", String(isCamp));
    if (!isCamp) sel.value = state.boardView;
  }''')
rep('''    $("board-sel").addEventListener("change", function (ev) { state.boardView = ev.target.value; drawBoard(); });''',
'''    $("board-sel").addEventListener("change", function (ev) { state.boardView = ev.target.value; drawBoard(); });
    $("bd-ind").addEventListener("click", function () { if (state.boardView === "camp") { state.boardView = state.boardIndView || "kw"; drawBoard(); } });
    $("bd-camp").addEventListener("click", function () { if (state.boardView !== "camp") { state.boardIndView = state.boardView; state.boardView = "camp"; drawBoard(); } });''')
rep('''    if (state.boardView !== "kw" && !(state.boardView === "camp" && hasCamp) &&''', '''    if (state.boardView !== "kw" && state.boardView !== "camp" &&''')
rep('''if (!c) { $("h-board").textContent = "Campaign"; box.appendChild(el("p", "note", "No campaign set up yet.")); return; }''',
'''if (!c) { $("h-board").textContent = "Campaign"; var cs = el("div", "cmp-soon"); cs.appendChild(bannerEl("trumpet")); var cx = el("span", "cmp-tx"); cx.appendChild(el("span", "label-caps cmp-k", "Next campaign")); cx.appendChild(el("span", "cmp-nm", "Coming soon")); cx.appendChild(el("span", "cmp-sub", "Teams of " + CAMP_MIN + " to " + CAMP_MAX + " men battle for " + CAMP_WEEKS + " weeks. Sign-ups show here and on Today when they open. Until then, compete on the Individual board.")); cs.appendChild(cx); box.appendChild(cs); if (state.isOwner) { var g0 = el("button", "mini cmp-gear", "Owner settings"); g0.type = "button"; g0.addEventListener("click", function () { openSettingsSection("h-s-owner"); }); box.appendChild(g0); } return; }''')
rep('''var ix = campIndex(), c = ix.c; if (!c || !state.me) return; var ph = campPhase(c); if (ph !== "live" && ph !== "signup") return;''',
'''var ix = campIndex(), c = ix.c; if (!state.me) return; var ph = campPhase(c); if (ph !== "live" && ph !== "signup") { campSoonCard(box, c, ph); return; }''')
rep('''    if (ph !== "signup") return;
    var mm = (state.tmem''', '''    if (ph !== "signup") { campSoonCard(box, c, ph); return; }
    var mm = (state.tmem''')
rep('''  function drawCampToday() {''', '''  /* Today card when a brother isn't in the battle: no campaign yet, sign-ups not open, a live campaign he isn't on a
     team for, or a finished one. Tap opens the Campaign board. */
  function campSoonCard(box, c, ph) {
    var n = c ? (c.n || 1) : 0, k, nm, sub, lead = null;
    if (!c || ph === "done") {
      var win = c ? (campStandings().filter(function (y) { return y.t.ok; })[0] || null) : null;
      k = "Next campaign"; nm = "Coming soon";
      sub = (win ? "Campaign " + n + " is over. " + win.t.name + " took it. " : "") + "Teams of " + CAMP_MIN + " to " + CAMP_MAX + " men battle for " + CAMP_WEEKS + " weeks. Sign-ups show here when they open.";
    } else if (ph === "soon") {
      k = "Campaign " + n; nm = c.signup ? "Sign-ups open " + campDateText(c.signup) : "Coming soon";
      sub = "Teams of " + CAMP_MIN + " to " + CAMP_MAX + " men battle for " + CAMP_WEEKS + " weeks, starting " + campDateText(c.start) + ".";
    } else {
      lead = campStandings().filter(function (y) { return y.t.ok; })[0] || null;
      k = "Campaign " + n + " · Week " + (campWeekIdx(c, todayKey()) + 1) + " of " + CAMP_WEEKS; nm = lead ? lead.t.name + " leads" : "The battle is on";
      sub = "You’re not on a team this campaign, so you compete on the Individual board. Sign-ups for the next one show here.";
    }
    var b = el("button", "cmp-today"); b.type = "button"; b.appendChild(bannerEl(lead ? lead.t.banner : "trumpet"));
    var tx = el("span", "cmp-tx"); tx.appendChild(el("span", "label-caps cmp-k", k)); tx.appendChild(el("span", "cmp-nm", nm)); tx.appendChild(el("span", "cmp-sub", sub));
    b.appendChild(tx); b.addEventListener("click", openCampBoard); box.appendChild(b); box.hidden = false;
  }
  function drawCampToday() {''')
rep('''.bd-seg { display: grid;''', '''.cmp-soon { display: grid; grid-template-columns: 52px minmax(0, 1fr); gap: 12px; align-items: center; padding: 12px; margin-bottom: 10px; border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 8px; background: var(--surface); }
.cmp-soon .cmp-tx { display: grid; gap: 2px; }
.bd-seg { display: grid;''')
n = len(re.findall(r'v214', s)); s = s.replace('v214', ver)
open(dst, 'w').write(s); print('ok', dst, n)
