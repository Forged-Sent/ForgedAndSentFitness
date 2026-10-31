#!/usr/bin/env python3
"""How I track food, part 2: in first-time setup (Your goal step, with Coach Gideon's note shown inline), in the
Fuel and Today info bubbles (current choice + Change), and a simpler Fuel screen when he opts out: his box and what
it means on top, Water and Fasting as normal, and the macro bars, food log and 7-day chart folded behind
"Log food here anyway". Usage: patch_foodmode2.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

FN = r'''  /* Shared: the three choices as radio cards (Settings, setup, the Change picker). */
  function foodModeCards(cur, onPick, off) {
    var box = el("div", "fm-opts"); box.setAttribute("role", "radiogroup"); box.setAttribute("aria-label", "How I track food");
    Object.keys(FOOD_MODES).forEach(function (k) {
      var b = el("button", "fm-opt" + (k === cur ? " on" : "")); b.type = "button"; b.setAttribute("role", "radio"); b.setAttribute("aria-checked", String(k === cur)); b.disabled = !!off;
      b.appendChild(el("span", "fm-dot"));
      var tx = el("span", "fm-tx"); tx.appendChild(el("b", null, FOOD_MODES[k].t)); tx.appendChild(el("span", null, FOOD_MODES[k].s)); b.appendChild(tx);
      b.addEventListener("click", function () { onPick(k); }); box.appendChild(b);
    });
    return box;
  }
  /* Coach Gideon's note as a card (used inline in setup). */
  function foodGideonCard(mode) {
    var g = FOOD_GIDEON[mode], c = el("div", "fm-gcard");
    var hd = el("div", "vd-coach"), bd = el("span", "vd-badge"); bd.innerHTML = GIDEON_BADGE; hd.appendChild(bd);
    var nm = el("span"); nm.appendChild(el("b", null, COACH_LABEL)); nm.appendChild(el("small", null, FOOD_MODES[mode].t)); hd.appendChild(nm); c.appendChild(hd);
    c.appendChild(el("p", "fm-gh", g.h));
    var ul = el("ul", "fm-ul"); g.p.forEach(function (x) { ul.appendChild(el("li", null, x)); }); c.appendChild(ul);
    return c;
  }
  function openFoodModePicker() {
    var old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box gb-box fm-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "fmp-t");
    var hd = el("div", "vd-coach"), bd = el("span", "vd-badge"); bd.innerHTML = GIDEON_BADGE; hd.appendChild(bd);
    var nm = el("span"); nm.appendChild(el("b", null, COACH_LABEL)); nm.appendChild(el("small", null, "Same points every way")); hd.appendChild(nm); box.appendChild(hd);
    var h = el("h2", "fm-h", "How do you track food?"); h.id = "fmp-t"; box.appendChild(h);
    box.appendChild(foodModeCards(foodMode(), function (k) { back.remove(); if (k !== foodMode()) setFoodMode(k); }, !state.me || !state.canWrite));
    var no = el("button", "btn ghost", "Close"); no.type = "button"; box.appendChild(no);
    function close() { back.remove(); }
    no.addEventListener("click", close);
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back); no.focus({ preventScroll: true });
  }
  var fuelShowLog = false;
  /* Fuel when he doesn't track in the app: his box on top, the logging tools folded away. */
  function drawFuelMode() {
    var mode = foodMode(), own = mode !== "app", card = $("fm-fuel-card");
    ["h-macros", "h-food", "h-seven"].forEach(function (hid) { var h = $(hid), sec = h && h.closest("section"); if (sec) sec.hidden = own && !fuelShowLog; });
    var more = $("fm-fuel-more"); if (more) { more.hidden = !own; more.textContent = fuelShowLog ? "Hide the food log" : "Log food here anyway"; }
    if (!card) return; card.hidden = !own; card.textContent = ""; if (!own) return;
    var ct = taskOfKind("calories"), done = ct && myDoc().done[ct.id], fast = isFastDay(todayKey());
    card.appendChild(el("div", "label-caps fmc-k", mode === "elsewhere" ? "You track in another app" : "You don’t count calories"));
    var b = el("button", "fmc-box" + (done ? " on" : "")); b.type = "button"; b.setAttribute("role", "checkbox"); b.setAttribute("aria-checked", String(!!done));
    b.disabled = fast || !ct || !state.me || !state.canWrite;
    var bx = el("span", "box"); bx.innerHTML = CHECK_SVG; b.appendChild(bx);
    var tx = el("span", "fmc-t"); tx.appendChild(el("b", null, FOOD_MODES[mode].box));
    tx.appendChild(el("span", null, fast ? "Fasting today. Checked for you." : mode === "elsewhere" ? "Tap when you land in your range today. On your honor." : "Tap when you ate on purpose today."));
    b.appendChild(tx); b.appendChild(el("i", "fmc-pts", "+" + (ct ? ct.points : 1) + " pt"));
    b.addEventListener("click", function () { if (ct) toggle(ct.id); });
    card.appendChild(b);
    if (mode === "none") {
      var ul = el("ul", "fmc-ul"); ["Protein at every meal", "Real food, mostly from the ground or an animal", "Nothing mindless after dinner"].forEach(function (x) { ul.appendChild(el("li", null, x)); }); card.appendChild(ul);
    } else card.appendChild(el("p", "note fmc-n", "Your targets are in Settings if you want them handy: " + (function () { var t = targets(); return t && Number(t.kcal) ? fmt(Number(t.kcal)) + " kcal, " + fmt(Number(t.p) || 0) + " g protein." : "none set yet."; })()));
    var ch = el("button", "linkish", "Change how I track food"); ch.type = "button"; ch.addEventListener("click", openFoodModePicker); card.appendChild(ch);
  }
'''
rep('  function drawFoodMode() {', FN + '  function drawFoodMode() {')
# Fuel: the card and the fold toggle; the old one-line note gives way to the card
rep('''      <p class="note fm-fuel" id="fuel-mode-note" hidden></p>
      <div class="macros" id="macros"></div>''', '''      <div class="macros" id="macros"></div>''')
rep('''    <section aria-labelledby="h-macros">''', '''    <section class="fm-fuel-card" id="fm-fuel-card" aria-label="Your Calories box" hidden></section>
    <section aria-labelledby="h-macros">''')
rep('''    <section aria-labelledby="h-water">''', '''    <section aria-labelledby="h-water">''')
rep('  function drawFuel() {\n    drawFast(); drawFoodMode();', '  function drawFuel() {\n    drawFast(); drawFoodMode(); drawFuelMode();')
# a fold button below Fasting
rep('''    <section aria-labelledby="h-food">''', '''    <button class="btn ghost fm-more" type="button" id="fm-fuel-more" hidden>Log food here anyway</button>
    <section aria-labelledby="h-food">''')
rep('    $("adj-targets").addEventListener("click", function () { openSettingsSection("h-s-tg"); });',
    '    $("adj-targets").addEventListener("click", function () { openSettingsSection("h-s-tg"); });\n    $("fm-fuel-more").addEventListener("click", function () { fuelShowLog = !fuelShowLog; drawFuelMode(); });')
# settings list uses the shared cards
rep('''    var box = $("food-mode"); if (!box) return; box.textContent = ""; var cur = foodMode(), off = !state.me || !state.canWrite;
    Object.keys(FOOD_MODES).forEach(function (k) {
      var b = el("button", "fm-opt" + (k === cur ? " on" : "")); b.type = "button"; b.setAttribute("role", "radio"); b.setAttribute("aria-checked", String(k === cur)); b.disabled = off;
      b.appendChild(el("span", "fm-dot"));
      var tx = el("span", "fm-tx"); tx.appendChild(el("b", null, FOOD_MODES[k].t)); tx.appendChild(el("span", null, FOOD_MODES[k].s)); b.appendChild(tx);
      b.addEventListener("click", function () { setFoodMode(k); });
      box.appendChild(b);
    });''', '''    var box = $("food-mode"); if (box) { box.textContent = ""; var cards = foodModeCards(foodMode(), setFoodMode, !state.me || !state.canWrite); while (cards.firstChild) box.appendChild(cards.firstChild); }''')
rep('''    var fn = $("fuel-mode-note");''', '''    if (state.page === "fuel") drawFuelMode();
    var fn = null;''')

# ---- info bubbles (Fuel and Today): current choice and Change
rep('''    var ul = el("ul", "help-list"); h.how.forEach''', '''    if (page === "fuel" || page === "today") {
      var fmr = el("div", "help-fm"), fml = el("span"); fml.appendChild(document.createTextNode("How you track food: ")); fml.appendChild(el("b", null, FOOD_MODES[foodMode()].t)); fmr.appendChild(fml);
      var fmb = el("button", "mini", "Change"); fmb.type = "button"; fmb.addEventListener("click", function () { back.remove(); openFoodModePicker(); }); fmr.appendChild(fmb);
      fmr.appendChild(el("p", null, foodMode() === "app" ? "Already tracking in another app, or don’t want to count? Change it here. Same points every way." : "Your Calories box is “" + FOOD_MODES[foodMode()].box + ".” Tap it on Today or Fuel. Same points as logging here."));
      box.appendChild(fmr);
    }
    var ul = el("ul", "help-list"); h.how.forEach''')
# Fuel tip changes when he opts out
rep('''    fuel: { t: "Fuel", why: "Track what you eat and drink against your daily calorie and macro targets.", tip: function () {
''', '''    fuel: { t: "Fuel", why: "Track what you eat and drink against your daily calorie and macro targets.", tip: function () {
      if (foodMode() !== "app") { var wk3 = taskOfKind("water"); return "Points on Fuel: your " + FOOD_MODES[foodMode()].box + " box (+1) is yours to tap, on your honor. Water at your goal checks your Water box (+" + (wk3 ? wk3.points : 1) + "). The food log is still here under Log food here anyway."; }
''')

# ---- first-time setup: inside Your goal
rep('''      var tk = el("div", "tk-card"); tk.appendChild(el("div", "onb-k", "What tracking is for"));''',
    '''      if (!d.foodMode) d.foodMode = foodMode();
      var fw = el("div", "onb-f"); fw.appendChild(el("span", "onb-lbl", "How you’ll track food"));
      fw.appendChild(el("p", "onb-note", "Already dialed in with another app, or don’t want to count? Pick what fits. Same points every way."));
      fw.appendChild(foodModeCards(d.foodMode, function (k) { d.foodMode = k; drawOnb(); }, false));
      if (d.foodMode !== "app") fw.appendChild(foodGideonCard(d.foodMode));
      body.appendChild(fw);
      var tk = el("div", "tk-card"); tk.appendChild(el("div", "onb-k", "What tracking is for"));''')
rep('''        if (plan) { state.settings.targets = { kcal: plan.kcal, p: plan.p, f: plan.f, c: plan.c }; ONB.done.goal = true; }''',
    '''        if (plan) { state.settings.targets = { kcal: plan.kcal, p: plan.p, f: plan.f, c: plan.c }; ONB.done.goal = true; }
        state.settings.foodMode = d.foodMode === "elsewhere" || d.foodMode === "none" ? d.foodMode : "app";''')

rep('.fm-fuel { border-left: 3px solid var(--accent); padding-left: 10px; }', '''.fm-fuel-card { border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: var(--radius, 4px); background: var(--surface); padding: 12px; display: grid; gap: 10px; }
.fmc-k { color: var(--muted); font-size: 12px; }
.fmc-box { display: grid; grid-template-columns: 30px minmax(0, 1fr) auto; gap: 12px; align-items: center; width: 100%; padding: 10px; text-align: left; font: inherit; color: var(--ink); background: var(--bg); border: 1px solid var(--line); border-radius: var(--radius, 4px); cursor: pointer; }
.fmc-box .box { width: 28px; height: 28px; border: 2px solid var(--line); border-radius: 5px; display: grid; place-items: center; }
.fmc-box .box svg { width: 18px; height: 18px; opacity: 0; }
.fmc-box.on .box { background: var(--accent); border-color: var(--accent); } .fmc-box.on .box svg { opacity: 1; }
.fmc-t { display: grid; gap: 2px; min-width: 0; } .fmc-t b { font-size: 17px; } .fmc-t span { font-size: 13.5px; color: var(--muted); }
.fmc-pts { font-style: normal; font-weight: 700; color: var(--accent); }
.fmc-ul { margin: 0; padding-left: 20px; list-style: disc outside; display: grid; gap: 4px; font-size: 15px; } .fmc-ul li { display: list-item; } .fmc-ul li::marker { color: var(--accent); }
.fmc-n { margin: 0; }
.fm-more { width: 100%; margin: 4px 0 8px; }
.fm-gcard { margin-top: 10px; padding: 12px; border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: var(--radius, 4px); background: var(--surface); }
.fm-gh { margin: 4px 0 6px; font-weight: 700; }
.onb .fm-opt { background: var(--surface); }
.help-fm { margin: 10px 0 4px; padding: 10px 12px; border: 1px solid var(--line); border-radius: var(--radius, 4px); display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 6px 10px; }
.help-fm p { flex-basis: 100%; margin: 0; font-size: 13.5px; color: var(--muted); }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
