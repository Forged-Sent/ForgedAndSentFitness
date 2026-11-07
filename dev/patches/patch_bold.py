import sys, re
src, dst, ver = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(src, encoding="utf-8").read()

def rep(old, new, count=1):
    global s
    n = s.count(old)
    assert n == count, (n, old[:90])
    s = s.replace(old, new)

s = re.sub(r'var APP_VERSION = "v\d+";', 'var APP_VERSION = "%s";' % ver, s, count=1)

# ---------------- CSS ----------------
CSS = r'''
.creed { margin: 12px 0 14px; padding: 10px 12px 10px 14px; border-left: 3px solid var(--accent); background: var(--surface); border-radius: 6px; }
.creed-k { font-family: var(--f-label); font-weight: 700; font-size: 11px; letter-spacing: .16em; text-transform: uppercase; color: var(--brass, #b08d57); }
.creed-q { margin: 4px 0 2px; font-family: Georgia, "Times New Roman", serif; font-style: italic; font-size: 15px; line-height: 1.45; color: var(--ink); }
.creed-r { font-family: var(--f-label); font-weight: 700; font-size: 11px; letter-spacing: .12em; color: var(--accent); }
.txt .cmd { font-family: var(--f-label); font-weight: 700; font-size: 10.5px; letter-spacing: .14em; text-transform: uppercase; color: var(--brass, #b08d57); line-height: 1.2; }
.bold-card { display: grid; grid-template-columns: 40px minmax(0, 1fr) auto; gap: 10px; align-items: center; width: 100%; margin: 10px 0 4px; padding: 10px 12px; text-align: left; color: inherit; font: inherit; background: var(--surface); border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 8px; cursor: pointer; }
.bold-card.done { border-left-color: #8f9f50; }
.bold-card .bc-ic { width: 40px; height: 40px; display: grid; place-items: center; }
.bold-card .bc-ic svg { width: 34px; height: 34px; }
.bold-card .bc-t { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
.bold-card .bc-k { font-family: var(--f-label); font-weight: 700; font-size: 11px; letter-spacing: .14em; text-transform: uppercase; color: var(--brass, #b08d57); }
.bold-card .bc-n { font-weight: 600; font-size: 15px; line-height: 1.3; overflow-wrap: anywhere; }
.bold-card .bc-tag { font-family: var(--f-label); font-weight: 700; font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: var(--accent); white-space: nowrap; }
.bold-card.done .bc-tag { color: #b9c97d; }
.cdlg[data-k="bold"] .cdlg-btns .btn, .cdlg[data-k="watch"] .cdlg-btns .btn, .cdlg[data-k="sent"] .cdlg-btns .btn { font-size: 13.5px; letter-spacing: .05em; padding-left: 8px; padding-right: 8px; white-space: nowrap; }
.fs-v { margin: 8px 0; padding: 2px 0 2px 12px; border-left: 3px solid var(--accent); }
.fs-v q { display: block; font-family: Georgia, "Times New Roman", serif; font-style: italic; font-size: 14.5px; line-height: 1.5; quotes: none; }
.fs-v small { display: block; margin-top: 2px; font-family: var(--f-label); font-weight: 700; font-size: 11px; letter-spacing: .12em; color: var(--accent); }
.fs-kinds { display: flex; flex-direction: column; gap: 6px; margin: 8px 0; }
.fs-kinds .mini { justify-content: flex-start; text-align: left; min-height: 40px; padding: 6px 12px; font-size: 12.5px; letter-spacing: .04em; white-space: normal; }
.fs-lab { display: block; margin: 10px 0 4px; font-family: var(--f-label); font-weight: 700; font-size: 12.5px; letter-spacing: .1em; text-transform: uppercase; color: var(--brass, #b08d57); }
.fs-priv { margin: 8px 0; padding: 8px 10px; border: 1px dashed var(--accent); border-radius: 8px; font-size: 13px; line-height: 1.4; }
.fs-guard { margin: 10px 0; padding: 10px 12px; border-radius: 8px; background: var(--surface); border: 1px solid var(--line); font-size: 13.5px; line-height: 1.45; }
.fs-guard b { display: block; font-family: var(--f-label); font-size: 11px; letter-spacing: .14em; text-transform: uppercase; color: var(--muted); margin-bottom: 2px; }
.fs-done { margin: 8px 0; font-weight: 600; color: #b9c97d; }
.rtp-card { display: grid; grid-template-columns: 58px minmax(0, 1fr) auto; gap: 12px; align-items: center; width: 100%; padding: 12px; text-align: left; color: inherit; font: inherit; background: var(--surface); border: 1px solid var(--line); border-radius: 8px; cursor: pointer; }
.rtp-ring { width: 58px; height: 58px; border-radius: 50%; border: 5px solid var(--line); box-sizing: border-box; display: grid; place-items: center; font-family: var(--f-label); font-weight: 800; font-size: 18px; }
.rtp-ring.on { border-color: var(--accent); }
.rtp-card .rk { font-family: var(--f-label); font-weight: 700; font-size: 11.5px; letter-spacing: .14em; text-transform: uppercase; color: var(--brass, #b08d57); }
.rtp-card .rs { display: block; font-size: 13.5px; line-height: 1.4; }
.rtp-row { padding: 10px 0; border-bottom: 1px solid var(--line); }
.rtp-row:first-of-type { border-top: 1px solid var(--line); }
.rtp-top { display: flex; align-items: baseline; justify-content: space-between; gap: 8px; }
.rtp-top b { font-family: var(--f-label); font-weight: 700; font-size: 16px; text-transform: uppercase; }
.rtp-top em { font-style: normal; font-family: var(--f-label); font-weight: 700; font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: var(--muted); }
.rtp-top em.met { color: var(--accent); }
.rtp-row p { margin: 2px 0; font-size: 13px; line-height: 1.4; color: var(--muted); }
.rtp-row p.std { color: var(--ink); }
.rtp-btns { display: flex; gap: 6px; margin-top: 6px; flex-wrap: wrap; }
.rtp-btns .mini { min-height: 32px; padding: 0 10px; font-size: 11.5px; }
.sent-card { display: grid; grid-template-columns: 40px minmax(0, 1fr); gap: 12px; align-items: center; width: 100%; margin-top: 12px; padding: 12px; text-align: left; color: inherit; font: inherit; background: var(--surface); border: 1px solid var(--accent); border-radius: 10px; cursor: pointer; }
.sent-card svg { width: 34px; height: 38px; fill: none; stroke: var(--accent); stroke-width: 2.4; stroke-linejoin: round; stroke-linecap: round; }
.sent-card b { display: block; font-family: var(--f-label); font-weight: 800; font-size: 18px; text-transform: uppercase; }
.sent-card small { display: block; font-size: 13px; color: var(--muted); line-height: 1.4; }
.chal-btn.chal-protector { border-top-color: #5b86b8; }
.chal-btn.chal-protector { border-left-color: #5b86b8 !important; }
.chb-protector { --slotc: #6f98c8; }
'''
A = '.chb-family { --slotc: var(--gold-2, #e0c46c); } .chb-endure { --slotc: #d0642f; } .chb-iron { --slotc: #8f9f50; }'
rep(A, A + CSS)

# ---------------- Markup ----------------
rep('''    </header>
    <div class="ready" id="ready" hidden></div>''', '''    </header>
    <div class="creed" id="creed-today" role="note" aria-label="The Stand Firm creed"><div class="creed-k">The Stand Firm creed</div><p class="creed-q">“Be watchful, stand firm in the faith, act like men, be strong. Let all that you do be done in love.”</p><div class="creed-r">1 Corinthians 16:13–14 (ESV)</div></div>
    <div class="ready" id="ready" hidden></div>''')
rep('''      <ul class="rows" id="tasks"></ul>''', '''      <div id="bold-today" hidden></div>
      <ul class="rows" id="tasks"></ul>''')
rep('''<h2 class="label-caps" id="h-chal">This week's challenges</h2>''', '''<h2 class="label-caps" id="h-chal">Orders for the week</h2>''')
rep('''    <button class="btn ghost gb-open" type="button" id="gym-basics">New to the gym? Start here</button>
''', '''    <button class="btn ghost gb-open" type="button" id="gym-basics">New to the gym? Start here</button>

    <section aria-labelledby="h-rtp">
      <div class="section-head"><h2 class="label-caps" id="h-rtp" data-sub="Five real-world standards: could you carry, ruck, get up, run and help when it counts? On your honor. No points.">Ready to protect</h2></div>
      <button class="rtp-card" type="button" id="rtp-open"></button>
    </section>
''')
rep('''    <button class="btn ghost" type="button" id="p-invite" style="width:100%" hidden>Invite a brother</button>''',
    '''    <button class="btn ghost" type="button" id="p-invite" style="width:100%" hidden>Invite a brother</button>
    <button class="btn ghost" type="button" id="p-mission" style="width:100%;margin-top:8px" hidden>My mission</button>''')
rep('''<div class="banner" id="banner" hidden>Every box checked. Mission complete.</div>''', '''<div class="banner" id="banner" hidden>Every box checked. Mission accomplished.</div>''')

# ---------------- Challenge data: Protector and Bold Step ----------------
i = s.index('  var CHAL = '); j = s.index('\n', i) + 1
s = s[:j] + r'''  /* Called to Be Bold: two completion lanes added to every week. Protector shows with the weekly orders on Train (30 pts).
     Bold Step lives on Today (25 pts). Only "done" goes to the shared challenge record; what a man writes stays private. */
  (function () {
    CHAL.slots.push({ id: "protector", label: "Protector", description: "Stand in the gap for someone God has put in your care. Completion only; not ranked. Nehemiah 4:14." },
      { id: "bold", label: "Bold Step", description: "One hard thing you have been avoiding, done before Sunday. Completion only; not ranked. Judges 6:12." });
    CHAL.weeks.forEach(function (w) {
      var nn = (w.week < 10 ? "0" : "") + w.week;
      w.challenges.push({ slot: "protector", id: "w" + nn + "-protector", name: "Stand in the Gap", description: "Pick one this week. Protect your family: one-on-one time with each child, or a date with your wife with your phone away. Protect the vulnerable: visit a widow or an elderly neighbor, mentor a fatherless boy, or serve a veteran or first responder. Protect your brothers: call the brother who has gone quiet in Rally. Don’t text. Call.", target: 1, unit: "act", points: 30, scoredBy: "completion", equipment: "None", scripture: "Nehemiah 4:14", record: "Mark it complete once you’ve done it. On your honor.", alternate: null });
      w.challenges.push({ slot: "bold", id: "w" + nn + "-bold", name: "Bold Step", description: "Pick one hard thing you have been avoiding and do it before Sunday. Share your faith, have the conversation, apologize first, lead your family in prayer, or say no to what pulls you from God.", target: 1, unit: "act", points: 25, scoredBy: "completion", equipment: "None", scripture: "Judges 6:12", record: "Set it on Today. Mark it done once you’ve done it. On your honor.", alternate: null });
    });
  })();
''' + s[j:]

# ---------------- Scoring code ----------------
rep('''if (!/^w\\d{2}-(family|iron|endure)$/.test(k)) return;''', '''if (!/^w\\d{2}-(family|iron|endure|protector|bold)$/.test(k)) return;''')
rep('''      var flatPts = r.flat ? (c.scoredBy === "completion" ? CHAL.scoring.family.completionPoints : CHAL.scoring.scaled.completionPoints) : 0;''',
    '''      var flatPts = r.flat ? (c.scoredBy === "completion" ? chalCompPts(c) : CHAL.scoring.scaled.completionPoints) : 0;''')
rep('''  function chalMaxPts(c) { return c.scoredBy === "completion" ? CHAL.scoring.family.completionPoints : CHAL.scoring.standard.maxPoints; }''',
    '''  function chalMaxPts(c) { return c.scoredBy === "completion" ? chalCompPts(c) : CHAL.scoring.standard.maxPoints; }
  // Family keeps the published 50. Protector (30) and Bold Step (25) carry their own points.
  function chalCompPts(c) { return c && c.slot !== "family" && c.points ? c.points : CHAL.scoring.family.completionPoints; }
  function chalWeekMax(w) { return (w.challenges || []).reduce(function (t, c) { return t + chalMaxPts(c); }, 0); }''')
# Challenge page text for completion challenges
rep('''CHAL.scoring.family.completionPoints + " for completing");''', '''chalCompPts(c) + " for completing");''')
rep('''    } else how.appendChild(el("li", null, "Complete it for " + CHAL.scoring.family.completionPoints + " points. Not''', '''    } else how.appendChild(el("li", null, "Complete it for " + chalCompPts(c) + " points. Not''')
rep('''isFam ? "On your honor. " + CHAL.scoring.family.completionPoints + " points''', '''isFam ? "On your honor. " + chalCompPts(c) + " points''')
rep('''    if (c.scoredBy === "completion" && juniorFor(w.week)) {''', '''    if (c.slot === "family" && juniorFor(w.week)) {''')
# Points breakdown
rep('''    var ch = { family: 0, iron: 0, endure: 0 }, cw = chalWeekFor(today)''', '''    var ch = { family: 0, iron: 0, endure: 0, protector: 0, bold: 0 }, cw = chalWeekFor(today)''')
rep('''[["Family", ch.family], ["Iron", ch.iron], ["Endure", ch.endure]], ch.family + ch.iron + ch.endure);''',
    '''[["Family", ch.family], ["Iron", ch.iron], ["Endure", ch.endure], ["Protector", ch.protector], ["Bold Step", ch.bold]], ch.family + ch.iron + ch.endure + ch.protector + ch.bold);''')
# Badges
rep('''    if (c.slot === "family") return CHB_FAMILY[nm] || "heart";''', '''    if (c.slot === "family") return CHB_FAMILY[nm] || "heart";
    if (c.slot === "protector") return "gap";
    if (c.slot === "bold") return "torch";''')
rep('''    var slot = c.slot === "family" || c.slot === "endure" ? c.slot : "iron", tag = chbTag(c), gy = tag ? 8.6 : 15.4;
    var s = '<svg class="chb chb-' + slot + (gaunt ? " chb-gaunt" : "") + '" viewBox="0 0 64 64" aria-hidden="true">';''',
    '''    var slot = c.slot === "family" || c.slot === "endure" ? c.slot : c.slot === "protector" || c.slot === "bold" ? "family" : "iron", tag = c.slot === "protector" || c.slot === "bold" ? "" : chbTag(c), gy = tag ? 8.6 : 15.4;
    var s = '<svg class="chb chb-' + (c.slot === "protector" ? "protector" : slot) + (gaunt ? " chb-gaunt" : "") + '" viewBox="0 0 64 64" aria-hidden="true">';''')
# Grid: Bold Step is on Today, not in the grid
rep('''    w.challenges.forEach(function (c) {
      var b = el("button", "chal-btn chal-" + c.slot''', '''    w.challenges.forEach(function (c) {
      if (c.slot === "bold") { var bmr = chalAttempts(c.id).length ? chalMyRow(c) : null; weekPts += bmr ? bmr.pts : 0; return; }
      var b = el("button", "chal-btn chal-" + c.slot''')
rep('''" Your points this week: " + weekPts + " of " + CHAL.scoring.maxWeek.allStandard + ".";''', '''" Your points this week: " + weekPts + " of " + chalWeekMax(w) + ", Bold Step included.";''')

# ---------------- Today rows: command labels, Be watchful ----------------
rep('''      var txt = el("span", "txt"), nm = el("span", "name", tk.kind === "calories" && foodMode() !== "app" ? FOOD_MODES[foodMode()].box : tk.title);
      txt.appendChild(nm);''', '''      var txt = el("span", "txt"), nm = el("span", "name", tk.kind === "calories" && foodMode() !== "app" ? FOOD_MODES[foodMode()].box : tk.title);
      txt.appendChild(el("span", "cmd", cmdOf(tk))); txt.appendChild(nm);''')
rep('''      var ftx = el("span", "txt"); ftx.appendChild(el("span", "name", "Family report"));''', '''      var ftx = el("span", "txt"); ftx.appendChild(el("span", "cmd", "Act like men")); ftx.appendChild(el("span", "name", "Family report"));''')
rep('''      var ltx = el("span", "txt"); ltx.appendChild(el("span", "name", "Legacy log"));''', '''      var ltx = el("span", "txt"); ltx.appendChild(el("span", "cmd", "Act like men")); ltx.appendChild(el("span", "name", "Legacy log"));''')
rep('''      lb0.addEventListener("click", function () { openLegacy(); }); lli.appendChild(lb0); list.appendChild(lli);
    }''', '''      lb0.addEventListener("click", function () { openLegacy(); }); lli.appendChild(lb0); list.appendChild(lli);
      var wd = watchDoneToday(), wli = el("li", "item fr-li"), wb = el("button", "hit fr-open"); wb.type = "button"; wb.id = "watch-today";
      if (wd) { wb.classList.add("fr-done"); var wbx = el("span", "box"); wbx.innerHTML = CHECK_SVG; wb.appendChild(wbx); } else { var wic = el("span", "fr-ic"); wic.innerHTML = EYE_SVG; wb.appendChild(wic); }
      var wtx = el("span", "txt"); wtx.appendChild(el("span", "cmd", "Be watchful")); wtx.appendChild(el("span", "name", "Sabbath self-check"));
      wtx.appendChild(el("span", "sub", wd ? "Saved to your journal · Only you can read it" : "Three honest questions. Private. No points.")); wb.appendChild(wtx);
      if (wd) wb.appendChild(el("span", "pts fr-tag", "Done")); wb.appendChild(el("span", "chev", "›"));
      wb.addEventListener("click", function () { openWatch(); }); wli.appendChild(wb); list.appendChild(wli);
      setTimeout(function () { try { loadWkHist(); } catch (e) {} }, 0);
    }''')
rep('''      var jtx = el("span", "txt"); jtx.appendChild(el("span", "name", "Journal"));''', '''      var jtx = el("span", "txt"); jtx.appendChild(el("span", "cmd", "Be watchful")); jtx.appendChild(el("span", "name", "Journal"));''')
rep('''  function drawToday() {
    drawFirstOrders(); drawReady();''', '''  function drawToday() {
    drawFirstOrders(); drawReady(); try { drawBoldToday(); } catch (e) {}''')
rep('''"Yesterday\\u2019s gone. Own it and get back on the line."''', '''"Grace for yesterday. Own it and get back in the line."''')

# ---------------- Train / workout wording ----------------
rep('''var sb = el("button", "btn wk-start", "Start workout");''', '''var sb = el("button", "btn wk-start", "Pray, then train");''')
rep('''    var t = el("h2", null, "Workout complete"); t.id = "aw-t"; box.appendChild(t);''', '''    var t = el("h2", null, list.length ? "Stronger to serve" : "Workout complete"); t.id = "aw-t"; box.appendChild(t);''')
rep('''  function drawTrain() {
    drawChallengeButtons(); rtDrawPlan();''', '''  function drawTrain() {
    drawChallengeButtons(); rtDrawPlan(); try { drawRtp(); } catch (e) {}''')

# ---------------- Campaign wording and Sent ----------------
rep('''j = el("button", "mini on", "Join"), d = el("button", "mini", "Decline");''', '''j = el("button", "mini on", "Answer the call"), d = el("button", "mini", "Decline");''')
rep('''"He’ll see your invite on Today and tap Join."''', '''"He’ll see your invite on Today and tap Answer the call."''')
rep('''ct.appendChild(el("small", null, "Final standings are on the Board.")); ch.appendChild(ct); ch.addEventListener("click", openCampBoard); box.appendChild(ch); }''',
    '''ct.appendChild(el("small", null, "Final standings are on the Board.")); ch.appendChild(ct); ch.addEventListener("click", openCampBoard); box.appendChild(ch); }
        if (state.me) box.appendChild(sentCard("Campaign " + n + " is complete. Write the mission God is sending you on."));''')

# ---------------- Points dialog ----------------
rep('''    group("Sent", [["A brother you invited joins"''', '''    group("Weekly challenges", [["Family", chalCompPts({ slot: "family" }) + " pts"], ["Iron and Endure", CHAL.scoring.standard.minPoints + " to " + CHAL.scoring.standard.maxPoints + " pts"], ["Protector: stand in the gap", "30 pts"], ["Bold Step on Today", "25 pts"]], "Family, Protector and Bold Step are on your honor and not ranked. Iron and Endure are ranked in your age bracket. Due Sunday 8 AM Arizona time.");
    group("Sent", [["A brother you invited joins"''')

# ---------------- Backend: private forge doc ----------------
rep('''    saveLegacy: function (uid, o) { return this.db.doc("data/users/" + uid + "/legacy").set(o); },''', '''    saveLegacy: function (uid, o) { return this.db.doc("data/users/" + uid + "/legacy").set(o); },
    watchForge: function (uid, cb) { return this.db.doc("data/users/" + uid + "/forge").onSnapshot(function (s) { cb(s.exists ? (s.data() || {}) : {}); }, noop); },
    saveForge: function (uid, o) { return this.db.doc("data/users/" + uid + "/forge").set(o); },''')
rep('''      if (B.watchLegacy) B.watchLegacy(state.me,''', '''      if (B.watchForge) B.watchForge(state.me, function (m) { state.forge = normForge(m); drawToday(); if (state.page === "train") drawRtp(); });
      if (B.watchLegacy) B.watchLegacy(state.me,''')
rep('''    $("prof-gear").hidden = !own; $("prof-jr").hidden = !own;''', '''    $("prof-gear").hidden = !own; $("prof-jr").hidden = !own; $("p-mission").hidden = !own;''')
rep('''    $("prof-jr").addEventListener("click", function () { jrUI.tab = "all"; go("journal"); });''', '''    $("prof-jr").addEventListener("click", function () { jrUI.tab = "all"; go("journal"); });
    $("p-mission").addEventListener("click", function () { openSent(); });
    $("rtp-open").addEventListener("click", function () { openRtp(); });''')
rep('''x.src === "devo" ? " · Devotional" :''', '''x.src === "devo" ? " · Devotional" : x.src === "watch" ? " · Sabbath self-check" :''')

# ---------------- Help, tour, onboarding text ----------------
rep('''      "This week's challenges: three buttons at the top for the Family, Iron and Endure challenges. Tap one to see what it is, then submit your result there.",''',
    '''      "Orders for the week: the Family, Iron, Endure and Protector challenges at the top. Tap one to see what it is, then submit your result there. Protector is 30 points for standing in the gap for someone in your care.",
      "Ready to protect: five real-world standards (carry, ruck, floor to feet, sprint, first aid and CPR). Mark each one on your honor. No points. Ranks come from David\\u2019s mighty men in 2 Samuel 23.",''')
rep('''      "Tap a box when you've done it. Boxes with an arrow open something first, like the devotional, your creed or your steps.",''',
    '''      "Report in: tap a box when you've done it. Boxes with an arrow open something first, like the devotional, your creed or your steps.",
      "The Stand Firm creed at the top is 1 Corinthians 16:13\\u201314. Each box carries one of its commands: Stand firm, Be strong, Be watchful, Act like men, In love.",
      "Lead at Home: pray with your family or lead at home today. 1 point.",
      "This week\\u2019s Bold Step sits under your boxes. Pick one hard thing you\\u2019ve been avoiding and do it before Sunday for 25 points. What you write stays private.",
      "On your Sabbath, Be watchful is a short private self-check. It saves to your journal.",''')
rep('''    ["today", "Today", ["Tap a box when it's done. Boxes with an arrow open first, like the devotional, your creed and your steps.",''',
    '''    ["today", "Today", ["The Stand Firm creed sits at the top. Each box carries one of its commands.", "Tap a box when it's done. Boxes with an arrow open first, like the devotional, your creed and your steps.", "Your Bold Step for the week is under your boxes.",''')
rep('''"Weekly challenges are at the top. Due Sunday 8 AM Arizona time, with photo or video proof."]],''', '''"Orders for the week are at the top, including Protector. Due Sunday 8 AM Arizona time.", "Ready to protect: five real-world standards, on your honor."]],''')
rep('''      [["Today", "Your daily boxes: devotional, creed, workout, steps, water and calories.",''', '''      [["Today", "The Stand Firm creed and your daily boxes: devotional, workout, steps, water, calories and leading at home. Plus one Bold Step each week.",''')

# ---------------- New feature code ----------------
NEW = r'''  /* ---------- Called to Be Bold: creed commands, Bold Step, Ready to protect, Be watchful, Sent ----------
     Private parts live in data/users/<me>/forge: { bold: { "w<N>": { k, t, at } }, ready: { key: { s, at } }, mission, missionAt }.
     Only completion of the Bold Step goes to the shared challenge record, with no text. */
  var EYE_SVG = '<svg viewBox="0 0 24 24" aria-hidden="true" style="width:20px;height:20px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"><path d="M2.6 12Q12 3.6 21.4 12 12 20.4 2.6 12Z"/><circle cx="12" cy="12" r="2.6"/></svg>';
  var SHIELD_SVG = '<svg viewBox="0 0 30 34" aria-hidden="true"><path d="M15 2 L27 6 V16 C27 24 21 29.5 15 32 C9 29.5 3 24 3 16 V6 Z"/><path d="M15 9 V24 M10 14 H20"/></svg>';
  function cmdOf(tk) {
    if (tk.kind === "devo" || tk.id === "t_motto") return "Stand firm";
    if (tk.kind === "checkin") return "In love";
    if (tk.id === "t_home") return "Act like men";
    return "Be strong";
  }
  function normForge(m) {
    m = m && typeof m === "object" ? m : {}; var o = { bold: {}, ready: {}, mission: "", missionAt: 0 };
    var b = m.bold && typeof m.bold === "object" ? m.bold : {};
    Object.keys(b).forEach(function (k) { if (/^w\d{1,2}$/.test(k) && b[k] && typeof b[k].t === "string") o.bold[k] = { k: String(b[k].k || "").slice(0, 12), t: b[k].t.slice(0, 240), at: Number(b[k].at) || 0 }; });
    var r = m.ready && typeof m.ready === "object" ? m.ready : {};
    RTP.forEach(function (x) { var v = r[x.k]; if (v && (v.s === "met" || v.s === "scaled")) o.ready[x.k] = { s: v.s, at: Number(v.at) || 0 }; });
    if (typeof m.mission === "string") { o.mission = m.mission.slice(0, 1200); o.missionAt = Number(m.missionAt) || 0; }
    return o;
  }
  function forgeOf() { return state.forge || (state.forge = normForge({})); }
  function saveForgeNow(f) { state.forge = f; try { if (B.saveForge && state.me) B.saveForge(state.me, f).catch(noop); } catch (e) {} }
  function fsVerse(host, q, ref) { var v = el("div", "fs-v"); v.appendChild(el("q", null, "“" + q + "”")); v.appendChild(el("small", null, ref + " (ESV)")); host.appendChild(v); }
  function fsSheet(k, title, kicker) {
    var old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg"; back.dataset.k = k;
    var box = el("div", "cdlg-box nw-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "fs-t");
    var x = el("button", "dlg-x"); x.type = "button"; x.setAttribute("aria-label", "Close"); x.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>'; box.appendChild(x);
    if (kicker) box.appendChild(el("p", "fr-k", kicker));
    var h = el("h2", null, title); h.id = "fs-t"; box.appendChild(h);
    function close() { back.remove(); }
    x.addEventListener("click", close);
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back);
    return { back: back, box: box, close: close, focus: function () { try { x.focus({ preventScroll: true }); } catch (e) {} } };
  }
  async function fsShare(title, txt, msg) {
    if (navigator.share) { try { await navigator.share({ title: title, text: txt }); msg.textContent = "✓ Shared."; return; } catch (e) { if (e && e.name === "AbortError") return; } }
    try { await navigator.clipboard.writeText(txt); msg.textContent = "✓ Copied. Paste it in a text to your " + (myPaul() ? "Paul" : "brother") + "."; return; } catch (e) {}
    var ta = el("textarea", "field"); ta.value = txt; ta.rows = 5; ta.readOnly = true; ta.setAttribute("aria-label", "Text to copy"); msg.textContent = "Copy this and send it:"; msg.after(ta); ta.select();
  }
  function paulWord() { var p = myPaul(); return p ? "my Paul" : "a brother"; }
  function shareLbl() { return myPaul() ? "Send to my Paul" : "Share it"; }

  /* Bold Step (Today) */
  var BOLD_KINDS = [["faith", "Share my faith with someone"], ["talk", "Have the conversation I’ve been avoiding"], ["sorry", "Apologize first"], ["pray", "Lead my family in prayer"], ["no", "Say no to what pulls me from God"]];
  function boldNow() {
    var cw = chalWeekFor(todayKey()); if (cw.pre || cw.over) return null;
    var f = chalFind("w" + pad(cw.n) + "-bold"); if (!f) return null;
    return { n: cw.n, c: f.c, w: f.w, step: forgeOf().bold["w" + cw.n] || null, done: chalAttempts(f.c.id).length > 0, open: chalIsOpen(cw.n) };
  }
  function drawBoldToday() {
    var box = $("bold-today"); if (!box) return; box.textContent = "";
    var b = state.me ? boldNow() : null; if (!b) { box.hidden = true; return; }
    box.hidden = false;
    var card = el("button", "bold-card" + (b.done ? " done" : "")); card.type = "button"; card.id = "bold-open";
    var ic = el("span", "bc-ic"); ic.innerHTML = chalBadgeSvg(b.c, false); card.appendChild(ic);
    var t = el("span", "bc-t"); t.appendChild(el("span", "bc-k", "This week’s Bold Step"));
    t.appendChild(el("span", "bc-n", b.step ? b.step.t : "Pick one hard thing you’ve been avoiding. Do it before Sunday."));
    card.appendChild(t);
    card.appendChild(el("span", "bc-tag", b.done ? "✓ Done" : b.step ? (b.open ? "Due Sun" : "Closed") : "+" + chalCompPts(b.c)));
    card.setAttribute("aria-label", "This week’s Bold Step" + (b.step ? ": " + b.step.t : "") + (b.done ? ". Done" : ""));
    card.addEventListener("click", function () { openBold(); });
    box.appendChild(card);
  }
  function openBold(editing) {
    var b = boldNow(); if (!b) return;
    var F = openBold.F || (openBold.F = {}), key = "w" + b.n, step = b.step;
    if (F.wk !== key) { F.wk = key; F.k = step ? step.k : ""; F.t = step ? step.t : ""; }
    var S = fsSheet("bold", "Your Bold Step", "Week " + b.n + " · Due Sunday 8 AM Arizona time"), box = S.box;
    fsVerse(box, "The LORD is with you, O mighty man of valor.", "Judges 6:12");
    var off = !state.me || !state.canWrite, msg = el("p", "note", "");
    if (step && !editing) {
      box.appendChild(el("span", "fs-lab", "You committed to"));
      box.appendChild(el("p", "lg-p", step.t));
      if (b.done) box.appendChild(el("p", "fs-done", "✓ Done. +" + chalCompPts(b.c) + " points. Well done, brother."));
      box.appendChild(el("p", "fs-priv", "Private. Only you can see what you wrote. The challenge record only shows that you did a Bold Step."));
      var row = el("div", "cdlg-btns");
      if (!b.done) {
        var did = el("button", "btn", "I did it · +" + chalCompPts(b.c)); did.type = "button"; did.disabled = off || !b.open;
        did.addEventListener("click", function () { chalSave(b.c.id, [{ mode: "standard", v: 0, x: 0, m: "", note: "", at: Date.now(), media: [] }], "Bold Step done."); drawToday(); openBold(); });
        row.appendChild(did);
      }
      var sh = el("button", "btn ghost", shareLbl()); sh.type = "button";
      sh.addEventListener("click", function () { fsShare("My Bold Step", "My Bold Step this week: " + step.t + (b.done ? "\n\nI did it. Thank God." : "\n\nHold me to it. Ask me how it went before Sunday."), msg); });
      row.appendChild(sh); box.appendChild(row);
      if (!b.done) { var ed = el("button", "linkish", "Change my step"); ed.type = "button"; ed.disabled = off; ed.addEventListener("click", function () { openBold(true); }); box.appendChild(ed); }
      if (!b.open && !b.done) box.appendChild(el("p", "note", "This week is closed. A new Bold Step opens Monday."));
      box.appendChild(msg); S.focus(); return;
    }
    box.appendChild(el("p", "note", "God called Gideon a mighty man while he was hiding. Pick one hard thing you have been avoiding and do it before Sunday."));
    var kinds = el("div", "fs-kinds");
    BOLD_KINDS.forEach(function (x) {
      var c = el("button", "mini" + (F.k === x[0] ? " on" : ""), x[1]); c.type = "button"; c.setAttribute("aria-pressed", F.k === x[0] ? "true" : "false");
      c.addEventListener("click", function () { F.k = x[0]; F.t = ta.value; openBold(editing); });
      kinds.appendChild(c);
    });
    box.appendChild(kinds);
    var lab = el("label", "fs-lab", "Make it specific"); lab.setAttribute("for", "bold-ta"); box.appendChild(lab);
    var ta = el("textarea", "field"); ta.id = "bold-ta"; ta.rows = 3; ta.maxLength = 240; ta.placeholder = "Who, what and when. Example: Ask Mark to church before Sunday.";
    ta.value = F.t || ""; ta.addEventListener("input", function () { F.t = ta.value; }); box.appendChild(ta);
    box.appendChild(el("p", "fs-priv", "Private. Only you can see what you write. Share it with " + paulWord() + " if you want someone to hold you to it."));
    var row2 = el("div", "cdlg-btns"), go2 = el("button", "btn", "Commit to it"), cx = el("button", "btn ghost", "Cancel"); go2.type = cx.type = "button"; go2.disabled = off;
    go2.addEventListener("click", function () {
      var v = ta.value.trim(); if (!v && F.k) v = BOLD_KINDS.filter(function (x) { return x[0] === F.k; })[0][1];
      if (!v) { msg.textContent = "Pick one or write your own step first."; return; }
      var f = Object.assign({}, forgeOf()); f.bold = Object.assign({}, f.bold); f.bold[key] = { k: F.k || "own", t: v.slice(0, 240), at: Date.now() };
      saveForgeNow(f); F.t = v; drawToday(); openBold();
    });
    cx.addEventListener("click", function () { if (step) openBold(); else S.close(); });
    row2.appendChild(go2); row2.appendChild(cx); box.appendChild(row2); box.appendChild(msg); S.focus();
  }

  /* Ready to protect (Train). On his honor. No points. */
  var RTP = [
    { k: "carry", n: "Carry", s: "Farmer carry your body weight, split between two hands, for 100 feet.", sc: "Half your body weight for 100 feet." },
    { k: "ruck", n: "Ruck", s: "4 miles with 30 lb in under 60 minutes.", sc: "2 miles with 20 lb, or 4 miles with no weight." },
    { k: "floor", n: "Floor to feet", s: "Sit on the floor and stand up with no hands, 5 times.", sc: "Use one hand for support, 5 times." },
    { k: "sprint", n: "Sprint", s: "100 yards in under 16 seconds.", sc: "100 yards in under 25 seconds, or a brisk 100-yard walk." },
    { k: "cpr", n: "First aid and CPR", s: "Take a certified first aid and CPR class, like the American Red Cross or American Heart Association.", sc: "" }
  ];
  function rtpCount() { var r = forgeOf().ready; return RTP.filter(function (x) { return r[x.k]; }).length; }
  function rtpRank(n) { return n >= 5 ? "Of the Three" : n >= 3 ? "Of the Thirty" : "In training"; }
  function rtpNext(n) { return n >= 5 ? "You stand with the Three. Keep your standards and train a brother up to them." : n >= 3 ? (5 - n) + (5 - n === 1 ? " more standard" : " more standards") + " to stand with the Three." : (3 - n) + (3 - n === 1 ? " more standard" : " more standards") + " to stand with the Thirty."; }
  function drawRtp() {
    var b = $("rtp-open"); if (!b) return; b.textContent = "";
    var n = rtpCount(), ring = el("span", "rtp-ring" + (n ? " on" : ""), n + "/5"); b.appendChild(ring);
    var t = el("span"); t.appendChild(el("span", "rk", "Rank: " + rtpRank(n))); t.appendChild(el("span", "rs", "Could you carry your family out of a fire, run to help, and get back up? " + rtpNext(n))); b.appendChild(t);
    b.appendChild(el("span", "chev", "›"));
    b.setAttribute("aria-label", "Ready to protect: " + n + " of 5 standards met. Rank: " + rtpRank(n));
  }
  function openRtp() {
    var S = fsSheet("rtp", "Ready to protect", "Train · Standards"), box = S.box, n = rtpCount(), r = forgeOf().ready, off = !state.me || !state.canWrite;
    box.appendChild(el("p", "note", "Not how you look. Whether you could carry your family out of a fire, run to help, and get back up."));
    box.appendChild(el("p", "fs-done", "Rank: " + rtpRank(n) + " · " + n + " of 5 met"));
    box.appendChild(el("p", "note", rtpNext(n) + " Ranks come from David’s mighty men, the Three and the Thirty, in 2 Samuel 23."));
    RTP.forEach(function (x) {
      var cur = r[x.k], row = el("div", "rtp-row"), top = el("div", "rtp-top");
      top.appendChild(el("b", null, x.n)); top.appendChild(el("em", cur ? "met" : null, cur ? (cur.s === "scaled" ? "Met (scaled)" : "Met") : "Not yet")); row.appendChild(top);
      row.appendChild(el("p", "std", x.s)); if (x.sc) row.appendChild(el("p", null, "Scaled for age or injury: " + x.sc));
      var bt = el("div", "rtp-btns");
      [["met", "Met"], x.sc ? ["scaled", "Met scaled"] : null, ["", "Not yet"]].forEach(function (o) {
        if (!o) return; var on = o[0] ? cur && cur.s === o[0] : !cur, c = el("button", "mini" + (on ? " on" : ""), o[1]); c.type = "button"; c.disabled = off; c.setAttribute("aria-pressed", on ? "true" : "false");
        c.addEventListener("click", function () { var f = Object.assign({}, forgeOf()); f.ready = Object.assign({}, f.ready); if (o[0]) f.ready[x.k] = { s: o[0], at: Date.now() }; else delete f.ready[x.k]; saveForgeNow(f); drawRtp(); openRtp(); });
        bt.appendChild(c);
      });
      row.appendChild(bt); box.appendChild(row);
    });
    fsVerse(box, "Be strong and courageous… for the LORD your God is with you wherever you go.", "Joshua 1:9");
    box.appendChild(el("p", "note", "On your honor. Private to you. No points. Test safely, warm up first, and check with your doctor if you have a heart, joint or other health concern."));
    S.focus();
  }

  /* Be watchful: Sabbath self-check, saved as a private journal entry */
  var WATCH_Q = ["Where was I weak this week?", "What is pulling at me?", "Where did I see God?"];
  function watchDoneToday() { return journalToday().some(function (x) { return x.src === "watch"; }); }
  function watchGuard() {
    if (!wkHist) return 0; var from = addDays(todayKey(), -7), n = 0;
    wkHist.forEach(function (d) { if (!d || !d.date || d.date < from || d.date > todayKey()) return; var p = (d.rate && d.rate.pre) || {}; if (p.sleep === "rough" || p.stress === "high") n++; });
    return n;
  }
  function openWatch() {
    var F = openWatch.F || (openWatch.F = { a: ["", "", ""], saved: "" });
    if (F.day !== todayKey()) { F.day = todayKey(); F.a = ["", "", ""]; F.saved = ""; }
    var S = fsSheet("watch", F.saved ? "Saved to your journal." : "Be watchful", "Sabbath · " + parseKey(todayKey()).toLocaleDateString(undefined, { weekday: "long", month: "short", day: "numeric" })), box = S.box, msg = el("p", "note", "");
    fsVerse(box, "Let us test and examine our ways, and return to the LORD!", "Lamentations 3:40");
    function text() { return WATCH_Q.map(function (q, i) { return F.a[i].trim() ? q + "\n" + F.a[i].trim() : ""; }).filter(Boolean).join("\n\n"); }
    if (F.saved) {
      box.appendChild(el("p", "fs-priv", "Only you can read this. It’s in My journal with your other entries."));
      var r0 = el("div", "cdlg-btns"), sh0 = el("button", "btn ghost", shareLbl()), dn = el("button", "btn", "Done"); sh0.type = dn.type = "button";
      sh0.addEventListener("click", function () { fsShare("My Sabbath self-check", text() + "\n\n(From my Forged & Sent journal)", msg); });
      dn.addEventListener("click", S.close); r0.appendChild(dn); r0.appendChild(sh0); box.appendChild(r0); box.appendChild(msg); S.focus(); return;
    }
    box.appendChild(el("p", "fs-priv", "Private. Only you can read this. Your " + (myPaul() ? "Paul" : "brothers") + " see nothing unless you choose to share it."));
    var tas = [];
    WATCH_Q.forEach(function (q, i) {
      var lab = el("label", "fs-lab", q); lab.setAttribute("for", "watch-" + i); box.appendChild(lab);
      var ta = el("textarea", "field"); ta.id = "watch-" + i; ta.rows = 2; ta.maxLength = 1200; ta.value = F.a[i]; ta.addEventListener("input", function () { F.a[i] = ta.value; });
      box.appendChild(ta); tas.push(ta);
    });
    var g = watchGuard(), gd = el("div", "fs-guard"); gd.appendChild(el("b", null, "Guard yourself this week"));
    gd.appendChild(document.createTextNode(g >= 2 ? "Your workouts logged rough sleep or high stress " + g + " times this week. A man who is spent can’t protect anyone. What will you guard: sleep, your phone at night, your time with God?" : "Where do you need a hedge this week: sleep, your phone at night, what you watch, your time with God?"));
    box.appendChild(gd);
    var row = el("div", "cdlg-btns"), sv = el("button", "btn", "Save privately"), sh = el("button", "btn ghost", shareLbl()); sv.type = sh.type = "button"; sv.disabled = !state.me || !state.canWrite;
    sv.addEventListener("click", function () {
      var v = text(); if (!v) { msg.textContent = "Answer at least one question first."; tas[0].focus(); return; }
      var x = { id: "j" + Date.now().toString(36), d: todayKey(), at: Date.now(), t: v, tags: ["struggle"], src: "watch", p: "Sabbath self-check" };
      jrSave(x); F.saved = x.id; openWatch();
    });
    sh.addEventListener("click", function () { var v = text(); if (!v) { msg.textContent = "Answer at least one question first."; return; } fsShare("My Sabbath self-check", v, msg); });
    row.appendChild(sv); row.appendChild(sh); box.appendChild(row); box.appendChild(msg); S.focus();
  }

  /* Sent: commissioning after a campaign, and from Profile */
  function sentCard(sub) {
    var b = el("button", "sent-card"); b.type = "button"; b.id = "sent-open";
    var ic = el("span"); ic.innerHTML = SHIELD_SVG; b.appendChild(ic);
    var t = el("span"); t.appendChild(el("b", null, "You are sent")); t.appendChild(el("small", null, forgeOf().mission ? "Your mission: " + forgeOf().mission.slice(0, 90) + (forgeOf().mission.length > 90 ? "…" : "") : sub)); b.appendChild(t);
    b.addEventListener("click", function () { openSent(); });
    return b;
  }
  function openSent() {
    var fg = forgeOf(), S = fsSheet("sent", "You are sent", "Sent"), box = S.box, msg = el("p", "note", ""), off = !state.me || !state.canWrite;
    fsVerse(box, "Here I am! Send me.", "Isaiah 6:8");
    box.appendChild(el("p", "note", "Write who God has called you to protect, lead and reach. Your wife and kids, the men on your street, a Timothy who will train others."));
    var lab = el("label", "fs-lab", "My mission"); lab.setAttribute("for", "sent-ta"); box.appendChild(lab);
    var ta = el("textarea", "field"); ta.id = "sent-ta"; ta.rows = 5; ta.maxLength = 1200; ta.value = fg.mission || ""; ta.placeholder = "God has called me to…"; box.appendChild(ta);
    box.appendChild(el("p", "fs-priv", "Private until you share it in Rally."));
    function save() { var v = ta.value.trim(); var f = Object.assign({}, forgeOf(), { mission: v, missionAt: Date.now() }); saveForgeNow(f); return v; }
    var row = el("div", "cdlg-btns"), sv = el("button", "btn", "Save my mission"), rl = el("button", "btn ghost", "Share in Rally"); sv.type = rl.type = "button"; sv.disabled = rl.disabled = off;
    sv.addEventListener("click", function () { if (!ta.value.trim()) { msg.textContent = "Write your mission first."; ta.focus(); return; } save(); msg.textContent = "✓ Saved. Only you can see it."; });
    rl.addEventListener("click", function () {
      var v = save(); if (!v) { msg.textContent = "Write your mission first."; ta.focus(); return; }
      S.close(); go("checkin");
      setTimeout(function () { var pt = $("post-text"); if (!pt) return; pt.value = "Here I am. Send me. My mission: " + v; try { pt.dispatchEvent(new Event("input", { bubbles: true })); pt.focus(); } catch (e) {} }, 60);
    });
    row.appendChild(sv); row.appendChild(rl); box.appendChild(row);
    var tim = el("button", "btn ghost", "Invite a Timothy"); tim.type = "button"; tim.style.width = "100%"; tim.style.marginTop = "8px";
    tim.addEventListener("click", function () { if (ta.value.trim()) save(); S.close(); state.menView = ""; go("mentor"); });
    box.appendChild(tim); box.appendChild(msg); S.focus();
  }

'''
rep('''  var PEN_SVG = ''', NEW + '''  var PEN_SVG = ''')

# Ask entries
NEW_ASK = r'''
  ASK.push(
    { t: "The Stand Firm creed", a: "1 Corinthians 16:13–14 sits at the top of Today: be watchful, stand firm in the faith, act like men, be strong, and do it all in love. Each daily box carries one of those five commands.", w: "Today, at the top", k: "creed stand firm watchful act like men strong love commands corinthians", go: { p: "today" } },
    { t: "Bold Step", a: "Once a week pick one hard thing you’ve been avoiding: share your faith, have the conversation, apologize first, lead your family in prayer, or say no to what pulls you from God. Commit to it on Today, then tap I did it before Sunday 8 AM Arizona time for 25 points. What you write stays private; share it with your Paul if you want someone to hold you to it.", w: "Today, under your boxes", k: "bold step courage hard avoiding gideon weekly", go: { p: "today" } },
    { t: "Protector challenge", a: "Stand in the Gap is in the weekly orders on Train. Pick one: protect your family, protect the vulnerable, or protect your brothers. Mark it complete on your honor for 30 points.", w: "Train › Orders for the week", k: "protector protect stand gap widow vulnerable family brothers challenge nehemiah", go: { p: "train" } },
    { t: "Ready to protect", a: "Five real-world standards on Train: carry, ruck, floor to feet, sprint, and first aid and CPR. Each has a scaled version for age or injury. Mark them on your honor. No points. Ranks: In training, Of the Thirty (3 met), Of the Three (all 5).", w: "Train › Ready to protect", k: "ready protect standards carry ruck sprint cpr first aid rank thirty three mighty men", go: { p: "train" } },
    { t: "Lead at Home", a: "A daily box: pray with your family or lead at home today. Tap it when it’s done for 1 point.", w: "Today", k: "lead home family pray wife kids box", go: { p: "today" } },
    { t: "Be watchful (Sabbath self-check)", a: "On your Sabbath, Today shows Be watchful: three honest questions about where you were weak, what is pulling at you, and where you saw God. It saves privately to your journal. Share it with your Paul only if you choose.", w: "Today on your Sabbath", k: "watchful self check sabbath weak temptation examine lamentations", go: { p: "today" } },
    { t: "My mission (Sent)", a: "When a campaign ends, the Campaign page shows You are sent. Write the mission God is sending you on, then share it in Rally or invite a Timothy. You can also open it from your profile with My mission.", w: "Campaign after it ends · Profile › My mission", k: "sent mission commission isaiah send campaign end timothy", go: { p: "camp" } }
  );
  if (HELP.camp && HELP.camp.how) HELP.camp.how.push("When a campaign ends, You are sent shows here. Write your mission, then share it in Rally or invite a Timothy.");
'''
rep('''  var ASK_STOP = ''', NEW_ASK + '''  var ASK_STOP = ''')

open(dst, "w", encoding="utf-8").write(s)
print("ok", ver)
