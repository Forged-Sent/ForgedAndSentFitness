import sys
S = ''  # set to the folder that holds v255.html and v256/add.js
src = open(S + 'v255.html', encoding='utf-8').read()
add = open(S + 'v256/add.js', encoding='utf-8').read()

def rep(old, new, count=1):
    global src
    n = src.count(old)
    if n != count:
        sys.exit('expected %d, found %d: %r' % (count, n, old[:90]))
    src = src.replace(old, new)

def between(start, end, new):
    global src
    if src.count(start) != 1:
        sys.exit('start marker count %d: %r' % (src.count(start), start[:80]))
    i = src.index(start) + len(start); j = src.index(end, i)
    src = src[:i] + new + src[j:]

# version
rep('var APP_VERSION = "v255";', 'var APP_VERSION = "v256";')

# styles
rep('/* First-time setup */', '''/* v256: plan setup, check-in and Stop . Pain */
.ps-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 0 10px; border: 1px solid var(--line); border-radius: var(--radius, 4px); background: var(--surface); padding: 4px 10px; }
.ps-ck { display: grid; grid-template-columns: 22px minmax(0, 1fr); gap: 8px; align-items: start; width: 100%; min-height: 40px; padding: 8px 0; background: none; border: 0; text-align: left; font-size: 13.5px; line-height: 1.3; color: var(--ink); cursor: pointer; }
.ps-ck.static { cursor: default; min-height: 0; padding: 4px 0; }
.ps-ck i { width: 20px; height: 20px; border: 2px solid var(--muted); border-radius: 3px; display: grid; place-items: center; font-style: normal; font-weight: 700; font-size: 13px; color: var(--accent-ink); }
.ps-ck.on i { background: var(--accent); border-color: var(--accent); }
.ps-ck.warn.on i { background: var(--danger); border-color: var(--danger); color: var(--bg); }
.ps-card { border: 1px solid var(--line); border-radius: var(--radius, 4px); background: var(--surface); padding: 10px 12px; display: flex; flex-direction: column; gap: 4px; }
.ps-card > b { font-family: var(--f-label); font-weight: 700; letter-spacing: .06em; text-transform: uppercase; font-size: 14px; }
.ps-card p { margin: 0; font-size: 13.5px; line-height: 1.45; color: var(--muted); }
.ps-card.rec { border-left: 3px solid var(--accent); } .ps-card.fnd { border-color: var(--brass); }
.ps-card .ps-prog { font-size: 22px; font-weight: 800; letter-spacing: .02em; }
.ps-warn { border: 1px solid var(--brass); border-radius: var(--radius, 4px); padding: 10px 12px; font-size: 13.5px; line-height: 1.45; display: flex; flex-direction: column; gap: 4px; }
.ps-warn > b:first-child { display: inline; } .ps-warn p { margin: 0; }
.ps-stop { border: 2px solid var(--danger); border-radius: var(--radius, 4px); padding: 12px; display: flex; flex-direction: column; gap: 6px; background: color-mix(in srgb, var(--danger) 9%, transparent); }
.ps-stop p { margin: 0; font-size: 14.5px; line-height: 1.45; }
.ps-stop-t { display: block; font-family: var(--f-label); font-weight: 800; font-size: 22px; line-height: 1.05; text-transform: uppercase; }
#psw .onb-lbl { margin-top: 6px; } #psw .ld-chips { margin: 0; }
.ck-card .rate-chips .mini { flex: 1 1 0; min-width: 0; padding: 4px 4px; }
.ck-log { margin: 10px 0 0; padding: 8px 10px; border: 1px solid var(--line); border-radius: var(--radius, 4px); font-size: 13px; }
.ck-ease { margin: 12px 0; } .ck-prev { color: var(--muted); font-size: 13px; }
.ck-pilot { font-family: var(--f-label); font-weight: 700; letter-spacing: .1em; text-transform: uppercase; font-size: 11px; color: var(--brass); }
.ck-link { display: block; width: 100%; text-align: center; margin-top: 4px; }
.wk-start + .wk-start { margin-top: 8px; }
.ease-note { margin: 8px 0 0; padding: 8px 10px; border-left: 3px solid var(--brass); background: color-mix(in srgb, var(--brass) 8%, transparent); font-size: 13px; line-height: 1.4; }
.sp-btn { flex: none; min-height: 36px; min-width: 0; padding: 0 10px; font-size: 11.5px; border-color: var(--danger); color: var(--danger); }
.sp-box .btn { width: 100%; } .sp-box .sp-k { font-size: 12px; color: var(--muted); padding-right: 40px; } .sp-box p { margin: 0; font-size: 15px; line-height: 1.45; } .sp-box .sp-n { text-align: center; font-size: 12.5px; }
.wx-skip { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: 6px; padding: 8px 10px; border: 1px dashed var(--line); border-radius: var(--radius, 4px); font-size: 13.5px; color: var(--muted); }
/* First-time setup */''')

# new code block, before the plan form
rep('  function drawPlanForm() {', add + '  function drawPlanForm() {')

# workoutFor: hold when the health check says stop; Foundation, beginner singles and lighter sessions
rep('''  function workoutFor(key) {
    var rw = rtWorkout(key); if (rw) return rw;''', '''  function workoutFor(key) {
    if (key >= todayKey() && hlBlocked()) return planCfg() ? { kind: "before", hold: true } : null;
    var rw = rtWorkout(key); if (rw) return easeWorkout(rw, null, key);''')
rep('''    return { kind: w.sessionType === "Rest" ? "rest" : "train", w: w, th: th };
  }
  function moveName(g, equip)''', '''    return easeWorkout({ kind: w.sessionType === "Rest" ? "rest" : "train", w: w, th: th }, p, key);
  }
  function moveName(g, equip)''')

# automatic swaps: equipment he does not have, and low impact
rep('''    var areas = ((state.settings.body || {}).injuries || []), options = (ALT.alternates || {})[g] || {};''',
    '''    var areas = ((state.settings.body || {}).injuries || []).concat(eqReasons(g, (rec && rec.date) || todayKey())), options = (ALT.alternates || {})[g] || {};''')
rep('''        if (PLAN.M[candidate] && !areas.some(''', '''        if (PLAN.M[candidate] && eqOk(candidate) && !areas.some(''')

# the plan editor keeps the setup answers
rep('''    var np = { program: d.program, equip: d.equip, rest: d.rest, fourth: !!d.fourth, start: restart ? planStartFor(d.rest) : p.start }, nd = normLiftDays(d.lifts, d.rest);''',
    '''    var np = { program: d.program, equip: d.equip, rest: d.rest, fourth: !!d.fourth, start: restart ? planStartFor(d.rest) : p.start }, nd = normLiftDays(d.lifts, d.rest);
    if (p && p.setup) { np.setup = Object.assign({}, p.setup); if (restart && np.setup.fnd) np.setup.fndFrom = np.start; }''')

# Train: no plan opens setup, a stop shows the clinician card
rep('''    var p = planCfg(), box = $("plan-summary"), editing = state.planEdit || !p; box.textContent = "";
    $("plan-form").hidden = !editing; $("plan-cancel").hidden = !p;
    if (editing) drawPlanForm();
    if (p && !editing) {''', '''    var p = planCfg(), box = $("plan-summary"), held = hlBlocked(), editing = !!(state.planEdit && p && !held); box.textContent = "";
    $("plan-form").hidden = !editing; $("plan-cancel").hidden = !p;
    if (editing) drawPlanForm();
    if (held) {
      var hc = el("div", "ps-stop"); hc.appendChild(el("b", "ps-stop-t", "Talk with your clinician first"));
      hc.appendChild(el("p", null, "Your training plan is on hold. One of your health-check answers needs a clinician’s eyes before you train."));
      hc.appendChild(el("p", null, "Your devotional, journal and brothers are all still here."));
      var hb = el("button", "btn", "I have talked with my clinician"); hb.type = "button"; hb.disabled = !state.me || !state.canWrite; hb.addEventListener("click", function () { openPlanSetup(); }); hc.appendChild(hb);
      box.appendChild(hc); return;
    }
    if (!p) {
      var nc = el("div", "ps-card rec"); nc.appendChild(el("b", null, "Set up your plan"));
      nc.appendChild(el("p", null, "Five short steps: your goal, your week, what you have, a health check, and your plan."));
      var nbp = el("button", "btn", "Set up your plan"); nbp.type = "button"; nbp.disabled = !state.me || !state.canWrite; nbp.addEventListener("click", function () { openPlanSetup(); }); nc.appendChild(nbp);
      box.appendChild(nc); return;
    }
    if (p && !editing) {''')
rep('''      var cb = el("button", "btn ghost", "Change plan"); cb.type = "button"; cb.addEventListener("click", openPlanEdit); row.appendChild(cb);''',
    '''      var su = psSetup(realPlan());
      if (su) row.appendChild(el("span", "sub", "Level: " + su.level + (fndOn(realPlan(), todayKey()) ? " · Foundation until " + longDate(addDays(su.fndFrom, FND_DAYS - 1)).split(",").slice(0, 2).join(",") : su.fnd && su.fndFrom > todayKey() ? " · Foundation for the first 4 weeks" : "")));
      var cb = el("button", "btn ghost", "Change plan"); cb.type = "button"; cb.addEventListener("click", openPlanEdit); row.appendChild(cb);
      if (realPlan()) { var sb0 = el("button", "btn ghost", su ? "Run plan setup again" : "Plan setup: goal, equipment and health check"); sb0.type = "button"; sb0.disabled = !state.me || !state.canWrite; sb0.addEventListener("click", function () { openPlanSetup(); }); row.appendChild(sb0); }''')

# first-run setup: the training step hands over to plan setup
rep('''["profile", "service", "goal", "training", "three"].indexOf(k) >= 0) onbSaveStep(k);''', '''["profile", "service", "goal", "three"].indexOf(k) >= 0) onbSaveStep(k);''')
between('''    } else if (k === "training") {\n''', '''    } else if (k === "three") {''', '''      h("Step 5 of 7", "Your training");
      body.appendChild(el("p", "onb-lead", "Five short steps so the plan fits you: your goal, your week, what you have, a health check, and your plan."));
      var pz = realPlan();
      if (hlBlocked()) body.appendChild(el("p", "onb-note", "Plan setup is on hold until you have talked with your clinician. You can pick it up on Train."));
      else if (pz) body.appendChild(el("p", "onb-note ok", "Plan set: " + pz.program + " \\u00B7 " + DAYN[pz.rest] + " Sabbath."));
      next(pz ? "Change my plan setup" : "Set up my plan", function () { openPlanSetup(function () { if (ONB) drawOnb(); }); });
      var sk5 = el("button", "btn ghost", pz ? "Next" : "Do this later"); sk5.type = "button"; sk5.addEventListener("click", function () { onbGo(1); }); foot.appendChild(sk5);
      back();
''')

# workout log keeps skipped lifts
rep('''      o.swaps = normSwaps(r.swaps);
      o.rate = normRate(r.rate);''', '''      o.swaps = normSwaps(r.swaps);
      o.skip = normSkip(r.skip);
      o.rate = normRate(r.rate);''')

# workout page: plan notes under the title
rep('''    body.appendChild(el("h1", "pg", w.title));
    var altW = !S && !rec.finishedAt && !rec.startedAt ? optAlt(key) : ""; body.classList.toggle("alt-on", !!altW);''',
    '''    body.appendChild(el("h1", "pg", w.title));
    if (!S) easeNote(wf, p, key).forEach(function (t) { body.appendChild(el("p", "ease-note", t)); });
    var endNow = null;
    var altW = !S && !rec.finishedAt && !rec.startedAt ? optAlt(key) : ""; body.classList.toggle("alt-on", !!altW);''')

# workout page: the check comes before "Pray, then train"
rep('''    if (isToday && !started && !done && !altW) { var sb = el("button", "btn wk-start", "Pray, then train"); sb.type = "button"; sb.disabled = off || !wk.loaded; sb.addEventListener("click", function () { openWorkoutPrayer(function () { if (!wk.root) wk.root = emptyWk(key); if (!wk.rec) wk.rec = wk.root; if (!wk.rec.startedAt) wk.rec.startedAt = Date.now(); saveWkNow(); drawWorkoutPage(true); }); }); body.appendChild(sb); }''',
    '''    if (isToday && !started && !done && !altW) {
      var addStart = function () { var sb = el("button", "btn wk-start", "Pray, then train"); sb.type = "button"; sb.disabled = off || !wk.loaded; sb.addEventListener("click", function () { openWorkoutPrayer(function () { if (!wk.root) wk.root = emptyWk(key); if (!wk.rec) wk.rec = wk.root; if (!wk.rec.startedAt) wk.rec.startedAt = Date.now(); var c0 = !S && ckGet(key); if (c0 && c0.sleep) rateOf(wk.rec).pre.sleep = c0.sleep; saveWkNow(); drawWorkoutPage(true); }); }); body.appendChild(sb); };
      if (!S && !off && wk.loaded) drawPreCheck(body, key, w, rec, p, addStart); else addStart();
    }''')

# the old "Before you lift" card is replaced by the check
between('''    if (live && !S && !off) {\n      var rr = rateOf(rec), pc = el("div", "rate-card"); pc.appendChild(el("div", "rate-h", "Before you lift"));''',
        '''    if (S && !normExtra(rec.extra).length)''', '''
    }
''')
rep('''    if (live && !S && !off) {\n      var rr = rateOf(rec), pc = el("div", "rate-card"); pc.appendChild(el("div", "rate-h", "Before you lift"));\n    }\n''', '')

# Stop . Pain on every lift, and a skipped lift
rep('''      ex.appendChild(top);
      if (swp0) ex.appendChild(el("span", "sw-note", "Swapped from "''', '''      var skipped = !!(rec.skip && rec.skip[idx]);
      if (live && !editing && isToday && !off && wk.loaded && !skipped) {
        var spb = el("button", "mini sp-btn", "Stop \\u00B7 Pain"); spb.type = "button"; spb.setAttribute("aria-label", "Stop " + shownName + " because of pain");
        spb.addEventListener("click", function () { saveWkNow(); openStopPain(idx, shownName, key, function () { if (endNow) endNow(); }); }); top.appendChild(spb);
      }
      ex.appendChild(top);
      if (swp0) ex.appendChild(el("span", "sw-note", "Swapped from "''')
rep('''      if (live) {
        var a = setsOf(idx, ps);''', '''      if (live && skipped) {
        var ab0 = top.querySelector(".sw-btn"); if (ab0) ab0.remove();
        var skr = el("div", "wx-skip"); skr.appendChild(el("span", null, "Skipped today."));
        if (!editing && isToday && !off) { var ub = el("button", "mini", "Bring it back"); ub.type = "button"; ub.addEventListener("click", function () { skipLift(idx, false); }); skr.appendChild(ub); }
        ex.appendChild(skr);
        if (Array.isArray(rec.ex[idx])) { var sl0 = fmtSetLine(rec.ex[idx], ps && ps.time); if (sl0) ex.appendChild(el("span", "wlog", "Logged before you stopped: " + sl0)); }
      } else if (live) {
        var a = setsOf(idx, ps);''')
rep('''      fb.addEventListener("click", function () {
        var chk = wk && wk.rec ? workoutFixes(exList, wk.rec, p)''', '''      endNow = finishNow;
      fb.addEventListener("click", function () {
        var chk = wk && wk.rec ? workoutFixes(exList, wk.rec, p)''')

rep('kind === "before" ? "Your plan starts " + longDate(p.start) + "." :', 'kind === "before" ? (wf.hold ? "Your plan is on hold. Talk with your clinician first." : "Your plan starts " + longDate(p.start) + ".") :', 2)
rep('if (wf.kind === "before") return { t: "Plan starts "', 'if (wf.kind === "before" && wf.hold) return { t: "Plan on hold", s: "" };\n    if (wf.kind === "before") return { t: "Plan starts "')
open(S + 'v256/app-v256.html', 'w', encoding='utf-8').write(src)
print('ok', len(src))
