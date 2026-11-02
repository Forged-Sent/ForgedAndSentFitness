#!/usr/bin/env python3
"""How I track food: a setting with three choices. Track in the app (as today), I track somewhere else (one honest tap:
"Hit my calories"), or I don't count calories ("Fueled on purpose"). Same 1 point every way. Choosing one opens a
note from Coach Gideon on what it means before it is saved. Protein bonus only applies when tracking in the app.
Usage: patch_foodmode.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- loaded with the rest of his settings
rep('routine: normRoutine(st && st.routine) };', 'routine: normRoutine(st && st.routine), foodMode: st && (st.foodMode === "elsewhere" || st.foodMode === "none") ? st.foodMode : "app" };')
# ---- saved with the rest of his settings
rep('routine: state.settings.routine || null };', 'routine: state.settings.routine || null, foodMode: foodMode() };')

FN = r'''  /* How I track food: "app" (log in Fuel, box checks itself), "elsewhere" (one honest tap), "none" (no counting). */
  var FOOD_MODES = {
    app: { t: "Track in the app", s: "Log your food in Fuel. Your Calories box checks itself when you land in your range.", box: "Calories" },
    elsewhere: { t: "I track somewhere else", s: "MyFitnessPal, MacroFactor or another app. One honest tap when you hit your calories.", box: "Hit my calories" },
    none: { t: "I don't count calories", s: "No numbers. Check the box when you ate on purpose today.", box: "Fueled on purpose" }
  };
  function foodMode() { var m = (state.settings || {}).foodMode; return m === "elsewhere" || m === "none" ? m : "app"; }
  var FOOD_GIDEON = {
    elsewhere: { h: "You already track. Keep using what works.", p: [
      "Your Calories box becomes “Hit my calories.” Tap it on the days you land in your range, on your honor.",
      "Same 1 point. You lose nothing on the Board.",
      "The protein bonus needs your food logged here, so it is off while you track somewhere else.",
      "Fuel stays open. Log a meal here any time you want.",
      "The deal is honesty. Check it only on the days you actually hit it."] },
    none: { h: "Counting isn’t the only way to eat well.", p: [
      "Your Calories box becomes “Fueled on purpose.” Check it on the days you ate with intent: protein at every meal, real food, nothing mindless after dinner.",
      "Same 1 point. You lose nothing on the Board.",
      "No protein bonus, since there are no numbers to check.",
      "If counting has been unhealthy for you before, this is the right call. No explanation needed.",
      "If your weight stalls for a few weeks and you want to know why, count for two weeks. It is the fastest way to find the gap. Then come back here if you like."] },
    app: { h: "Back to logging in Fuel.", p: [
      "Your Calories box checks itself when your food log lands in your range.",
      "The protein bonus is back on: hit your protein and stay in range for +" + PROTEIN_BONUS + " points.",
      "You can switch again any time."] }
  };
  function openFoodMode(mode, after) {
    var old = $("cdlg"); if (old) old.remove();
    var g = FOOD_GIDEON[mode], back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box gb-box fm-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "fm-t");
    var hd = el("div", "vd-coach"), bd = el("span", "vd-badge"); bd.innerHTML = GIDEON_BADGE; hd.appendChild(bd);
    var nm = el("span"); nm.appendChild(el("b", null, COACH_LABEL)); nm.appendChild(el("small", null, FOOD_MODES[mode].t)); hd.appendChild(nm); box.appendChild(hd);
    var h = el("h2", "fm-h", g.h); h.id = "fm-t"; box.appendChild(h);
    var ul = el("ul", "fm-ul"); g.p.forEach(function (x) { ul.appendChild(el("li", null, x)); }); box.appendChild(ul);
    var prev = el("div", "fm-prev"); prev.appendChild(el("span", "fm-pk", "Your box on Today"));
    var pr = el("span", "fm-pr"); pr.appendChild(el("span", "fm-pb")); pr.appendChild(el("b", null, FOOD_MODES[mode].box)); pr.appendChild(el("i", null, "+1 pt")); prev.appendChild(pr); box.appendChild(prev);
    var ok = el("button", "btn", mode === "app" ? "Track in the app" : "Got it. Switch me"), no = el("button", "btn ghost", "Cancel"); ok.type = "button"; no.type = "button";
    box.appendChild(ok); box.appendChild(no);
    function close() { back.remove(); }
    no.addEventListener("click", close);
    ok.addEventListener("click", function () { close(); after(); });
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back); ok.focus({ preventScroll: true });
  }
  function setFoodMode(mode) {
    if (mode === foodMode()) return;
    openFoodMode(mode, function () {
      state.settings.foodMode = mode; saveSettings();
      if (state.me && state.canWrite) writeDay(function () { return false; }); else drawAll();
      drawFoodMode();
    });
  }
  function drawFoodMode() {
    var box = $("food-mode"); if (!box) return; box.textContent = ""; var cur = foodMode(), off = !state.me || !state.canWrite;
    Object.keys(FOOD_MODES).forEach(function (k) {
      var b = el("button", "fm-opt" + (k === cur ? " on" : "")); b.type = "button"; b.setAttribute("role", "radio"); b.setAttribute("aria-checked", String(k === cur)); b.disabled = off;
      b.appendChild(el("span", "fm-dot"));
      var tx = el("span", "fm-tx"); tx.appendChild(el("b", null, FOOD_MODES[k].t)); tx.appendChild(el("span", null, FOOD_MODES[k].s)); b.appendChild(tx);
      b.addEventListener("click", function () { setFoodMode(k); });
      box.appendChild(b);
    });
    var fn = $("fuel-mode-note");
    if (fn) { fn.hidden = cur === "app"; fn.textContent = ""; if (cur !== "app") { fn.appendChild(document.createTextNode(cur === "elsewhere" ? "You track food in another app. Logging here is optional. " : "You don’t count calories. Logging here is optional. ")); var ch = el("button", "linkish", "Change"); ch.type = "button"; ch.addEventListener("click", function () { openSettingsSection("h-s-food"); }); fn.appendChild(ch); } }
  }
'''
rep('  function derive(rec, log) {', FN + '  function derive(rec, log) {')
# derive: only auto-check calories (and the protein bonus) when he tracks in the app
rep('''    if (ct) { var cw = calWindow(tk); if (tk > 0 && log.kcal >= cw[0] && log.kcal <= cw[1]) rec.done[ct.id] = true; else delete rec.done[ct.id]; }''',
    '''    var fmApp = foodMode() === "app";
    if (ct && fmApp) { var cw = calWindow(tk); if (tk > 0 && log.kcal >= cw[0] && log.kcal <= cw[1]) rec.done[ct.id] = true; else delete rec.done[ct.id]; }''')
rep('''    rec.pbonus = !!(tk > 0 && tp > 0 && log.p >= tp && log.kcal >= cw2[0] && log.kcal <= cw2[1]);''',
    '''    rec.pbonus = !!(fmApp && tk > 0 && tp > 0 && log.p >= tp && log.kcal >= cw2[0] && log.kcal <= cw2[1]);''')
# Today: the box is his to tap when he does not track in the app
rep('      var isDevo = tk.kind === "devo", page = AUTO_PAGE[tk.kind];',
    '      var isDevo = tk.kind === "devo", fmOwn = tk.kind === "calories" && foodMode() !== "app" && !isFastDay(todayKey()), page = fmOwn ? null : AUTO_PAGE[tk.kind];')
rep('      var txt = el("span", "txt"), nm = el("span", "name", tk.title);',
    '      var txt = el("span", "txt"), nm = el("span", "name", tk.kind === "calories" && foodMode() !== "app" ? FOOD_MODES[foodMode()].box : tk.title);')
rep('''      else if (tk.kind === "calories") sub = t && Number(t.kcal)''',
    '''      else if (fmOwn) sub = foodMode() === "elsewhere" ? (done[tk.id] ? "Hit my range today" : "Tap when you land in your range today. On your honor") : (done[tk.id] ? "Ate on purpose today" : "Protein at every meal, real food, nothing mindless after dinner");
      else if (tk.kind === "calories") sub = t && Number(t.kcal)''')
# Settings section, before the targets
rep('''    <section aria-labelledby="h-s-tg">''', '''    <section aria-labelledby="h-s-food">
      <div class="section-head"><h2 class="label-caps" id="h-s-food" data-sub="Log in the app, use another app, or skip the numbers. Same points every way.">How I track food</h2></div>
      <div class="fm-opts" id="food-mode" role="radiogroup" aria-labelledby="h-s-food"></div>
    </section>

    <section aria-labelledby="h-s-tg">''')
rep('["h-s-wk", "h-s-body", "h-s-goal", "h-s-tg",', '["h-s-wk", "h-s-body", "h-s-goal", "h-s-food", "h-s-tg",')
# Fuel: a short line when he does not track here
rep('''      <div class="macros" id="macros"></div>''', '''      <p class="note fm-fuel" id="fuel-mode-note" hidden></p>
      <div class="macros" id="macros"></div>''')
rep('  function drawFuel() {\n    drawFast();', '  function drawFuel() {\n    drawFast(); drawFoodMode();')
rep('  function drawSettings() {\n    paintTestCtl(); drawInviteSettings();', '  function drawSettings() {\n    paintTestCtl(); drawInviteSettings(); drawFoodMode();')
rep('.gb-box { position: relative; max-height: 86vh; overflow-y: auto; }', '''.gb-box { position: relative; max-height: 86vh; overflow-y: auto; }
.fm-opts { display: grid; gap: 8px; }
.fm-opt { display: grid; grid-template-columns: 22px minmax(0, 1fr); gap: 12px; align-items: start; width: 100%; padding: 12px; text-align: left; font: inherit; color: var(--ink); background: var(--surface); border: 1px solid var(--line); border-radius: var(--radius, 4px); cursor: pointer; }
.fm-opt.on { border-color: var(--accent); box-shadow: inset 3px 0 0 var(--accent); }
.fm-dot { width: 20px; height: 20px; margin-top: 2px; border-radius: 50%; border: 2px solid var(--muted); }
.fm-opt.on .fm-dot { border-color: var(--accent); background: radial-gradient(circle, var(--accent) 0 5px, transparent 6px); }
.fm-tx { display: grid; gap: 3px; min-width: 0; }
.fm-tx b { font-family: var(--f-label); font-weight: 800; font-size: 16px; letter-spacing: .03em; text-transform: uppercase; }
.fm-tx span { font-size: 14px; line-height: 1.4; color: var(--muted); }
.fm-h { margin: 6px 0 6px; font-family: var(--f-display); font-size: 21px; line-height: 1.15; text-transform: uppercase; }
.fm-ul { margin: 0 0 12px; padding-left: 20px; display: grid; gap: 6px; }
.fm-ul li { font-size: 15px; line-height: 1.45; }
.fm-ul li::marker { color: var(--accent); }
.fm-prev { margin: 0 0 12px; padding: 10px 12px; border: 1px dashed var(--line); border-radius: var(--radius, 4px); }
.fm-pk { display: block; font-family: var(--f-label); font-weight: 700; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--muted); margin-bottom: 6px; }
.fm-pr { display: flex; align-items: center; gap: 10px; }
.fm-pb { width: 22px; height: 22px; border: 2px solid var(--line); border-radius: 4px; flex: none; }
.fm-pr b { flex: 1; font-size: 16px; } .fm-pr i { font-style: normal; font-weight: 700; color: var(--accent); }
.fm-box .btn { width: 100%; margin-top: 8px; }
.fm-fuel { border-left: 3px solid var(--accent); padding-left: 10px; }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
