import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
def rep(a,b,n=1):
    global s; assert s.count(a)==n,(s.count(a),a[:90]); s=s.replace(a,b)
WALK_SVG='<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="8" cy="7" r="2.6"/><circle cx="16.5" cy="8" r="2.2"/><path d="M3.5 20c.4-4 2.2-6.5 4.5-6.5s4 2.5 4.5 6.5M12.5 20c.3-3 1.8-5 4-5s3.6 2 4 5"/></svg>'
# Tab bar: Today, Fuel, Train, Walk, Board, Rally. Campaign lives under Board.
rep('''  <button type="button" data-page="board"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 20V10M12 20V4M19 20v-7"/></svg>Board</button>
  <button type="button" data-page="camp"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3h14v12.6L12 21l-7-5.4Z"/><path d="M9 8.6h6M12 6v8"/></svg>Campaign</button>''',
'''  <button type="button" data-page="walk">'''+WALK_SVG+'''Walk</button>
  <button type="button" data-page="board"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 20V10M12 20V4M19 20v-7"/></svg>Board</button>''')
# Router
rep('''  function go(p) {
    if (p === "board" && state.page !== "board") state.boardView = "kw";''','''  function go(p) {
    if (p === "walk") p = state.walkPage === "journal" ? "journal" : "mentor";
    if (p === "mentor" || p === "journal") state.walkPage = p;
    if (p === "board" && state.page !== "board") state.boardView = "kw";''')
rep(''': p === "mentor" || p === "journal" ? "today" : p === "team" || (p === "checkin" && state.chan) ? "camp" : p))''',''': p === "mentor" || p === "journal" ? "walk" : p === "camp" || p === "team" || (p === "checkin" && state.chan) ? "board" : p))''')
rep('''    if (p === "mentor") drawMentorPage();
    if (p === "journal") drawJournalPage();''','''    if (p === "mentor") { drawMentorPage(); drawWalkBold(); }
    if (p === "journal") drawJournalPage();
    if (p === "mentor" || p === "journal") paintWalkSeg();
    if (p === "camp") paintCampSeg();''')
# Walk headers on Paul & Timothy and Journal pages
SEG='''<div class="walk-seg" role="group" aria-label="Walk"><button type="button" data-w="mentor">Brothers</button><button type="button" data-w="journal">Journal</button><button type="button" data-w="pray">Prayers</button></div>'''
rep('''  <div class="page" id="page-journal" hidden>
    <div class="pbar">
      <button class="mini" type="button" id="jr-back">&lsaquo; Today</button>
      <span class="date label-caps">Write it down</span>
      <button type="button" class="jr-pen" id="jr-new" aria-label="New journal entry"></button>
    </div>
    <h1 class="pg">My journal</h1>''','''  <div class="page" id="page-journal" hidden>
    <header>
      <div class="topline"><span class="date label-caps">Walk with God · Private</span><button type="button" class="me-btn" data-open="me" aria-label="Your profile"></button></div>
      <h1 class="pg">Walk</h1>
    </header>
    <button class="mini" type="button" id="jr-back" hidden>&lsaquo; Today</button><button type="button" class="jr-pen" id="jr-new" aria-label="New journal entry" hidden></button>
    '''+SEG)
rep('''  <div class="page" id="page-mentor" hidden>
    <div class="pbar">
      <button class="mini" type="button" id="men-back">&lsaquo; Today</button>
      <span class="date label-caps">Iron sharpens iron</span>
    </div>
    <h1 class="pg">Paul &amp; Timothy</h1>
    <div id="men-body"></div>''','''  <div class="page" id="page-mentor" hidden>
    <header>
      <div class="topline"><span class="date label-caps">Walk with your brothers</span><button type="button" class="me-btn" data-open="me" aria-label="Your profile"></button></div>
      <h1 class="pg">Walk</h1>
    </header>
    <button class="mini" type="button" id="men-back" hidden>&lsaquo; Today</button>
    <div class="walk-v"><q>“Iron sharpens iron, and one man sharpens another.”</q><small>Proverbs 27:17 (ESV)</small></div>
    '''+SEG+'''
    <div id="men-body"></div>
    <div id="walk-bold"></div>''')
# Campaign page gets the Board switch
rep('''      <h1 class="pg">Campaign</h1>
    </header>
    <div id="camp-page"></div>''','''      <h1 class="pg">Campaign</h1>
    </header>
    <div class="bd-seg" id="camp-seg" role="group" aria-label="Which board"><button type="button" id="cs-ind" aria-pressed="false"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="7.6" r="3.6"/><path d="M4.6 20.4c.8-4.2 3.8-6.6 7.4-6.6s6.6 2.4 7.4 6.6"/></svg>Individual</button><button type="button" id="cs-camp" aria-pressed="true"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3h14v12.6L12 21l-7-5.4Z"/><path d="M9 8.6h6M12 6v8"/></svg>Campaign</button></div>
    <div id="camp-page"></div>''')
# Board's Campaign button opens the Campaign page (signup, team, standings)
rep('''    $("bd-camp").addEventListener("click", function () { if (state.boardView !== "camp") { state.boardIndView = state.boardView; state.boardView = "camp"; drawBoard(); } });''','''    $("bd-camp").addEventListener("click", function () { if (state.boardView === "camp") return; state.boardIndView = state.boardView; go("camp"); });
    $("cs-ind").addEventListener("click", function () { go("board"); });
    Array.prototype.forEach.call(document.querySelectorAll(".walk-seg button"), function (b) { b.addEventListener("click", function () {
      if (b.dataset.w === "mentor") { state.menView = ""; go("mentor"); } else { jrUI.tab = b.dataset.w === "pray" ? "pray" : "all"; go("journal"); } }); });''')
# Today: the Paul & Timothy card and the Journal row move to Walk
rep('''  function drawMentorToday() {
    var box = $("mentor-today"); if (!box) return; box.textContent = ""; if (!state.me || !state.mentorLoaded) return;''','''  function drawMentorToday() {
    var box = $("mentor-today"); if (!box) return; box.textContent = ""; walkBadge(); return; // Paul & Timothy moved to the Walk tab.
    if (!state.me || !state.mentorLoaded) return;''')
rep('''    if (state.me) {
      var jt = journalToday(), jli = el("li", "item fr-li"), jb = el("button", "hit fr-open"); jb.type = "button"; jb.id = "jr-today";''','''    if (false) { // Journal moved to the Walk tab.
      var jt = journalToday(), jli = el("li", "item fr-li"), jb = el("button", "hit fr-open"); jb.type = "button"; jb.id = "jr-today";''')
# Walk helpers
NEW=r'''  /* ---------- Walk tab: Paul & Timothy (Brothers) and the journal (Journal, Prayers) ---------- */
  function paintWalkSeg() {
    var cur = state.page === "mentor" ? "mentor" : jrUI.tab === "pray" || jrUI.tab === "ans" ? "pray" : "journal";
    Array.prototype.forEach.call(document.querySelectorAll(".walk-seg button"), function (b) { b.setAttribute("aria-pressed", String(b.dataset.w === cur)); });
  }
  function paintCampSeg() { var a = $("cs-ind"), c = $("cs-camp"); if (a) { a.setAttribute("aria-pressed", "false"); c.setAttribute("aria-pressed", "true"); } }
  function walkBadge() {
    // A dot on the Walk tab when a brother asked to pair, or your weekly check-in with your Paul is still due.
    var b = document.querySelector('.tabbar button[data-page="walk"]'); if (!b) return;
    var due = false;
    try { if (state.me && state.mentorLoaded) { var p = myPaul(), wk = menOf(state.me).chk[menWeek()]; due = menRequests().length > 0 || (!!p && !wk); } } catch (e) {}
    b.classList.toggle("has-dot", due);
    b.setAttribute("aria-label", due ? "Walk, something needs you" : "Walk");
  }
  function drawWalkBold() {
    var box = $("walk-bold"); if (!box) return; box.textContent = "";
    var b = state.me ? boldNow() : null; if (!b) return;
    box.appendChild(el("p", "label-caps walk-h", "This week"));
    var c = el("button", "bold-card" + (b.done ? " done" : "")); c.type = "button";
    var ic = el("span", "bc-ic"); ic.innerHTML = chalBadgeSvg(b.c, false); c.appendChild(ic);
    var t = el("span", "bc-t"); t.appendChild(el("span", "bc-k", "Bold Step")); t.appendChild(el("span", "bc-n", b.step ? b.step.t : "Pick one hard thing you’ve been avoiding.")); c.appendChild(t);
    c.appendChild(el("span", "bc-tag", b.done ? "✓ Done" : b.step ? "Send to Paul" : "Pick"));
    c.addEventListener("click", function () { openBold(); }); box.appendChild(c);
  }
  function drawJournalTop(body) {
    var w = el("div", "walk-cards");
    var wr = el("button", "walk-card on"); wr.type = "button"; wr.id = "walk-write";
    var wt = el("span"); wt.appendChild(el("b", null, "Write it down")); wt.appendChild(el("small", null, "A win, a struggle, a prayer, something God showed you. Only you can read it.")); wr.appendChild(wt); wr.appendChild(el("span", "btn", "Write"));
    wr.addEventListener("click", function () { openJournal(); }); w.appendChild(wr);
    if (state.me && isWeighDay(todayKey())) {
      var wd = watchDoneToday(), wa = el("button", "walk-card watch"); wa.type = "button"; wa.id = "walk-watch";
      var at = el("span"); at.appendChild(el("b", null, "Be watchful · Sabbath")); at.appendChild(el("small", null, wd ? "Done today. Saved to your journal." : "Three honest questions about your week.")); wa.appendChild(at); wa.appendChild(el("span", "btn ghost", wd ? "Open" : "Start"));
      wa.addEventListener("click", function () { openWatch(); }); w.appendChild(wa);
    }
    body.appendChild(w);
  }

'''
rep('''  var PEN_SVG = ''', NEW+'''  var PEN_SVG = ''')
rep('''    body.textContent = "";
    var all = journalSorted(), prayers''','''    body.textContent = ""; paintWalkSeg();
    if (jrUI.tab === "all" && !jrUI.q) drawJournalTop(body);
    var all = journalSorted(), prayers''')
# CSS
CSS='''
/* Walk tab */
.walk-seg { display: grid; grid-template-columns: repeat(3, 1fr); border: 1px solid var(--line); border-radius: var(--radius, 4px); overflow: hidden; margin: -16px 0 0; }
.walk-seg button { min-height: 44px; border: 0; border-left: 1px solid var(--line); background: transparent; color: var(--muted); font-family: var(--f-label); font-weight: 700; font-size: 13.5px; letter-spacing: .1em; text-transform: uppercase; }
.walk-seg button:first-child { border-left: 0; }
.walk-seg button[aria-pressed="true"] { background: var(--accent); color: var(--accent-ink); }
.walk-v { margin: -18px 0 0; padding: 2px 0 2px 12px; border-left: 3px solid var(--accent); }
.walk-v q { display: block; font-family: var(--f-scripture); font-style: italic; font-size: 14.5px; line-height: 1.45; quotes: none; }
.walk-v small { display: block; margin-top: 2px; font-family: var(--f-label); font-weight: 700; font-size: 11px; letter-spacing: .12em; text-transform: uppercase; color: var(--accent); }
#page-mentor .walk-v + .walk-seg { margin-top: -20px; }
#walk-bold:empty { display: none; }
#walk-bold .walk-h { margin: 0 0 4px; font-size: 13px; color: var(--brass); }
#walk-bold .bold-card { margin: 0; }
.walk-cards { display: flex; flex-direction: column; gap: 10px; margin-bottom: 14px; }
.walk-card { display: flex; align-items: center; gap: 12px; width: 100%; padding: 12px; text-align: left; color: inherit; font: inherit; background: var(--surface); border: 1px solid var(--line); border-radius: 8px; cursor: pointer; }
.walk-card.on { border-color: var(--accent); }
.walk-card.watch { border-color: var(--brass); }
.walk-card > span:first-child { flex: 1; min-width: 0; }
.walk-card b { display: block; font-family: var(--f-label); font-weight: 700; font-size: 16px; text-transform: uppercase; letter-spacing: .03em; }
.walk-card.watch b { color: var(--brass); }
.walk-card small { display: block; font-size: 12.5px; color: var(--muted); line-height: 1.4; }
.walk-card .btn { flex: none; min-height: 40px; padding: 0 14px; font-size: 13px; pointer-events: none; }
#page-journal .topline .right { display: inline-flex; align-items: center; gap: 10px; }
.tabbar button.has-dot { position: relative; }
.tabbar button.has-dot::after { content: ""; position: absolute; top: 8px; left: calc(50% + 9px); width: 9px; height: 9px; border-radius: 50%; background: var(--hot, #d0642f); box-shadow: 0 0 0 2px var(--bg); }
#camp-seg { margin: -16px 0 0; }
.jr-tabs:empty { display: none; }
#mentor-today:empty { display: none; }
#page-journal .jr-tabs { grid-template-columns: 1fr 1fr; }
'''
rep('/* Footer verse on Today */', CSS+'/* Footer verse on Today */')
# Tour, help, Ask
rep('''    ["journal", "Journal", ["Tap the pen at the top of any page to write about anything: a lift, your work, your family, your faith. Only you can read it.", "After a workout, Write about this workout keeps what you noticed. Tag prayers and mark them answered.", "Look back with search and On this day. No points, just write."]],''','')
rep('''    ["board", "Board", [''','''    ["mentor", "Walk", ["Brothers: your Paul, your Timothys and your weekly check-in. A dot on Walk means a brother asked to pair or your check-in is due.", "Journal: write about anything, a lift, your work, your family, your faith. Only you can read it. The pen at the top of any page works too.", "Prayers: what you\\u2019re praying for, and what God has answered."]],
    ["board", "Board", [''')
rep('''"Individual and Campaign buttons switch boards.''','''"Individual and Campaign switch between the Kingdom Warrior board and the Campaign.''')
rep('''    ["camp", "Campaign", ["Team battles of 6 to 8 men for 6 weeks.''','''    ["camp", "Campaign", ["Campaign lives under Board. Team battles of 6 to 8 men for 6 weeks.''')
rep('''"w": "Campaign tab \\u00B7 Board \\u203A Campaign"''','''"w": "Board \\u203A Campaign"''')
rep('''"w": "The pen at the top of any page \\u00B7 Today \\u203A Journal \\u00B7 a finished workout"''','''"w": "Walk \\u203A Journal \\u00B7 the pen at the top of any page \\u00B7 a finished workout"''')
rep('''{ t: "My mission''','''{ t: "My mission''',0) if False else None
rep('"The Stand Firm creed under Walk with your brothers is','"The Stand Firm creed above your boxes is')
rep('w: "Today, under Walk with your brothers"','w: "Today, above your boxes"')
rep('"The Stand Firm creed sits under Walk with your brothers.','"The Stand Firm creed sits above your boxes.')
rep('[["all", "Entries"], ["pray", "Praying for · " + open.length], ["ans", "Answered · " + prayers.length]].forEach','(jrUI.tab === "all" ? [] : [["pray", "Praying for · " + open.length], ["ans", "Answered · " + prayers.length]]).forEach')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
