  /* ---------- v256: plan setup with a health check, Foundation, the pre-session check and Stop · Pain ----------
     Health answers (the health-check result, check-in answers, pain taps) are kept on this device only, in localStorage.
     They are never written to the database, a score, a board or a log. Plan settings (goal, level, equipment) are saved with the plan.
     Every threshold below is a pilot default. */
  var HL_MEM = null;
  function hlKey() { return "fs-health-" + (state.me || "anon"); }
  function hlGet() {
    if (HL_MEM && HL_MEM.k === hlKey()) return HL_MEM.v;
    var v = null; try { v = JSON.parse(localStorage.getItem(hlKey()) || "null"); } catch (e) { v = null; }
    if (!v || typeof v !== "object" || Array.isArray(v)) v = {};
    if (!v.checks || typeof v.checks !== "object") v.checks = {};
    if (!Array.isArray(v.light)) v.light = [];
    if (!Array.isArray(v.stops)) v.stops = [];
    HL_MEM = { k: hlKey(), v: v, fail: false }; return v;
  }
  function hlSave() {
    var v = hlGet(), cut = addDays(todayKey(), -60);
    Object.keys(v.checks).forEach(function (k) { if (k < cut) delete v.checks[k]; }); v.stops = v.stops.slice(-200);
    try { localStorage.setItem(hlKey(), JSON.stringify(v)); HL_MEM.fail = false; return true; } catch (e) { HL_MEM.fail = true; return false; }
  }
  function hlBlocked() { var s = hlGet().screen; return !!(s && s.clear === false); }
  function realPlan() { var p = state.settings.plan; return p && p.start && PLAN.W[p.program] ? p : null; }
  function psSetup(p) { return p && p.setup && typeof p.setup === "object" ? p.setup : null; }
  var FND_DAYS = 28;
  function fndOn(p, key) { var s = psSetup(p); if (!s || !s.fnd || !s.fndFrom) return false; var d = dayDiff(s.fndFrom, key); return d >= 0 && d < FND_DAYS; }
  function lightOn(key) { return hlGet().light.indexOf(key) >= 0; }
  // Lighter session: sets come down 25 to 40 percent. Two sets or fewer stay as they are.
  var LIGHT_N = { 3: 2, 4: 3, 5: 3, 6: 4, 7: 5, 8: 5, 9: 6, 10: 6, 11: 7, 12: 8 };
  function rxCut(rx, how) {
    return String(rx).replace(/^(\s*(?:Superset\s+[A-Z]\d+:\s*)?)(\d+)(\s*(?:x\s|rounds\b))/i, function (m, a, n, b) { n = +n; return a + (how === "light" ? (LIGHT_N[n] || n) : (n >= 3 ? n - 1 : n)) + b; });
  }
  // A ramp that ends in a single ("1 x 5, 1 x 3, 1 x 1") becomes three sets of five.
  function rxNoSingle(rx) { var s = String(rx).replace(/\(.*$/, ""); return /^\s*\d+\s*x\s*\d+(\s*,\s*\d+\s*x\s*\d+)+\s*$/i.test(s) && /x\s*1\s*$/.test(s) ? "3 x 5 (rest 2 min)" : rx; }
  function easeWorkout(wf, p, key) {
    if (!wf || wf.kind !== "train" || !wf.w) return wf;
    var s = wf.rt ? null : psSetup(p), f = !wf.rt && fndOn(p, key), l = lightOn(key), ns = f || !!(s && psBeginner(s.level));
    if (!f && !l && !ns) return wf;
    var w = Object.assign({}, wf.w), single = false;
    w.exercises = wf.w.exercises.map(function (e) {
      var rx = e[1], r0 = rx; if (ns) { rx = rxNoSingle(rx); if (rx !== r0) single = true; }
      if (f) rx = rxCut(rx, "fnd"); if (l) rx = rxCut(rx, "light");
      var o = e.slice(); o[1] = rx; return o;
    });
    var out = { kind: wf.kind, w: w, th: wf.th, ease: { fnd: f, light: l, single: single } }; if (wf.rt) out.rt = true; return out;
  }
  function easeNote(wf, p, key) {
    var e = wf && wf.ease, out = []; if (!e) return out;
    if (e.fnd) out.push("Foundation, week " + (Math.floor(dayDiff(psSetup(p).fndFrom, key) / 7) + 1) + " of 4: fewer sets, low impact, and easy effort. Stop every set with 3 or more reps left (5 to 7 out of 10).");
    if (e.single) out.push("The heavy single is replaced with 3 x 5 at your level. Keep it at 7 out of 10 or easier.");
    if (e.light) out.push("Lighter session today: " + (e.fnd ? "" : "fewer sets, and ") + "stop every set with 3 or more reps left. Pilot default.");
    return out;
  }
  /* Equipment he said he does not have. A swap is only made where the alternates list has one. */
  var EQ_RX = { pullup: /pull-?up|chin-?up|hanging|dead hang/i, bench: /\bbench\b|incline (?:dumbbell|barbell|press)|chest-supported/i, kb: /kettlebell/i, mb: /medicine ball|med ball|ball slam/i, sled: /\bsled\b|prowler/i, bands: /\bband/i, stairs: /step-?up|stair/i };
  var EQ_NAME = { pullup: "a pull-up bar", bench: "a bench", kb: "a kettlebell", mb: "a medicine ball", sled: "a sled", bands: "bands", stairs: "stairs or a step" };
  function eqMissing(name) { var s = psSetup(realPlan()); if (!s || !s.inv) return ""; for (var k in EQ_RX) if (!s.inv[k] && EQ_RX[k].test(name)) return k; return ""; }
  function eqReasons(g, key) {
    var p = realPlan(), s = psSetup(p), out = []; if (!s) return out;
    var miss = eqMissing(moveName(g, p.equip));
    if (miss === "pullup") out.push("No Pull-Up Bar"); if (miss === "bench") out.push("No Bench");
    if (s.impact === "low" || fndOn(p, key)) out.push("Low Impact");
    return out;
  }
  function eqOk(g) { var p = realPlan(); return !p || !eqMissing(moveName(g, p.equip)); }
  function psEquip(inv) {
    var S = PLAN.META.equipmentSetups;
    if (inv.bar && inv.rack && inv.bench && inv.machines) return S[0];
    if (inv.bar && inv.rack && inv.bench && inv.db) return S[1];
    if (inv.db) return S[2];
    return S[3];
  }
  function psNoVertPull(inv) { return !inv.pullup && !inv.machines && !(inv.bands && inv.anchor); }
  // Movements in this program that need something he does not have and have no swap in the alternates list.
  function psUnmatched(prog, equip, inv) {
    var seen = {}, out = [];
    (PLAN.W[prog] || []).forEach(function (d) { (d.exercises || []).forEach(function (e) {
      var nm = moveName(e[0], equip); if (seen[nm]) return; seen[nm] = 1;
      for (var k in EQ_RX) if (!inv[k] && EQ_RX[k].test(nm)) {
        var opts = (ALT.alternates || {})[e[0]] || {}, fix = (k === "pullup" ? opts["No Pull-Up Bar"] : k === "bench" ? opts["No Bench"] : null) || [];
        if (!fix.some(function (c) { if (!PLAN.M[c]) return false; var cn = moveName(c, equip); for (var j in EQ_RX) if (!inv[j] && EQ_RX[j].test(cn)) return false; return true; })) out.push(nm + " (needs " + EQ_NAME[k] + ")");
        return;
      }
    }); });
    return out;
  }
  var PS = null, PS_KEEP = null;
  function psReady(d) { return !!(d.goal && d.hist && d.cons && d.level && d.impact && d.lifts.length === 3); }
  function psBeginner(level) { return level !== "intermediate" && level !== "advanced"; }
  var PS_GOALS = [["strong", "Get stronger", "Forged"], ["muscle", "Build muscle", "Built"], ["cond", "Conditioning", "Engine"], ["combat", "Athletic and combat", "Warrior"]];
  var PS_HIST = [["new", "New or under 6 months"], ["mid", "6 months to 2 years"], ["long", "2 years or more"]];
  var PS_CONS = [["none", "Not training"], ["some", "Off and on"], ["most", "Most weeks"]];
  var PS_LEVEL = [["beginner", "Beginner"], ["intermediate", "Intermediate"], ["advanced", "Advanced"]];
  var PS_TIME = [["30", "30 min"], ["45", "45 min"], ["long", "Longer is fine"]];
  var PS_INV = [["bench", "A bench"], ["rack", "A rack with safeties"], ["bar", "A barbell and plates"], ["db", "Dumbbells"], ["machines", "Cables and machines"], ["pullup", "A pull-up bar"], ["bands", "Bands"], ["anchor", "A secure anchor for bands"], ["kb", "A kettlebell"], ["mb", "A medicine ball"], ["sled", "A sled"], ["stairs", "Stairs or a step"], ["floor", "Floor space to lie down"]];
  var PS_FLAGS = [["chest", "Chest pain or pressure during activity"], ["dizzy", "Dizziness or fainting during exercise"], ["surgery", "Recent surgery"], ["meds", "A medication that affects exercise"]];
  var PS_AREAS = ["Knee", "Hip", "Low Back", "Shoulder", "Elbow or Wrist"];
  // When the answers are missing or disagree, the lower level is suggested.
  function psLevel(hist, cons) { return hist === "long" ? (cons === "most" ? "advanced" : cons === "some" ? "intermediate" : "beginner") : hist === "mid" && cons === "most" ? "intermediate" : "beginner"; }
  function psProg(goal) { var g = PS_GOALS.filter(function (x) { return x[0] === goal; })[0]; return g ? g[2] : "Forged"; }
  function openPlanSetup(onClose, startAt) {
    if (!state.me || !state.canWrite) return;
    var p = realPlan(), s = psSetup(p) || {}, b = state.settings.body || {}, inv = {};
    PS_INV.forEach(function (x) { inv[x[0]] = !!(s.inv && s.inv[x[0]]); });
    var kept = PS_KEEP && PS_KEEP.me === state.me ? PS_KEEP.d : null;
    PS = { i: 0, stop: false, onClose: onClose || null, d: kept || {
      goal: s.goal || "", hist: s.hist || "", cons: s.cons || "", level: s.level || "", levelSet: !!s.level, time: s.time || "45",
      fourth: !!(p && p.fourth), rest: p ? p.rest : 0, lifts: p ? liftDaysOn(p, todayKey()) : defaultLiftDays(0), full: false,
      inv: inv, impact: s.impact || "", flags: {}, none: false, areas: Array.isArray(b.injuries) ? b.injuries.slice() : [], areasNone: false,
      program: p ? p.program : "", progSet: false } };
    if (hlBlocked() || startAt === "health") { PS.i = 3; PS.stop = hlBlocked() && startAt !== "health"; }
    drawPS();
  }
  function closePS(saved) { var cb = PS && PS.onClose; PS_KEEP = saved === true || !PS ? null : { me: state.me, d: PS.d }; PS = null; var o = $("psw"); if (o) o.remove(); drawTrain(); if (cb) cb(); }
  function psChips(box, opts, cur, onPick, multi) {
    var row = el("div", "onb-chips"); row.setAttribute("role", "group");
    opts.forEach(function (o) { var on = multi ? !!cur[o[0]] : cur === o[0], bt = el("button", "onb-chip" + (on ? " on" : ""), o[1]); bt.type = "button"; bt.setAttribute("aria-pressed", String(on)); bt.addEventListener("click", function () { onPick(o[0]); drawPS(); }); row.appendChild(bt); });
    box.appendChild(row); return row;
  }
  function psCheck(box, label, on, onTap, cls) {
    var bt = el("button", "ps-ck" + (on ? " on" : "") + (cls ? " " + cls : "")); bt.type = "button"; bt.setAttribute("role", "checkbox"); bt.setAttribute("aria-checked", String(!!on));
    bt.appendChild(el("i", null, on ? "✓" : "")); bt.appendChild(el("span", null, label)); bt.addEventListener("click", function () { onTap(); drawPS(); }); box.appendChild(bt); return bt;
  }
  function psSave(fnd) {
    if (!psReady(PS.d) || hlBlocked()) return;
    var d = PS.d, p = realPlan(), prog = d.program || psProg(d.goal), rest = +d.rest, keep = !!(p && p.program === prog && p.rest === rest);
    var np = { program: prog, equip: psEquip(d.inv), rest: rest, fourth: !!d.fourth, start: keep ? p.start : planStartFor(rest) }, ld = normLiftDays(d.lifts, rest);
    if (keep && Array.isArray(p.lifts)) { var nw = nextPlanWeek(p), kp = p.lifts.filter(function (x) { return x && x.from < nw; }); if (!kp.length) kp = [{ from: p.start, days: liftDaysOn(p, todayKey()) }]; if (kp[kp.length - 1].days.join(",") !== ld.join(",")) kp.push({ from: nw, days: ld }); np.lifts = kp; }
    else np.lifts = [{ from: np.start, days: ld }];
    var was = psSetup(p), inv = {}; PS_INV.forEach(function (x) { inv[x[0]] = !!d.inv[x[0]]; });
    np.setup = { v: 1, at: Date.now(), goal: d.goal, hist: d.hist, cons: d.cons, level: d.level, time: d.time, inv: inv, impact: d.impact === "ok" ? "ok" : "low", fnd: !!fnd,
      fndFrom: !fnd ? "" : keep && was && was.fnd && was.fndFrom ? was.fndFrom : keep ? todayKey() : np.start };
    var body = Object.assign({}, state.settings.body || {}); body.injuries = d.areas.slice(); state.settings.body = body;
    state.settings.plan = np; if (!keep) state.settings.dayMoves = {};
    state.planEdit = false; state.trainDay = np.start > todayKey() ? np.start : todayKey(); saveSettings(); ensureStrip(); closePS(true);
  }
  function drawPS() {
    if (!PS) return;
    var o = $("psw");
    if (!o) { o = el("div", "onb"); o.id = "psw"; o.style.zIndex = "160"; o.setAttribute("role", "dialog"); o.setAttribute("aria-modal", "true"); o.setAttribute("aria-labelledby", "psw-h"); document.body.appendChild(o); }
    var ob = $("psw-body"), keepTop = ob && PS.last === PS.i + (PS.stop ? "s" : "") ? ob.scrollTop : 0; PS.last = PS.i + (PS.stop ? "s" : "");
    o.textContent = ""; var d = PS.d;
    var bar = el("div", "onb-bar"), pr = el("div", "onb-prog"); for (var j = 0; j < 5; j++) pr.appendChild(el("i", !PS.stop && j <= PS.i ? "on" : null)); bar.appendChild(pr);
    var cx = el("button", "onb-skip", "Close"); cx.type = "button"; cx.addEventListener("click", function () { closePS(); }); bar.appendChild(cx); o.appendChild(bar);
    var body = el("div", "onb-body"); body.id = "psw-body"; o.appendChild(body);
    var foot = el("div", "onb-foot"); o.appendChild(foot);
    function h(kick, title) { body.appendChild(el("div", "onb-k", kick)); var t = el("h2", "onb-h", title); t.id = "psw-h"; t.tabIndex = -1; body.appendChild(t); }
    function q(text) { body.appendChild(el("span", "onb-lbl", text)); }
    function note(text, cls) { var n = el("p", "onb-note" + (cls ? " " + cls : ""), text); body.appendChild(n); return n; }
    function next(label, ok, fn) { var bt = el("button", "btn", label); bt.type = "button"; bt.disabled = !ok; bt.addEventListener("click", fn || function () { PS.i++; drawPS(); }); foot.appendChild(bt); return bt; }
    function back() { if (PS.i < 1) return; var bt = el("button", "onb-back", "‹ Back"); bt.type = "button"; bt.addEventListener("click", function () { PS.i--; PS.stop = false; drawPS(); }); foot.appendChild(bt); }
    if (PS.stop) {
      h("Set up your plan · Private", "Talk with your clinician first");
      var sc = el("div", "ps-stop"); sc.appendChild(el("p", null, "One of your answers needs a clinician’s eyes before a training plan. We are not able to judge it in an app."));
      sc.appendChild(el("p", null, "We have not built you a plan. Nothing is wrong with asking: it is what a wise man does.")); body.appendChild(sc);
      var c1 = el("div", "ps-card"); c1.appendChild(el("b", null, "What you can still do here")); c1.appendChild(el("p", null, "Your daily devotional, your journal, your brothers, and easy walking.")); body.appendChild(c1);
      var c2 = el("div", "ps-card"); c2.appendChild(el("b", null, "When you have talked with them")); c2.appendChild(el("p", null, "Come back and tap below. We will ask the questions again.")); body.appendChild(c2);
      note("Your answers stay on this phone. They are never shown to your group or on any board.");
      next("I have talked with my clinician", true, function () { d.flags = {}; d.none = false; PS.stop = false; PS.i = 3; drawPS(); });
      var ch = el("button", "onb-back", "Change my answers"); ch.type = "button"; ch.addEventListener("click", function () { PS.stop = false; PS.i = 3; drawPS(); }); foot.appendChild(ch);
    } else if (PS.i === 0) {
      h("Set up your plan · 1 of 5", "Where are you starting?");
      q("Your main goal"); psChips(body, PS_GOALS, d.goal, function (v) { d.goal = v; if (!d.progSet) d.program = psProg(v); });
      q("How long have you trained with weights?"); psChips(body, PS_HIST, d.hist, function (v) { d.hist = v; if (!d.levelSet) d.level = psLevel(d.hist, d.cons); });
      q("How consistent, last 3 months?"); psChips(body, PS_CONS, d.cons, function (v) { d.cons = v; if (!d.levelSet) d.level = psLevel(d.hist, d.cons); });
      q("Your level"); psChips(body, PS_LEVEL, d.level, function (v) { d.level = v; d.levelSet = true; });
      note(d.hist && d.cons ? "We suggest " + PS_LEVEL.filter(function (x) { return x[0] === psLevel(d.hist, d.cons); })[0][1] + " from your answers. You can change it." : "We suggest a level from your answers. You can change it.");
      next("Next", !!(d.goal && d.hist && d.cons && d.level));
    } else if (PS.i === 1) {
      h("Set up your plan · 2 of 5", "Your week");
      q("Training days a week"); psChips(body, [["3", "3 days"], ["4", "3 plus an optional 4th"]], d.fourth ? "4" : "3", function (v) { d.fourth = v === "4"; });
      q("Time you have per session"); psChips(body, PS_TIME, d.time, function (v) { d.time = v; });
      note("Core sessions are written for about 45 minutes. Your answer is saved with your plan; it does not change the sessions yet.");
      q("Your rest day (Sabbath)"); psChips(body, DAYN.map(function (n, i) { return [String(i), n.slice(0, 3)]; }), String(d.rest), function (v) { d.rest = +v; d.lifts = d.lifts.filter(function (x) { return x !== d.rest; }); if (d.lifts.length < 3) d.lifts = defaultLiftDays(d.rest); d.full = false; });
      q("Lifting days");
      var lc = el("div", "ld-chips"); drawLiftChips(lc, d, function () { drawPS(); }); body.appendChild(lc);
      note("Day 1 starts the day after your rest day.");
      next(d.lifts.length === 3 ? "Next" : "Pick your 3 lifting days", d.lifts.length === 3, function () { confirmBackToBack(d.lifts, +d.rest, function () { PS.i++; drawPS(); }); }); back();
    } else if (PS.i === 2) {
      h("Set up your plan · 3 of 5", "What do you have?");
      note("Tick everything you can use. We only give you movements you can do, where we have a swap for it.");
      var grid = el("div", "ps-grid"); PS_INV.forEach(function (x) { psCheck(grid, x[1], d.inv[x[0]], function () { d.inv[x[0]] = !d.inv[x[0]]; }); }); body.appendChild(grid);
      q("Jumping and running"); psChips(body, [["ok", "Fine for me"], ["low", "Keep it low impact"]], d.impact, function (v) { d.impact = v; });
      note("Your setup: " + psEquip(d.inv) + ".", "ok");
      if (psNoVertPull(d.inv)) { var wv = el("div", "ps-warn"); wv.appendChild(el("b", null, "No pull-up bar, cables or anchored band. ")); wv.appendChild(document.createTextNode("We cannot give you an overhead pull. You will get rows, and your plan will say that this pattern is missing.")); body.appendChild(wv); }
      next("Next", !!d.impact); back();
    } else if (PS.i === 3) {
      h("Set up your plan · 4 of 5 · Private", "Before we build it");
      var fb = el("div", "ps-card"); fb.appendChild(el("b", null, "Do any of these apply to you?"));
      PS_FLAGS.forEach(function (x) { psCheck(fb, x[1], d.flags[x[0]], function () { d.flags[x[0]] = !d.flags[x[0]]; d.none = false; }, "warn"); });
      psCheck(fb, "None of these", d.none, function () { d.none = !d.none; if (d.none) d.flags = {}; });
      body.appendChild(fb);
      note("These four answers stay on this phone. They are never sent anywhere and never shown to your group or on any board.");
      q("Anything we should work around?");
      var ar = el("div", "onb-chips"); PS_AREAS.forEach(function (a) { var on = d.areas.indexOf(a) >= 0, bt = el("button", "onb-chip" + (on ? " on" : ""), a); bt.type = "button"; bt.setAttribute("aria-pressed", String(on)); bt.addEventListener("click", function () { var k = d.areas.indexOf(a); if (k >= 0) d.areas.splice(k, 1); else d.areas.push(a); d.areasNone = false; drawPS(); }); ar.appendChild(bt); });
      var nb = el("button", "onb-chip" + (d.areasNone && !d.areas.length ? " on" : ""), "Nothing"); nb.type = "button"; nb.addEventListener("click", function () { d.areas = []; d.areasNone = true; drawPS(); }); ar.appendChild(nb); body.appendChild(ar);
      note("A sore area swaps work sets where we have an alternate. It is not a medical assessment, and you can always skip a movement. The areas are saved privately with your settings, never on a board.");
      var anyFlag = PS_FLAGS.some(function (x) { return d.flags[x[0]]; });
      next("Next", anyFlag || d.none, function () {
        var v = hlGet(); v.screen = { at: todayKey(), clear: !anyFlag }; hlSave();
        if (anyFlag) { PS.stop = true; drawPS(); drawTrain(); return; }
        PS.i = psReady(d) ? 4 : !(d.goal && d.hist && d.cons && d.level) ? 0 : d.lifts.length !== 3 ? 1 : 2; drawPS();
      }); back();
    } else {
      h("Set up your plan · 5 of 5", "Your plan");
      if (!d.program) d.program = psProg(d.goal);
      var eq = psEquip(d.inv), rec0 = psProg(d.goal), pc = el("div", "ps-card rec");
      pc.appendChild(el("span", "onb-k", d.program === rec0 ? "Recommended for you" : "Your choice"));
      pc.appendChild(el("b", "ps-prog", d.program + " · " + PLAN.META.programs[d.program]));
      pc.appendChild(el("p", null, (d.fourth ? "3 days plus an optional 4th" : "3 days") + ", " + DAYN[d.rest] + " rest, lifting " + liftsLabel(normLiftDays(d.lifts, +d.rest)) + ". " + eq + "."));
      if (d.areas.length) pc.appendChild(el("p", null, "Swaps for: " + d.areas.join(", ").toLowerCase() + ", where we have one."));
      if (d.impact !== "ok") pc.appendChild(el("p", null, "Low impact: jumps are swapped where we have an alternate."));
      body.appendChild(pc);
      q("Program"); psChips(body, Object.keys(PLAN.META.programs).map(function (k) { return [k, k]; }), d.program, function (v) { d.program = v; d.progSet = true; });
      var miss = psUnmatched(d.program, eq, d.inv);
      if (psNoVertPull(d.inv) || miss.length) {
        var mw = el("div", "ps-warn"); mw.appendChild(el("b", null, "What we could not match. "));
        if (psNoVertPull(d.inv)) mw.appendChild(document.createTextNode("No overhead pull: you have no pull-up bar, cables or anchored band, so you get rows instead. "));
        if (miss.length) mw.appendChild(document.createTextNode("No swap yet for " + miss.slice(0, 6).join("; ") + (miss.length > 6 ? "; and " + (miss.length - 6) + " more" : "") + ". Skip these or tap Alt in the workout."));
        body.appendChild(mw);
      }
      var beg = psBeginner(d.level), fc = el("div", "ps-card fnd"); fc.appendChild(el("span", "onb-k", "Start with Foundation · 4 weeks"));
      ["Fewer sets per session", "Effort kept at 5 to 7 out of 10", "No heavy singles", "Low impact"].forEach(function (t) { var r = el("div", "ps-ck on static"); r.appendChild(el("i", null, "✓")); r.appendChild(el("span", null, t)); fc.appendChild(r); });
      fc.appendChild(el("p", null, "Learn the lifts first. Full " + d.program + " sessions start in week 5.")); body.appendChild(fc);
      var rp = realPlan(), keeps = !!(rp && rp.program === d.program && rp.rest === +d.rest);
      note(keeps ? "Your plan keeps its start date." : "Day 1 starts " + longDate(planStartFor(+d.rest)) + ".");
      note(beg ? "Beginners always start in Foundation, and never get a heavy single." : "Foundation is your choice at your level.");
      next("Start with Foundation", true, function () { psSave(true); });
      if (!beg) { var sn = el("button", "btn ghost", "Start " + d.program + " now"); sn.type = "button"; sn.addEventListener("click", function () { psSave(false); }); foot.appendChild(sn); }
      back();
    }
    if (keepTop) body.scrollTop = keepTop; else { var hh = $("psw-h"); if (hh) try { hh.focus({ preventScroll: true }); } catch (e) {} }
  }
  /* ---------- Pre-session check (thirty seconds) ---------- */
  var CK_OPTS = { sleep: [["rough", "Rough"], ["ok", "OK"], ["good", "Good"]], sore: [["normal", "Normal"], ["more", "More than usual"], ["none", "None"]], pain: [["no", "No"], ["little", "A little"], ["yes", "Yes"]], drive: [["low", "Low"], ["normal", "Normal"], ["high", "High"]] };
  var EASE_SESSIONS = 3, EASE_SIGNALS = 2;
  function ckGet(key) { return hlGet().checks[key] || null; }
  function ckPut(key, c) { hlGet().checks[key] = c; return hlSave(); }
  function easeLeft(key) { var L = hlGet().ease; return L && Array.isArray(L.dates) && L.dates.length < EASE_SESSIONS && L.dates.indexOf(key) < 0 ? L.dates.length : -1; }
  // Reps down in each of the last two sessions of a lift, at the same or a lower weight and the same number of sets.
  function perfDrop(w, rec, key, p) {
    if (!wkHist || !w) return ""; var out = "";
    w.exercises.slice(0, 4).some(function (e, i) {
      var ps = parseSets(e[1]); if (!ps || ps.time) return false;
      var g = effMove(rec, i, e[0]), ss = liftSessions(g, key); if (ss.length < 3) return false;
      var v = ss.slice(0, 3).map(function (dd) { var ws = dd.sets.filter(function (x) { return !x.k; }); return { n: ws.length, r: ws.reduce(function (a, x) { return a + x.r; }, 0), w: ws.reduce(function (a, x) { return Math.max(a, x.w); }, 0) }; });
      if (v[0].n && v[0].n === v[1].n && v[1].n === v[2].n && v[0].r < v[1].r && v[1].r < v[2].r && v[0].w <= v[1].w && v[1].w <= v[2].w) { out = moveName(g, (p || {}).equip); return true; }
      return false;
    });
    return out;
  }
  function drawPreCheck(body, key, w, rec, p, addStart) {
    var c = ckGet(key) || {}, drop = perfDrop(w, rec, key, p);
    function put() { ckPut(key, c); }
    function redo() {
      var v = hlGet(); v.light = v.light.filter(function (x) { return x !== key; }); if (v.ease && Array.isArray(v.ease.dates)) v.ease.dates = v.ease.dates.filter(function (x) { return x !== key; });
      c = { sleep: c.sleep, sore: c.sore, pain: c.pain, drive: c.drive }; put(); drawWorkoutPage(true);
    }
    function link(text, fn) { var bt = el("button", "linkish ck-link", text); bt.type = "button"; bt.addEventListener("click", fn); body.appendChild(bt); return bt; }
    if (HL_MEM && HL_MEM.fail) body.appendChild(el("p", "note", "Your check could not be saved on this phone. It is kept only until you close the app."));
    if (!c.done) {
      var card = el("div", "rate-card ck-card"); card.appendChild(el("div", "rate-h", "How are you today? · Private"));
      [["sleep", "Sleep last night"], ["sore", "Soreness"], ["pain", "Any pain right now?"], ["drive", "Drive to train"]].forEach(function (x) {
        card.appendChild(el("span", "rate-l", x[1])); card.appendChild(rateChips(CK_OPTS[x[0]], c[x[0]], function (v) { if (v) c[x[0]] = v; else delete c[x[0]]; put(); }, x[1]));
      });
      if (drop) { var dl = el("p", "ck-log"); dl.appendChild(el("b", null, "From your log: ")); dl.appendChild(document.createTextNode(drop + " reps dropped in your last two sessions.")); card.appendChild(dl); }
      card.appendChild(el("p", "rate-n", "Thirty seconds. Your answers stay on this phone. They never show on the Board or earn points."));
      body.appendChild(card);
      var go1 = el("button", "btn wk-start", "See today’s plan"); go1.type = "button";
      go1.addEventListener("click", function () {
        c.done = true; c.skip = false; delete c.choice;
        if (c.pain === "yes" || c.pain === "little") c.res = "rest";
        else { var poor = (c.sleep === "rough" ? 1 : 0) + (c.sore === "more" ? 1 : 0) + (c.drive === "low" ? 1 : 0); c.drop = drop || ""; c.res = poor >= EASE_SIGNALS || drop || easeLeft(key) > 0 ? "suggest" : "asis"; }
        put(); drawWorkoutPage(true);
      });
      body.appendChild(go1);
      link("Skip the check", function () { c = { done: true, skip: true, res: "asis" }; put(); drawWorkoutPage(true); });
      return;
    }
    if (c.res === "rest") {
      var st = el("div", "ps-stop"); st.appendChild(el("b", "ps-stop-t", "Rest today"));
      st.appendChild(el("p", null, "You said you have pain right now. Do not train on it."));
      st.appendChild(el("p", null, "If it does not ease, or it worries you, talk with your doctor.")); body.appendChild(st);
      if (c.choice === "rest") body.appendChild(el("p", "note", "Today is marked as rest on this phone. Nothing is logged, and no one else sees why."));
      else { var mr = el("button", "btn wk-start", "Mark today as rest"); mr.type = "button"; mr.addEventListener("click", function () { c.choice = "rest"; put(); drawWorkoutPage(true); }); body.appendChild(mr); }
      link("Change my answer", redo); return;
    }
    if (c.res === "suggest" && !c.choice) {
      var why = []; if (c.sleep === "rough") why.push("rough sleep"); if (c.sore === "more") why.push("extra soreness"); if (c.drive === "low") why.push("low drive"); if (c.drop) why.push("your " + c.drop + " reps have dropped two sessions running");
      var n0 = easeLeft(key), ec = el("div", "ps-warn ck-ease"); ec.appendChild(el("b", "ps-stop-t", "Ease off today"));
      ec.appendChild(el("p", null, n0 > 0 ? "Session " + (n0 + 1) + " of " + EASE_SESSIONS + " on the lighter plan." + (why.length ? " Today: " + why.join(", ") + "." : "") : why.length ? why.join(", ").replace(/^./, function (m) { return m.toUpperCase(); }) + "." : ""));
      var f0 = null; (w.exercises || []).some(function (e) { var a = String(e[1]).replace(/\s*\(.*$/, "").replace(/\..*$/, ""), b2 = String(rxCut(e[1], "light")).replace(/\s*\(.*$/, "").replace(/\..*$/, ""); if (a !== b2) { f0 = [moveName(effMove(rec, w.exercises.indexOf(e), e[0]), (p || {}).equip), a, b2]; return true; } return false; });
      [f0 ? "One fewer set on most lifts (about a third less work)" : "Sets stay as written: they are already low", "Stop every set with 3 or more reps left", "Keep it this way for " + EASE_SESSIONS + " sessions, then we check again"].forEach(function (t) { var r = el("div", "ps-ck on static"); r.appendChild(el("i", null, "✓")); r.appendChild(el("span", null, t)); ec.appendChild(r); });
      if (f0) ec.appendChild(el("p", "ck-prev", f0[0] + ": was " + f0[1].replace(/^Superset\s+\w+:\s*/i, "") + ", today " + f0[2].replace(/^Superset\s+\w+:\s*/i, "")));
      ec.appendChild(el("p", "ck-pilot", "Pilot defaults · thresholds are not final")); body.appendChild(ec);
      var b1 = el("button", "btn wk-start", "Train the lighter session"); b1.type = "button";
      b1.addEventListener("click", function () { var v = hlGet(); if (v.light.indexOf(key) < 0) v.light.push(key); if (!v.ease || !Array.isArray(v.ease.dates) || v.ease.dates.length >= EASE_SESSIONS) v.ease = { dates: [] }; if (v.ease.dates.indexOf(key) < 0) v.ease.dates.push(key); v.light = v.light.slice(-400); c.choice = "light"; put(); drawWorkoutPage(true); });
      var b2 = el("button", "btn ghost wk-start", "Train it as written"); b2.type = "button"; b2.addEventListener("click", function () { delete hlGet().ease; c.choice = "asis"; put(); drawWorkoutPage(true); });
      body.appendChild(b1); body.appendChild(b2);
      link("Take today as a rest day", function () { c.choice = "rest"; put(); drawWorkoutPage(true); });
      return;
    }
    if (c.choice === "rest") { body.appendChild(el("p", "note", "Today is marked as rest on this phone. Nothing is logged.")); link("Change my answer", redo); return; }
    addStart();
    link(c.skip ? "Do the thirty-second check" : "Redo the check", redo);
  }
  /* ---------- Stop · Pain: stop the lift, then skip it or end the workout. No other lift is offered. ---------- */
  function normSkip(x) { var o = {}; if (x && typeof x === "object") Object.keys(x).forEach(function (k) { if (/^\d{1,2}$/.test(k) && x[k]) o[k] = 1; }); return o; }
  function logStop(key, name, what) { hlGet().stops.push({ d: key, t: Date.now(), lift: String(name).slice(0, 60), c: what }); hlSave(); }
  function skipLift(idx, on) {
    if (!wk || !wk.rec) return; var r = wk.rec; r.skip = normSkip(r.skip);
    if (on) { r.skip[idx] = 1; if (Array.isArray(r.ex[idx])) { r.ex[idx] = r.ex[idx].filter(function (s) { return s && Number(s.r) > 0; }); if (!r.ex[idx].length) delete r.ex[idx]; } }
    else delete r.skip[idx];
    saveWkNow(); redrawKeepScroll();
  }
  function openStopPain(idx, name, key, endFn) {
    var old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box sp-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "sp-t");
    var x = el("button", "dlg-x"); x.type = "button"; x.setAttribute("aria-label", "Close without stopping"); x.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>'; box.appendChild(x);
    box.appendChild(el("span", "label-caps sp-k", name + " · Private"));
    var t = el("h2", null, "Stop this lift"); t.id = "sp-t"; box.appendChild(t);
    box.appendChild(el("p", null, "Put the weight down and rest. Do not push through pain."));
    box.appendChild(el("p", null, "If it does not ease, or it worries you, talk with your doctor."));
    var sk = el("button", "btn", "Skip this lift and carry on"), en = el("button", "btn ghost", "End the workout here"); sk.type = en.type = "button";
    box.appendChild(sk); box.appendChild(en);
    box.appendChild(el("p", "note sp-n", "No other lift is offered in its place."));
    function close() { back.remove(); }
    x.addEventListener("click", close); back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); close(); } });
    sk.addEventListener("click", function () { close(); logStop(key, name, "skip"); skipLift(idx, true); });
    en.addEventListener("click", function () { close(); logStop(key, name, "end"); if (wk && wk.rec) { wk.rec.skip = normSkip(wk.rec.skip); wk.rec.skip[idx] = 1; } if (endFn) endFn(); });
    back.appendChild(box); document.body.appendChild(back); sk.focus({ preventScroll: true });
  }
