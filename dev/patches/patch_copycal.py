#!/usr/bin/env python3
"""Fuel › Copy a previous day: three quick chips plus a "Pick another day" button with a themed calendar icon
(calendar page carrying the app's shield-and-cross). It opens a month calendar inside the sheet: days with food get a
brass dot, empty days are greyed out, arrows move by month within the days the app keeps (lowKey to yesterday).
Usage: patch_copycal.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''    var l = el("label", "flabel", "Pick a day"), di = el("input", "field"); di.type = "date"; di.id = "af-cd"; di.min = low; di.max = yk; di.value = a.copyDate;
    di.addEventListener("change", function () { if (di.value && di.value >= low && di.value <= yk) { a.copyDate = di.value; drawMeals(true); } });
    l.appendChild(di); w.appendChild(l);
    if (days.length) {
      var ch = el("div", "rchips");
      days.slice(0, 7).forEach(function (d) {''', '''    if (days.length) {
      var ch = el("div", "rchips cp-chips");
      days.slice(0, 3).forEach(function (d) {''')
rep('''      w.appendChild(el("span", "label-caps", "Recent days with food")); w.appendChild(ch);
    }''', '''      w.appendChild(el("span", "label-caps", "Recent days with food")); w.appendChild(ch);
    }
    var pk = el("button", "cp-pick" + (a.calOpen ? " open" : "")); pk.type = "button"; pk.setAttribute("aria-expanded", String(!!a.calOpen));
    var ic = el("span", "cp-ic"); ic.innerHTML = CAL_ICON; pk.appendChild(ic);
    var pt = el("span", "cp-pt"); pt.appendChild(el("b", null, "Pick another day")); pt.appendChild(el("small", null, "Showing " + parseKey(a.copyDate).toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" }))); pk.appendChild(pt);
    pk.appendChild(el("span", "cp-chev", a.calOpen ? "\\u2013" : "+"));
    pk.addEventListener("click", function () { a.calOpen = !a.calOpen; if (a.calOpen) a.calMonth = a.copyDate.slice(0, 7); drawMeals(true); });
    w.appendChild(pk);
    if (a.calOpen) w.appendChild(copyCal(a, low, yk));''')
rep('''  function drawCopy(m, off) {''', '''  var CAL_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3.5 5.5h17V21h-17Z"/><path d="M3.5 9.5h17"/><path d="M8 3v4M16 3v4"/><path d="M12 11.3 15.6 12.6V15.2c0 2-1.4 3.4-3.6 4.2-2.2-.8-3.6-2.2-3.6-4.2V12.6Z"/><path d="M12 13.1v4.6M10.4 14.6h3.2"/></svg>';
  function copyCal(a, low, yk) {
    var have = {}; state.logs.forEach(function (l) { if (MEALS.some(function (x) { return (l.meals[x.k] || []).length; })) have[l.date] = 1; });
    var ym = a.calMonth || a.copyDate.slice(0, 7), y = +ym.slice(0, 4), mo = +ym.slice(5, 7) - 1;
    var box = el("div", "cpc"), hd = el("div", "cpc-hd");
    var pv = el("button", "mini cpc-nav", "\\u2039"), nx = el("button", "mini cpc-nav", "\\u203A"); pv.type = nx.type = "button";
    pv.setAttribute("aria-label", "Previous month"); nx.setAttribute("aria-label", "Next month");
    var first = new Date(y, mo, 1), last = new Date(y, mo + 1, 0);
    pv.disabled = dkey(new Date(y, mo, 0)) < low; nx.disabled = dkey(new Date(y, mo + 1, 1)) > yk;
    pv.addEventListener("click", function () { var d = new Date(y, mo - 1, 1); a.calMonth = dkey(d).slice(0, 7); drawMeals(true); });
    nx.addEventListener("click", function () { var d = new Date(y, mo + 1, 1); a.calMonth = dkey(d).slice(0, 7); drawMeals(true); });
    hd.appendChild(pv); hd.appendChild(el("b", "cpc-m", first.toLocaleDateString(undefined, { month: "long", year: "numeric" }))); hd.appendChild(nx); box.appendChild(hd);
    var g = el("div", "cpc-g"); ["M", "T", "W", "T", "F", "S", "S"].forEach(function (d) { g.appendChild(el("span", "cpc-dow", d)); });
    for (var i = 0, lead = (first.getDay() + 6) % 7; i < lead; i++) g.appendChild(el("span"));
    for (var dd = 1; dd <= last.getDate(); dd++) (function (k, dd) {
      var ok = have[k] && k >= low && k <= yk, b = el("button", "cpc-d" + (ok ? " has" : "") + (k === a.copyDate ? " on" : ""), String(dd)); b.type = "button"; b.disabled = !ok;
      b.setAttribute("aria-label", longDate(k) + (ok ? ", food logged" : ", nothing logged"));
      if (ok) b.addEventListener("click", function () { a.copyDate = k; a.calOpen = false; drawMeals(true); });
      g.appendChild(b);
    })(dkey(new Date(y, mo, dd)), dd);
    box.appendChild(g);
    box.appendChild(el("p", "fnote", "Dotted days have food logged. The app keeps about the last five weeks."));
    return box;
  }
  function drawCopy(m, off) {''')
rep('''.rchip{border:1px solid var(--line);background:transparent;padding:6px 10px;font-size:13px;min-height:36px}''', '''.rchip{border:1px solid var(--line);background:transparent;padding:6px 10px;font-size:13px;min-height:36px}
.cp-chips{flex-wrap:nowrap;overflow:hidden}
.cp-chips .rchip{flex:1 1 0;min-width:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.cp-pick{width:100%;display:flex;align-items:center;gap:12px;margin:12px 0 4px;padding:10px 12px;border:1px solid var(--line);border-radius:8px;background:var(--surface);color:var(--ink);text-align:left;font:inherit;cursor:pointer}
.cp-pick.open{border-color:var(--accent)}
.cp-ic{flex:none;width:40px;height:40px;border-radius:50%;display:grid;place-items:center;border:1px solid var(--accent);color:var(--accent)}
.cp-ic svg{width:22px;height:22px;fill:none;stroke:currentColor;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
.cp-pt{flex:1;min-width:0;display:grid;gap:1px}.cp-pt b{font-family:var(--f-label);font-weight:800;font-size:15px;letter-spacing:.08em;text-transform:uppercase}.cp-pt small{font-size:13px;color:var(--muted)}
.cp-chev{flex:none;font-size:20px;color:var(--accent);width:20px;text-align:center}
.cpc{margin:6px 0 8px;padding:10px;border:1px solid var(--line);border-radius:8px;background:var(--surface)}
.cpc-hd{display:flex;align-items:center;justify-content:space-between;gap:8px;margin-bottom:6px}
.cpc-m{font-family:var(--f-label);font-weight:800;letter-spacing:.08em;text-transform:uppercase;font-size:14.5px}
.cpc-nav{min-width:44px;min-height:40px;font-size:18px}
.cpc-g{display:grid;grid-template-columns:repeat(7,minmax(0,1fr));gap:4px}
.cpc-dow{text-align:center;font-size:11.5px;color:var(--muted);font-family:var(--f-label);letter-spacing:.1em;padding:2px 0}
.cpc-d{position:relative;min-height:42px;border:1px solid transparent;border-radius:6px;background:transparent;color:var(--muted);opacity:.45;font-size:15px;font-variant-numeric:tabular-nums}
.cpc-d.has{color:var(--ink);opacity:1;border-color:var(--line);cursor:pointer}
.cpc-d.has::after{content:"";position:absolute;left:50%;bottom:5px;width:5px;height:5px;margin-left:-2.5px;border-radius:50%;background:var(--brass,var(--accent))}
.cpc-d.on{border-color:var(--accent);color:var(--accent);font-weight:700}''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
