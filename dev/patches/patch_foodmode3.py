#!/usr/bin/env python3
"""How I track food, part 3: a man who tracks in another app can type today's totals from it (calories and protein).
With totals in, his box checks itself when he lands in his range and the protein bonus works like logging here.
Without totals, the one honest tap still works. Totals are saved on his private day log (ext).
Usage: patch_foodmode3.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- the day log carries his outside totals
rep('return { date: x.date || d.id, water: Number(x.water) || 0, kcal: Number(x.kcal) || 0, p: Number(x.p) || 0, f: Number(x.f) || 0, c: Number(x.c) || 0, meals: meals }; }));',
    'return { date: x.date || d.id, water: Number(x.water) || 0, kcal: Number(x.kcal) || 0, p: Number(x.p) || 0, f: Number(x.f) || 0, c: Number(x.c) || 0, meals: meals, ext: normExt(x.ext) }; }));')
rep('    var log = { date: date, water: cl.water, kcal: cl.kcal, p: cl.p, f: cl.f, c: cl.c, meals: cloneMeals(cl.meals) };',
    '    var log = { date: date, water: cl.water, kcal: cl.kcal, p: cl.p, f: cl.f, c: cl.c, meals: cloneMeals(cl.meals), ext: normExt(cl.ext) };')
rep('  function logFor(key) {', '''  function normExt(x) { if (!x || typeof x !== "object") return null; var k = Math.round(Number(x.kcal) || 0), p = Math.round(Number(x.p) || 0); return k > 0 && k < 15000 ? { kcal: k, p: Math.max(0, Math.min(1000, p)), at: Number(x.at) || 0 } : null; }
  function logFor(key) {''')

# ---- derive: totals from his other app count like logged food
rep('''    var fmApp = foodMode() === "app";''', '''    var fmApp = foodMode() === "app", ext = foodMode() === "elsewhere" ? normExt(log.ext) : null;
    if (ext) { log = { kcal: ext.kcal, p: ext.p }; fmApp = true; }''')

# ---- Today sub-line when totals are in
rep('''      else if (fmOwn) sub = foodMode() === "elsewhere" ? (done[tk.id] ? "Hit my range today" : "Tap when you land in your range today. On your honor")''',
    '''      else if (fmOwn && foodMode() === "elsewhere" && normExt(log.ext)) sub = (function () { var e = normExt(log.ext), w = calWindow(Number((t || {}).kcal) || 0); return fmt(e.kcal) + " kcal, " + fmt(e.p) + " g protein from your app" + (done[tk.id] ? ". In range" : ". Range " + fmt(w[0]) + "\\u2013" + fmt(w[1])) + (recFor(todayKey()).pbonus ? ". Protein bonus +" + PROTEIN_BONUS : ""); })();
      else if (fmOwn) sub = foodMode() === "elsewhere" ? (done[tk.id] ? "Hit my range today" : "Tap when you land in your range today. On your honor")''')
# with totals in, the box is the app's to check (like logging here)
rep('      var isDevo = tk.kind === "devo", fmOwn = tk.kind === "calories" && foodMode() !== "app" && !isFastDay(todayKey()), page = fmOwn ? null : AUTO_PAGE[tk.kind];',
    '      var isDevo = tk.kind === "devo", fmOwn = tk.kind === "calories" && foodMode() !== "app" && !isFastDay(todayKey()), fmExt = fmOwn && foodMode() === "elsewhere" && !!normExt(log.ext), page = fmOwn && !fmExt ? null : AUTO_PAGE[tk.kind];')

# ---- Fuel card: optional totals form for "elsewhere"
rep('''    } else card.appendChild(el("p", "note fmc-n", "Your targets are in Settings if you want them handy: " + (function () { var t = targets(); return t && Number(t.kcal) ? fmt(Number(t.kcal)) + " kcal, " + fmt(Number(t.p) || 0) + " g protein." : "none set yet."; })()));''',
    '''    } else drawExtTotals(card, b);''')
rep('  var fuelShowLog = false;', r'''  var fuelShowLog = false;
  /* Today's totals from his other app: two numbers, and the box and protein bonus work like logging here. */
  function drawExtTotals(card, boxBtn) {
    var t = targets(), tk = t ? Number(t.kcal) || 0 : 0, tp = t ? Number(t.p) || 0 : 0, w = calWindow(tk), ext = normExt(logFor(todayKey()).ext), off = !state.me || !state.canWrite;
    var f = el("form", "fmx"); f.noValidate = true;
    f.appendChild(el("div", "fmx-h", ext ? "Today’s totals from your app" : "Or enter today’s totals from your app (optional)"));
    f.appendChild(el("p", "fmx-n", tk ? "Your range is " + fmt(w[0]) + "–" + fmt(w[1]) + " kcal" + (tp ? " and protein " + fmt(tp) + " g" : "") + ". With totals in, the box checks itself and the protein bonus (+" + PROTEIN_BONUS + ") counts." : "Set your targets in Settings to see your range."));
    var row = el("div", "fmx-row");
    function fld(lbl, id, val, unit) { var l = el("label", "fmx-f"); l.appendChild(el("span", null, lbl)); var w2 = el("span", "fmx-in"); var i = el("input", "field"); i.type = "number"; i.id = id; i.min = "0"; i.inputMode = "numeric"; i.value = val || ""; i.disabled = off; w2.appendChild(i); w2.appendChild(el("i", null, unit)); l.appendChild(w2); row.appendChild(l); return i; }
    var ik = fld("Calories", "fmx-k", ext ? ext.kcal : "", "kcal"), ip = fld("Protein", "fmx-p", ext ? ext.p : "", "g");
    f.appendChild(row);
    var acts = el("div", "fmx-acts"), sv = el("button", "btn", ext ? "Update" : "Save totals"); sv.type = "submit"; sv.disabled = off; acts.appendChild(sv);
    if (ext) { var clr = el("button", "btn ghost", "Clear"); clr.type = "button"; clr.disabled = off; clr.addEventListener("click", function () { writeDay(function (r, l) { l.ext = null; var ct = taskOfKind("calories"); if (ct) delete r.done[ct.id]; return true; }); }); acts.appendChild(clr); }
    f.appendChild(acts);
    var err = el("p", "error"); err.hidden = true; f.appendChild(err);
    f.addEventListener("submit", function (ev) {
      ev.preventDefault(); var k = Math.round(Number(ik.value) || 0), p = Math.round(Number(ip.value) || 0);
      if (!(k > 0 && k < 15000)) { err.textContent = "Enter today’s calories from your app."; err.hidden = false; return; }
      writeDay(function (r, l) { l.ext = { kcal: k, p: p, at: Date.now() }; return true; });
    });
    if (ext) { boxBtn.disabled = true; boxBtn.classList.add("ext"); var sp = boxBtn.querySelector(".fmc-t span"); if (sp) sp.textContent = fmt(ext.kcal) + " kcal, " + fmt(ext.p) + " g protein from your app. " + (myDoc().done[(taskOfKind("calories") || {}).id] ? "In range." : "Not in range yet.") + (recFor(todayKey()).pbonus ? " Protein bonus +" + PROTEIN_BONUS + "." : ""); }
    card.appendChild(f);
  }
''')
# Gideon's note for "elsewhere" now mentions the totals
rep('''      "The protein bonus needs your food logged here, so it is off while you track somewhere else.",''',
    '''      "Want the protein bonus too? Type today’s calories and protein from your app on Fuel. With totals in, the box checks itself and the bonus counts.",''')
rep('''    elsewhere: { t: "I track somewhere else", s: "MyFitnessPal, MacroFactor or another app. One honest tap when you hit your calories.", box: "Hit my calories" },''',
    '''    elsewhere: { t: "I track somewhere else", s: "MyFitnessPal, MacroFactor or another app. One honest tap, or type today’s totals for the protein bonus.", box: "Hit my calories" },''')
rep('.fm-more { width: 100%; margin: 4px 0 8px; }', '''.fm-more { width: 100%; margin: 4px 0 8px; }
.fmx { display: grid; gap: 8px; padding-top: 10px; border-top: 1px dashed var(--line); }
.fmx-h { font-family: var(--f-label); font-weight: 700; font-size: 13px; letter-spacing: .1em; text-transform: uppercase; color: var(--ink); }
.fmx-n { margin: 0; font-size: 13.5px; color: var(--muted); }
.fmx-row { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.fmx-f { display: grid; gap: 4px; font-size: 13px; color: var(--muted); }
.fmx-in { position: relative; display: block; } .fmx-in .field { width: 100%; padding-right: 40px; }
.fmx-in i { position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-style: normal; font-size: 13px; color: var(--muted); }
.fmx-acts { display: flex; gap: 8px; } .fmx-acts .btn { flex: 1; }
.fmc-box.ext { opacity: 1; cursor: default; }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
