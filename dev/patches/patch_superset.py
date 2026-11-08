#!/usr/bin/env python3
"""Supersets logged set by set (approved by Curtis 2026-11-04 from superset_mock.png).
A1 and A2 sit in one Superset card. Each set shows A1 then A2 together, with one rest timer after A2.
+ Add set and + Warm-up set add one for both lifts. Per-lift pieces (video, Alt, cue, last time, notes, effort
question, PRs) stay with each lift. Stored data is unchanged (rec.ex[idx] per lift); this is display only.
Finished (locked) workouts show the same grouping. Usage: patch_superset.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

rep('''.setrow.one { grid-template-columns: 54px 48px; }''', '''.setrow.one { grid-template-columns: 54px 48px; }
.sup-card { border: 1px solid var(--accent); border-radius: 12px; padding: 12px 10px; margin: 10px 0; gap: 0; }
.sup-card .sup-k { font-family: var(--f-label); font-weight: 800; letter-spacing: .12em; text-transform: uppercase; font-size: 15px; color: var(--accent); }
.sup-card .sup-rx { font-size: 14px; color: var(--muted); margin: 2px 0 6px; line-height: 1.4; }
.sup-card > .wx { border-top: 1px dashed var(--line); padding: 8px 0; }
.sup-card .wx-top { align-items: center; }
.sup-tag { flex: none; width: 30px; height: 30px; border-radius: 50%; background: var(--accent); color: var(--accent-ink, #111); font-family: var(--f-label); font-weight: 800; font-size: 14px; display: inline-grid; place-items: center; }
.sup-round { margin-top: 10px; border: 1px solid var(--line); border-radius: 10px; padding: 0 8px 8px; }
.sup-round.done { border-color: var(--accent); }
.sup-rh { display: flex; justify-content: space-between; align-items: center; gap: 8px; margin: 0 -8px; padding: 7px 10px; background: var(--surface); border-radius: 9px 9px 0 0; font-family: var(--f-label); font-weight: 800; letter-spacing: .12em; text-transform: uppercase; font-size: 14px; }
.sup-rh span { color: var(--muted); font-weight: 700; font-size: 12.5px; letter-spacing: .08em; }
.sup-round.done .sup-rh span { color: var(--accent); }
#wkp-body .sup-round .setrow:not(.one) { grid-template-columns: 96px minmax(0, 1fr) minmax(0, 1fr) 26px 32px; }
.sup-round .sn .sn-l span { font-size: 12px; hyphens: auto; overflow-wrap: anywhere; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.sup-round .sn .sn-l { display: flex; gap: 5px; align-items: baseline; text-transform: none; letter-spacing: 0; font-family: var(--f-body); font-size: 12.5px; color: var(--ink); line-height: 1.2; }
.sup-round .sn .sn-l i { font-style: normal; font-family: var(--f-label); font-weight: 800; color: var(--accent); font-size: 14px; letter-spacing: .04em; }
.sup-round .rest { margin-top: 8px; }
.sup-rir .rate-l b { color: var(--accent); }
.lk-sup { border-left: 3px solid var(--accent); padding-left: 10px; }''')

JS = r'''
  /* ---------- Supersets: A1 and A2 logged set by set (display only; each lift keeps its own rec.ex) ---------- */
  function supLetter(rx, n) { var m = /^\s*Superset\s+([A-Z])(\d+):/i.exec(String(rx || "")); return m && (n == null || +m[2] === n) ? m[1].toUpperCase() : ""; }
  function supPairAt(list, i) {
    var a = list[i], b = list[i + 1]; if (!a || !b || a[2] || b[2]) return "";
    var L = supLetter(a[1], 1); if (!L || supLetter(b[1], 2) !== L) return "";
    var c = list[i + 2]; if (c && !c[2] && supLetter(c[1]) === L) return "";
    return L;
  }
  function supRestText(rx) { var m = /rest\s+([^.,]*?\d[^.,]*?(?:sec|min))/i.exec(String(rx || "")); return m ? m[1].replace(/\s+/g, " ") : "about a minute"; }
  function supShortRx(rx) { return String(rx || "").replace(/^\s*Superset\s+[A-Z]\d+:\s*/i, "").split(/\.\s/)[0].replace(/\.$/, ""); }
  function supGroup(body, L, items) {
    // items: [{ ex, e, idx, name, ps }] for A1 and A2, already rendered as .wx cards in body
    var A = items[0], Bx = items[1], card = el("div", "wx sup-card"); body.insertBefore(card, A.ex);
    var rows = [], rirs = [];
    items.forEach(function (it, n) {
      var tag = L + (n + 1), w = [], s = [];
      Array.prototype.slice.call(it.ex.children).forEach(function (c) {
        var cl = c.classList;
        if (cl.contains("setrow")) { var lb = c.querySelector(".sn-l"), t = lb ? lb.textContent : ""; (/^W/.test(t) ? w : s).push(c); c.remove(); return; }
        if (cl.contains("addset") || cl.contains("rest") || cl.contains("sup-go") || (c.tagName === "SPAN" && cl.contains("wc") && /^Target:/.test(c.textContent))) { c.remove(); return; }
        if (cl.contains("rir-q")) { var rl = c.querySelector(".rate-l"); if (rl) { rl.textContent = ""; rl.appendChild(el("b", null, tag + " ")); rl.appendChild(document.createTextNode(it.name)); } rirs.push(c); c.remove(); return; }
        if (cl.contains("wr")) c.textContent = supShortRx(c.textContent);
      });
      var top = it.ex.querySelector(".wx-top"); if (top) top.insertBefore(el("span", "sup-tag", tag), top.firstChild);
      it.ex.classList.add("sup-lift"); card.appendChild(it.ex);
      [w, s].forEach(function (list) { list.forEach(function (r) { var lb = r.querySelector(".sn-l"); if (lb) { lb.textContent = ""; lb.appendChild(el("i", null, tag)); lb.appendChild(el("span", null, it.name.replace(/^(Dumbbell|Barbell|Cable|Kettlebell|EZ[- ]Bar|Machine|Band|Banded|Smith Machine)\s+/i, ""))); lb.title = it.name; } }); });
      rows.push({ w: w, s: s });
    });
    var nSets = Math.max(rows[0].s.length, rows[1].s.length);
    var hd = el("div", "sup-hd"); hd.appendChild(el("div", "sup-k", "Superset " + L + " · " + nSets + (nSets === 1 ? " set" : " sets")));
    hd.appendChild(el("div", "sup-rx", "Each set: " + L + "1 then " + L + "2 back to back. Rest " + supRestText(Bx.e[1]) + " after " + L + "2."));
    card.insertBefore(hd, card.firstChild);
    var restSec = restOf(Bx.e[1]) || 60;
    function round(title, list, k, last, warm) {
      var rd = el("div", "sup-round"), rh = el("div", "sup-rh"), st = el("span"); rh.appendChild(el("b", null, title)); rh.appendChild(st); rd.appendChild(rh);
      list.forEach(function (r) { if (r) rd.appendChild(r); });
      function paint() { var on = list.filter(Boolean).every(function (r) { return r.classList.contains("ok"); }); rd.classList.toggle("done", on); st.textContent = on ? "✓ Done" : ""; }
      rd.addEventListener("input", function () { setTimeout(paint, 0); }); paint();
      if (!last && !warm) { var rb = restBar("sup" + Bx.idx + "-" + k, restSec); rb.insertBefore(el("span", "rt-label", "After " + L + "2 ·"), rb.firstChild); rd.appendChild(rb); }
      card.appendChild(rd);
    }
    var nW = Math.max(rows[0].w.length, rows[1].w.length);
    for (var k = 0; k < nW; k++) round("Warm-up " + (k + 1), [rows[0].w[k], rows[1].w[k]], k, false, true);
    for (var j = 0; j < nSets; j++) round("Set " + (j + 1), [rows[0].s[j], rows[1].s[j]], j, j === nSets - 1, false);
    var ab = el("div", "addset"), bw = el("button", "mini", "+ Warm-up set"), bx = el("button", "mini", "+ Add set"); bw.type = bx.type = "button";
    bw.addEventListener("click", function () { items.forEach(function (it) { var a = setsOf(it.idx, it.ps), at = a.filter(function (x) { return x.k === "w"; }).length; a.splice(at, 0, { w: "", r: "", d: false, k: "w" }); }); saveWkNow(); redrawKeepScroll(); });
    bx.addEventListener("click", function () { items.forEach(function (it) { setsOf(it.idx, it.ps).push({ w: "", r: "", d: false, k: "x" }); }); saveWkNow(); redrawKeepScroll(); });
    ab.appendChild(bw); ab.appendChild(bx); card.appendChild(ab);
    var tA = A.ps && A.ps.target, tB = Bx.ps && Bx.ps.target;
    card.appendChild(el("span", "wc", tA && tA === tB ? "Target: " + tA + " reps per lift, every set. + Add set adds a set for both lifts." : "Target: " + L + "1 " + (tA || "") + " reps, " + L + "2 " + (tB || "") + " reps, every set."));
    if (rirs.length) { var rq = el("div", "rir-q sup-rir"); rq.appendChild(el("span", "rate-l", "On your last set, how many more could you have done?")); card.appendChild(rq); rirs.forEach(function (r) { r.classList.add("sup-rir"); r.style.borderTop = "0"; r.style.marginTop = "4px"; r.style.paddingTop = "0"; card.appendChild(r); }); }
  }
'''
rep('''  function drawWorkoutPage(force) {''', JS + '''  function drawWorkoutPage(force) {''')

# remember each rendered card, then group live supersets after the loop
rep('''    var exBase = w.exercises.length, exList = w.exercises.concat(normExtra(rec.extra).map(function (x) { return [x.g, x.rx, true, x.rest]; }));
    exList.forEach(function (e, idx) {''', '''    var exBase = w.exercises.length, exList = w.exercises.concat(normExtra(rec.extra).map(function (x) { return [x.g, x.rx, true, x.rest]; })), supEls = {};
    exList.forEach(function (e, idx) {''')
rep('''        ex.insertBefore(xr, ex.firstChild);
      }
      body.appendChild(ex);
    });''', '''        ex.insertBefore(xr, ex.firstChild);
      }
      body.appendChild(ex); supEls[idx] = { ex: ex, e: e, idx: idx, name: shownName, ps: ps };
    });
    if (live) exList.forEach(function (e, idx) { var L = supPairAt(exList, idx); if (L && supEls[idx] && supEls[idx + 1] && supEls[idx].ex.querySelector(".setrow") && supEls[idx + 1].ex.querySelector(".setrow")) supGroup(body, L, [supEls[idx], supEls[idx + 1]]); });''')

# locked summary: group the pair set by set
rep('''    var sb = el("div", "lk-sec"); sb.appendChild(el("div", "lk-h", S ? "Exercises" : "Work sets"));
    exList.forEach(function (e, i) {
      var g = e[0],''', '''    var sb = el("div", "lk-sec"); sb.appendChild(el("div", "lk-h", S ? "Exercises" : "Work sets"));
    function lkVal(s, ps, bw) {
      var val = ps && ps.time ? [(s.r || "") + " sec"] : !ps ? ["Done"] : [(s.r || "") + " reps"];
      if (ps && !ps.time && !bw && s.w !== "" && s.w != null) { val.push(mut(" \\u00D7 ")); val.push(fmtW(Number(s.w)) + " lb"); }
      else if (bw && ps && Number(s.w) > 0) val.push(mut(" (bodyweight + " + fmtW(Number(s.w)) + " lb)"));
      else if (bw && ps) val.push(mut(" (bodyweight)"));
      return val;
    }
    var supSkip = {};
    exList.forEach(function (e, i) {
      if (supSkip[i]) return;
      var SL = S ? "" : supPairAt(exList.map(function (x) { return [x[0], x[1], x[2]]; }), i);
      if (SL) {
        supSkip[i + 1] = true;
        var item2 = el("div", "lk-ex lk-sup"), pr = [i, i + 1].map(function (ix, n) {
          var g2 = exList[ix][0], shown2 = moveName(g2, p.equip), a2 = (rec.ex && rec.ex[ix]) || [];
          var hd2 = el("div", "lk-name"); hd2.appendChild(el("span", null, SL + (n + 1) + " \\u00B7 " + shown2)); if (prNames[shown2]) hd2.appendChild(el("span", "lk-pr", "PR")); item2.appendChild(hd2);
          if (exList[ix][4] !== g2) { var sw2 = effSwap(rec, ix, exList[ix][4]); item2.appendChild(el("span", "sw-note", "Swapped from " + moveName(exList[ix][4], p.equip) + (sw2 && sw2.why ? " \\u00B7 " + sw2.why : ""))); }
          return { tag: SL + (n + 1), ps: parseSets(exList[ix][1]), bw: !needsWeight(g2, p.equip), w: a2.filter(function (s) { return s && s.k === "w"; }), s: a2.filter(function (s) { return s && s.k !== "w"; }) };
        });
        item2.insertBefore(el("div", "lk-round", "Superset " + SL), item2.firstChild);
        var any2 = false;
        [["w", "Warm-up "], ["s", "Set "]].forEach(function (kd) {
          var n2 = Math.max(pr[0][kd[0]].length, pr[1][kd[0]].length);
          for (var r2 = 0; r2 < n2; r2++) {
            var got = pr.filter(function (x) { var s3 = x[kd[0]][r2]; return s3 && (Number(s3.r) > 0 || s3.d); }); if (!got.length) continue; any2 = true;
            item2.appendChild(el("div", "lk-round", kd[1] + (r2 + 1)));
            got.forEach(function (x) { line(item2, x.tag, lkVal(x[kd[0]][r2], x.ps, x.bw), kd[0] === "w" ? "wu" : ""); });
          }
        });
        if (!any2) item2.appendChild(el("span", "lk-none", "Not logged"));
        sb.appendChild(item2); return;
      }
      var g = e[0],''')


rep('''      "Warm-ups go round by round. Enter reps, and weight where the lift needs it.",''', '''      "Warm-ups go round by round. Enter reps, and weight where the lift needs it.",
      "Dumbbells: enter the weight of one dumbbell, not both added together.",
      "Bodyweight lifts like push-ups, pull-ups and dips: don\\u2019t enter a weight. Leave the + box empty unless you add weight with a vest, belt or plate, and then enter only that added weight.",
      "Supersets: both lifts share one card. Each set shows A1 and A2 together. Do A1, go straight to A2, then rest.",''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
