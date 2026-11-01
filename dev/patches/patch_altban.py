#!/usr/bin/env python3
"""Optional 4th day: when a brother picks his own recovery or full rest, the workout shows a banner saying he did the
alternate (Train day view, the week list, and the workout page). Today's banner has a Change button. The workout is greyed out that day (still viewable);
"Switch to the workout" clears the choice after one confirm and brings back Start. Finishing the
optional workout instead still earns the +1 and replaces the banner.
Usage: patch_altban.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''  function openOptDay() {''', '''  function optAlt(key) { var r = recFor(key); return isOptDay(key) && !r.obonus ? normOpt(r.opt) : ""; }
  function altBanner(key, canChange) {
    var r = recFor(key), v = optAlt(key); if (!v) return null;
    var b = el("div", "alt-ban"), ic = el("span", "alt-ic"); ic.innerHTML = v === "rest" ? '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5Z"/></svg>' : '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12a8 8 0 0 1 13.7-5.6L20 8.7M20 4v4.7h-4.7M20 12a8 8 0 0 1-13.7 5.6L4 15.3M4 20v-4.7h4.7"/></svg>';
    b.appendChild(ic); var tx = el("span", "alt-tx");
    tx.appendChild(el("span", "label-caps alt-k", "Alternate day \u2713"));
    tx.appendChild(el("b", "alt-t", v === "rest" ? "Full rest" : "Own recovery"));
    tx.appendChild(el("span", "alt-s", v === "own" ? (r.onote ? r.onote + ". " : "You did your own recovery instead of the optional workout. ") + "Workout box checked." : "You took full rest instead of the optional workout. Workout box checked."));
    b.appendChild(tx);
    if (canChange) { var c = el("button", "mini", "Change"); c.type = "button"; c.disabled = !state.me || !state.canWrite; c.addEventListener("click", openOptDay); b.appendChild(c); }
    return b;
  }
  function openOptDay() {''')
# Train day view: banner replaces the "instead" button once he has chosen
rep('''        ob.addEventListener("click", function () { openWorkout(sel); }); box.appendChild(ob);
        if (isToday && isOptDay(sel) && !off) {''', '''        ob.addEventListener("click", function () { openWorkout(sel); }); var ab = altBanner(sel, isToday && !off); if (ab) box.appendChild(ab); box.appendChild(ob);
        if (isToday && isOptDay(sel) && !off && !ab) {''')
rep('''        box.appendChild(el("p", "note", msg0));
        if (isToday && isOptDay(sel) && !off) {''', '''        var ab2 = altBanner(sel, isToday && !off); if (ab2) box.appendChild(ab2); else box.appendChild(el("p", "note", msg0));
        if (isToday && isOptDay(sel) && !off && !ab2) {''')
# week list subtitle
rep('''(planSrc(key) !== key ? "Moved · " : "") + lb.s, done''', '''(planSrc(key) !== key ? "Moved · " : "") + (optAlt(key) ? "Alternate: " + (optAlt(key) === "rest" ? "full rest" : "own recovery") : lb.s), done''')
# workout page
rep('''    body.appendChild(el("h1", "pg", w.title));
    if (!S && !locked && th.brief)''', '''    body.appendChild(el("h1", "pg", w.title));
    if (!S && !rec.finishedAt) { var ab3 = altBanner(key, isToday && !off); if (ab3) { ab3.appendChild(el("span", "alt-foot", isToday ? "Want to train anyway? Finish this workout and it earns +" + OPT_BONUS + " bonus." : "")); body.appendChild(ab3); } }
    if (!S && !locked && th.brief)''')
rep('''.od-alt { width: 100%; margin-top: 8px; }''', '''.od-alt { width: 100%; margin-top: 8px; }
.alt-ban { display: grid; grid-template-columns: 40px minmax(0, 1fr) auto; gap: 12px; align-items: center; margin: 12px 0; padding: 12px; border: 1px solid var(--line); border-left: 3px solid var(--brass, var(--accent)); border-radius: 8px; background: var(--surface); }
.alt-ic { width: 40px; height: 40px; border-radius: 50%; display: grid; place-items: center; border: 1px solid var(--brass, var(--accent)); color: var(--brass, var(--accent)); }
.alt-ic svg { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
.alt-tx { display: grid; gap: 2px; min-width: 0; }
.alt-k { color: var(--brass, var(--accent)); font-size: 11.5px; }
.alt-t { font-family: var(--f-label); font-weight: 800; font-size: 18px; text-transform: uppercase; letter-spacing: .04em; }
.alt-s { font-size: 14px; color: var(--muted); overflow-wrap: anywhere; }
.alt-foot { grid-column: 1 / -1; font-size: 13.5px; color: var(--muted); }
.alt-foot:empty { display: none; }''')
rep('    st.textContent = done ? "Workout complete" :', '    st.textContent = done && optAlt(sel) ? (optAlt(sel) === "rest" ? "Alternate day: full rest" : "Alternate day: own recovery") : done ? "Workout complete" :')
# ---- v217b: grey out the workout on an alternate day; switching back takes one confirm
rep('''        var ob = chevRow("wk-open", wf.w.title, wf.w.sessionType + (wf.w.minutes ? " \\u00B7 " + wf.w.minutes + " min" : "") + " \\u00B7 Tap to open", "\\u203A");''',
'''        var altNow = optAlt(sel), ob = chevRow("wk-open" + (altNow ? " alt-off" : ""), wf.w.title, altNow ? "Skipped \\u00B7 alternate day \\u00B7 Tap to view" : wf.w.sessionType + (wf.w.minutes ? " \\u00B7 " + wf.w.minutes + " min" : "") + " \\u00B7 Tap to open", "\\u203A");''')
rep('''    if (!S && !rec.finishedAt) { var ab3 = altBanner(key, isToday && !off); if (ab3) { ab3.appendChild(el("span", "alt-foot", isToday ? "Want to train anyway? Finish this workout and it earns +" + OPT_BONUS + " bonus." : "")); body.appendChild(ab3); } }''',
'''    var altW = !S && !rec.finishedAt && !rec.startedAt ? optAlt(key) : ""; body.classList.toggle("alt-on", !!altW);
    if (altW) {
      var ab3 = altBanner(key, isToday && !off); body.appendChild(ab3);
      if (isToday) {
        var swb = el("button", "btn ghost wk-switch", "Switch to the workout"); swb.type = "button"; swb.disabled = off;
        swb.addEventListener("click", function () { confirmDelete({ neutral: true, title: "Train instead?", message: "This clears your " + (altW === "rest" ? "full rest" : "own recovery") + " for today. Finish the workout and it checks your Workout box with +" + OPT_BONUS + " bonus.", yes: "Train instead" }, function () { setOptChoice(""); setTimeout(function () { drawWorkoutPage(true); }, 50); }); });
        body.appendChild(swb);
      }
    }''')
rep('''    if (isToday && !started && !done) { var sb = el("button", "btn wk-start", "Start workout");''', '''    if (isToday && !started && !done && !altW) { var sb = el("button", "btn wk-start", "Start workout");''')
rep('''.alt-foot:empty { display: none; }''', '''.alt-foot:empty { display: none; }
.wk-open.alt-off { opacity: .55; border-color: var(--line); }
.wk-open.alt-off .wo-c { color: var(--muted); }
.wk-switch { width: 100%; margin: 0 0 12px; }
#wkp-body.alt-on > :not(.alt-ban):not(.wk-switch):not(.wk-meta):not(h1) { opacity: .5; }''')
# picking "Do the optional workout" in the 4th-day sheet is an explicit choice: clear rest/own recovery first
rep('''b1.addEventListener("click", function () { back.remove(); openWorkout(k); });''', '''b1.addEventListener("click", function () { back.remove(); if (cur && !rec.obonus) setOptChoice(""); openWorkout(k); });''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
