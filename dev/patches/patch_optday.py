#!/usr/bin/env python3
"""Optional 4th day: the Workout box no longer costs a man for resting. On that day, tapping the box offers three
choices: do the optional workout (+1 bonus when finished), I did my own recovery (one honest tap, optional note), or
full rest. Any of them checks the Workout box (3 pts, streak safe). Logging his own workout that day also checks it.
Works whether the 4th day is on (optional workout) or off (rest day). Decided by Curtis 2026-10-31 (option B).
Usage: patch_optday.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- the day record carries his choice and the bonus
rep('return { date: x.date, uid: x.uid, done: x.done || {}, prs: normPrs(p), steps: normSteps(x.steps), pbonus: !!x.pbonus, fast: !!x.fast }; }));',
    'return { date: x.date, uid: x.uid, done: x.done || {}, prs: normPrs(p), steps: normSteps(x.steps), pbonus: !!x.pbonus, fast: !!x.fast, opt: normOpt(x.opt), onote: String(x.onote || "").slice(0, 140), obonus: !!x.obonus }; }));')
rep('steps: normSteps(rec.steps), pbonus: !!rec.pbonus, fast: !!rec.fast }); },',
    'steps: normSteps(rec.steps), pbonus: !!rec.pbonus, fast: !!rec.fast, opt: normOpt(rec.opt), onote: String(rec.onote || "").slice(0, 140), obonus: !!rec.obonus }); },')
rep('    var cp = normPrs(cur.prs), rec = { date: date, uid: uid, done: {}, prs: cp, steps: normSteps(cur.steps), pbonus: !!cur.pbonus };',
    '    var cp = normPrs(cur.prs), rec = { date: date, uid: uid, done: {}, prs: cp, steps: normSteps(cur.steps), pbonus: !!cur.pbonus, opt: normOpt(cur.opt), onote: String(cur.onote || ""), obonus: !!cur.obonus };')
# ---- points
rep('  function bonusOf(rec) { var p = rec.prs || {}; return (Number(p.n) || 0) * PR_PTS + stepBonus(rec.steps) + (rec.pbonus ? PROTEIN_BONUS : 0); }',
    '''  var OPT_BONUS = 1; // finishing the optional 4th-day workout
  function normOpt(v) { return v === "own" || v === "rest" ? v : ""; }
  function bonusOf(rec) { var p = rec.prs || {}; return (Number(p.n) || 0) * PR_PTS + stepBonus(rec.steps) + (rec.pbonus ? PROTEIN_BONUS : 0) + (rec.obonus ? OPT_BONUS : 0); }''')
rep('    var t = { boxes: 0, habits: 0, steps: 0, protein: 0, prs: 0 }, prList = [];', '    var t = { boxes: 0, habits: 0, steps: 0, protein: 0, prs: 0, opt: 0 }, prList = [];')
rep('t.protein += c.pbonus ? PROTEIN_BONUS : 0;', 't.protein += c.pbonus ? PROTEIN_BONUS : 0; t.opt += c.obonus ? OPT_BONUS : 0;')
rep('    var kw = t.boxes + t.habits + t.steps + t.protein + t.prs + rcPts;', '    var kw = t.boxes + t.habits + t.steps + t.protein + t.prs + t.opt + rcPts;')
rep('["Protein bonus", t.protein], ["PRs', '["Protein bonus", t.protein], ["Optional workout bonus", t.opt], ["PRs')

FN = r'''  /* ---------- Optional 4th day: workout, his own recovery, or full rest. Any of them checks the Workout box. ---------- */
  function isOptDay(key) { var wf = workoutFor(key); return !!(wf && !wf.rt && wf.w && wf.w.templateDay === 6 && (wf.kind === "off" || wf.kind === "train")); }
  function setOptChoice(v, note) {
    writeDay(function (r) { r.opt = normOpt(v); r.onote = v === "own" ? String(note || "").trim().slice(0, 140) : ""; var hk = taskOfKind("workout"); if (hk && !v && !r.obonus) delete r.done[hk.id]; });
  }
  function openOptDay() {
    var k = todayKey(), wf = workoutFor(k), rec = recFor(k), cur = normOpt(rec.opt), off = !state.me || !state.canWrite;
    var old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box gb-box od-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "od-t");
    var hd = el("div", "vd-coach"), bd = el("span", "vd-badge"); bd.innerHTML = GIDEON_BADGE; hd.appendChild(bd);
    var nm = el("span"); nm.appendChild(el("b", null, COACH_LABEL)); nm.appendChild(el("small", null, "Your optional day")); hd.appendChild(nm); box.appendChild(hd);
    var h = el("h2", "fm-h", "The 4th day is yours."); h.id = "od-t"; box.appendChild(h);
    box.appendChild(el("p", "od-lead", "Any of these checks your Workout box. Finish the optional workout and you earn +" + OPT_BONUS + " bonus on top."));
    function card(key, title, sub, extra) {
      var c = el("div", "od-card" + (key && key === cur ? " on" : ""));
      var b = el("button", "od-pick"); b.type = "button"; b.disabled = off; b.appendChild(el("span", "fm-dot"));
      var tx = el("span", "fm-tx"); tx.appendChild(el("b", null, title)); tx.appendChild(el("span", null, sub)); b.appendChild(tx); c.appendChild(b);
      if (extra) c.appendChild(extra); box.appendChild(c); return b;
    }
    var hasW = wf && wf.kind === "train";
    var b1 = card("", "Do the optional workout", hasW ? wf.w.title.replace(/^Optional:\s*/, "") + " · " + (wf.w.minutes || 45) + " min · +" + OPT_BONUS + " bonus when you finish" : "Your plan has the 4th day off. Turn it on in Train › Workout plan to get a workout here.");
    if (!hasW) b1.disabled = true;
    b1.addEventListener("click", function () { back.remove(); openWorkout(k); });
    var nw = el("label", "od-note"); nw.appendChild(el("span", null, "What did you do? (optional)")); var ni = el("input", "field"); ni.type = "text"; ni.maxLength = 140; ni.placeholder = "Walk, stretch, mobility, ruck, a game of ball"; ni.value = cur === "own" ? rec.onote || "" : ""; ni.disabled = off; nw.appendChild(ni);
    var b2 = card("own", "I did my own recovery", "On your honor. Checks your Workout box.", nw);
    b2.addEventListener("click", function () { back.remove(); setOptChoice("own", ni.value); });
    var b3 = card("rest", "Full rest today", "Rest is part of the training. Sleep, eat well, be with your family.");
    b3.addEventListener("click", function () { back.remove(); setOptChoice("rest"); });
    if (cur && !rec.obonus) { var clr = el("button", "btn ghost", "Clear my choice"); clr.type = "button"; clr.disabled = off; clr.addEventListener("click", function () { back.remove(); setOptChoice(""); }); box.appendChild(clr); }
    var no = el("button", "btn ghost", "Close"); no.type = "button"; box.appendChild(no);
    function close() { back.remove(); }
    no.addEventListener("click", close);
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back); no.focus({ preventScroll: true });
  }
'''
rep('  function derive(rec, log) {', FN + '  function derive(rec, log) {\n    var hko = taskOfKind("workout"); if (hko && isOptDay(rec.date) && (normOpt(rec.opt) || rec.obonus)) rec.done[hko.id] = true;')

# ---- finishing on the optional day: the bonus, and his own workout counts too
rep('''        if (wk && wk.rec) { wkFoldPause(wk.rec); wk.rec.finishedAt = Date.now(); } saveWkNow(); if (!S) { var wt = taskOfKind("workout"); if (wt && !recFor(key).done[wt.id]) previewWorkout(); } drawWorkoutPage(true);''',
    '''        if (wk && wk.rec) { wkFoldPause(wk.rec); wk.rec.finishedAt = Date.now(); } saveWkNow();
        if (key === todayKey() && isOptDay(key)) { var nmS = S && wk && wk.rec ? wk.rec.name : ""; writeDay(function (r) { var hk2 = taskOfKind("workout"); if (hk2) r.done[hk2.id] = true; if (!S) { r.obonus = true; r.opt = ""; r.onote = ""; } else if (!r.obonus) { r.opt = "own"; r.onote = String(nmS || "My own workout").slice(0, 140); } }); }
        else if (!S) { var wt = taskOfKind("workout"); if (wt && !recFor(key).done[wt.id]) previewWorkout(); }
        drawWorkoutPage(true);''')

# ---- Today: the Workout box on the optional day opens the choices
rep('      var isDevo = tk.kind === "devo", fmOwn =', '      var optD = tk.kind === "workout" && isOptDay(todayKey()) && !isWeighDay(todayKey());\n      var isDevo = tk.kind === "devo", fmOwn =')
rep('page = fmOwn && !fmExt ? null : AUTO_PAGE[tk.kind];', 'page = (fmOwn && !fmExt) || optD ? null : AUTO_PAGE[tk.kind];')
rep('''      else if (tk.kind === "workout") sub = isWeighDay(todayKey()) ? SABBATH_REST''',
    '''      else if (optD) { var orc = recFor(todayKey()); sub = orc.obonus ? "Optional workout done. +" + OPT_BONUS + " bonus" : orc.opt === "own" ? "Own recovery" + (orc.onote ? ": " + orc.onote : "") + ". Tap to change" : orc.opt === "rest" ? "Full rest today. Tap to change" : "Optional day. Tap to choose: workout, your own recovery or rest"; }
      else if (tk.kind === "workout") sub = isWeighDay(todayKey()) ? SABBATH_REST''')
rep('''      if (tk.kind === "photos" || (tk.kind === "steps" && !hAuto) || (tk.kind === "weigh" && !hAuto)) b.appendChild(el("span", "chev", "\\u203A"));''',
    '''      if (tk.kind === "photos" || (tk.kind === "steps" && !hAuto) || (tk.kind === "weigh" && !hAuto) || (optD && !recFor(todayKey()).obonus)) b.appendChild(el("span", "chev", "\\u203A"));
      if (optD) { b.removeAttribute("aria-readonly"); b.classList.remove("auto"); b.disabled = !state.me || !state.canWrite; b.setAttribute("aria-haspopup", "dialog"); }''')
rep('      b.addEventListener("click", function () { if (isDevo) openDevo();', '      b.addEventListener("click", function () { if (optD) { if (!recFor(todayKey()).obonus) openOptDay(); return; } if (isDevo) openDevo();')

# ---- Train: the same choice on that day's card
rep('''        ob.addEventListener("click", function () { openWorkout(sel); }); box.appendChild(ob);
      } else {''', '''        ob.addEventListener("click", function () { openWorkout(sel); }); box.appendChild(ob);
        if (isToday && isOptDay(sel) && !off) { var orb = el("button", "btn ghost od-alt", "Rest or own recovery instead"); orb.type = "button"; orb.addEventListener("click", openOptDay); box.appendChild(orb); }
      } else {''')
rep('''        box.appendChild(el("p", "note", msg0));
      }''', '''        box.appendChild(el("p", "note", msg0));
        if (isToday && isOptDay(sel) && !off) { var orb2 = el("button", "btn ghost od-alt", "Log rest or own recovery"); orb2.type = "button"; orb2.addEventListener("click", openOptDay); box.appendChild(orb2); }
      }''')
rep('.fm-box .btn { width: 100%; margin-top: 8px; }', '''.fm-box .btn { width: 100%; margin-top: 8px; }
.od-box .btn { width: 100%; margin-top: 8px; }
.od-lead { margin: 0 0 10px; font-size: 15px; color: var(--muted); }
.od-card { border: 1px solid var(--line); border-radius: var(--radius, 4px); background: var(--surface); margin-bottom: 8px; }
.od-card.on { border-color: var(--accent); box-shadow: inset 3px 0 0 var(--accent); }
.od-card.on .fm-dot { border-color: var(--accent); background: radial-gradient(circle, var(--accent) 0 5px, transparent 6px); }
.od-pick { display: grid; grid-template-columns: 22px minmax(0, 1fr); gap: 12px; align-items: start; width: 100%; padding: 12px; text-align: left; font: inherit; color: var(--ink); background: none; border: 0; cursor: pointer; }
.od-pick:disabled { opacity: .55; cursor: default; }
.od-note { display: grid; gap: 4px; padding: 0 12px 12px 46px; font-size: 13px; color: var(--muted); }
.od-alt { width: 100%; margin-top: 8px; }''')
# a rest or recovery choice doesn't lock the optional workout: he can still do it for the bonus
rep('var done = S ? !!rec.finishedAt : !!((wkTask && recFor(key).done[wkTask.id]) || rec.finishedAt)',
    'var done = S ? !!rec.finishedAt : !!((wkTask && recFor(key).done[wkTask.id] && !(isOptDay(key) && normOpt(recFor(key).opt))) || rec.finishedAt)')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
