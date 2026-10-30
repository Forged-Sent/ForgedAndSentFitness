#!/usr/bin/env python3
"""Lift history: under each lift, small text with last time's sets (weight x reps), and a History button that opens
every earlier time he did that lift, newest first. Usage: patch_lifthist.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

HIST = r'''  /* Lift history: every earlier day this lift was logged, newest first. Read from his saved workout logs. */
  function liftSessions(g, key) {
    if (!wkHist) return []; var gk = String(g).trim().toLowerCase(), byDay = {};
    wkHist.forEach(function (d) {
      if (!d || !d.date || d.date >= key) return;
      var root = normWk(d, d.date), rt = root.rate || {};
      exEntriesOf(root, d.date).forEach(function (e) {
        if (String(e[0]).trim().toLowerCase() !== gk) return;
        var sets = e[2].filter(function (x) { return x && Number(x.r) > 0; }).map(function (x) { return { w: parseFloat(x.w) || 0, r: Number(x.r), k: !!x.k }; });
        if (!sets.length) return;
        var day = byDay[d.date] || (byDay[d.date] = { date: d.date, rx: e[1], sets: [], rir: "" });
        day.sets = day.sets.concat(sets); if (e[3] != null && (rt.lifts || {})[e[3]]) day.rir = rt.lifts[e[3]];
      });
    });
    return Object.keys(byDay).sort().reverse().map(function (k) { return byDay[k]; });
  }
  function setText(x, weighted) { return (x.w ? (weighted ? "" : "+") + fmtW(x.w) + " lb × " + x.r : x.r + (x.r === 1 ? " rep" : " reps")); }
  function openLiftHistory(g, key, name, weighted) {
    var list = liftSessions(g, key), old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box lh-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "lh-t");
    var x = el("button", "dlg-x"); x.type = "button"; x.setAttribute("aria-label", "Close"); x.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>'; box.appendChild(x);
    var h = el("h2", null, name + " history"); h.id = "lh-t"; box.appendChild(h);
    box.appendChild(el("p", "lh-sub", list.length + (list.length === 1 ? " workout" : " workouts") + " · newest first"));
    var yr = new Date().getFullYear(), rirTxt = { "3": "3+ reps left", "2": "2 reps left", "1": "1 rep left", "0": "Nothing left", "x": "Missed reps" };
    list.forEach(function (d, i) {
      var card = el("div", "lh-day" + (i === 0 ? " last" : "")), dt = parseKey(d.date);
      var top = el("div", "lh-top"); top.appendChild(el("b", null, dt.toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric", year: dt.getFullYear() !== yr ? "numeric" : undefined })));
      top.appendChild(el("span", null, d.rx || "")); card.appendChild(top);
      var heavy = 0; d.sets.forEach(function (st) { if (!st.k && st.w > heavy) heavy = st.w; });
      var n = 0;
      d.sets.forEach(function (st) {
        var row = el("div", "lh-set" + (st.k ? " wu" : "") + (!st.k && heavy && st.w === heavy ? " top" : ""));
        row.appendChild(el("span", "lh-n", st.k ? "Warm-up" : "Set " + (++n)));
        row.appendChild(el("span", "lh-v", setText(st, weighted)));
        card.appendChild(row);
      });
      if (d.rir && rirTxt[d.rir]) card.appendChild(el("p", "lh-rir", "Last set: " + rirTxt[d.rir]));
      var ln = liftNoteFor(g); if (ln && ln.d === d.date && ln.t) card.appendChild(el("p", "lh-note", "“" + ln.t + "”"));
      box.appendChild(card);
    });
    if (!list.length) box.appendChild(el("p", "note", "No earlier workouts with this lift yet."));
    function close() { back.remove(); }
    x.addEventListener("click", close);
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back); try { x.focus({ preventScroll: true }); } catch (e) {}
  }
'''
rep('  function lastTimeEl(g, key, rxNow, weighted) {', HIST + '  function lastTimeEl(g, key, rxNow, weighted, name) {')
# the small sets line and the History button, right under "Last time"
rep('''    box.appendChild(document.createTextNode((weighted && L.w ? L.w + " lb \\u00D7 " : "") + L.r + " reps on your last working set"));''',
    '''    box.appendChild(document.createTextNode((weighted && L.w ? L.w + " lb \\u00D7 " : "") + L.r + " reps on your last working set"));
    var hs = liftSessions(g, key), last = hs[0];
    if (last) {
      var work = last.sets.filter(function (x) { return !x.k; });
      var sl = el("span", "lt-sets"); sl.textContent = work.map(function (x, i) { return "Set " + (i + 1) + ": " + setText(x, weighted); }).join(" \\u00B7 ");
      box.appendChild(sl);
      var hb = el("button", "lt-hist"); hb.type = "button"; hb.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3.5 12a8.5 8.5 0 1 0 2.6-6.1"/><path d="M3 4.5v4h4"/><path d="M12 7.5V12l3 2"/></svg>';
      hb.appendChild(el("span", null, "History (" + hs.length + ")")); hb.setAttribute("aria-label", "See every earlier time you did " + (name || g) + ", newest first");
      hb.addEventListener("click", function () { openLiftHistory(g, key, name || g, weighted); }); box.appendChild(hb);
    }''')
# show on the workout preview too (not only once he starts), and pass the lift's name
rep('      if (ps && !ps.time && (live || (isToday && !done))) { var lt0 = lastTimeEl(mg, key, e[1], needsWeight(mg, p.equip)); if (lt0) ex.appendChild(lt0); }',
    '      if (ps && !ps.time && !done) { var lt0 = lastTimeEl(mg, key, e[1], needsWeight(mg, p.equip), shownName); if (lt0) ex.appendChild(lt0); }')

rep('.wk-last .up { display: block; font-weight: 700; color: var(--accent); }', '''.wk-last .up { display: block; font-weight: 700; color: var(--accent); }
.wk-last .lt-sets { display: block; margin-top: 3px; font-size: 12px; line-height: 1.4; color: var(--muted); font-variant-numeric: tabular-nums; }
.lt-hist { display: inline-flex; align-items: center; gap: 6px; margin-top: 6px; min-height: 32px; padding: 0 10px; border: 1px solid var(--line); border-radius: 16px; background: var(--surface); color: var(--ink); font-family: var(--f-label); font-weight: 700; font-size: 12px; letter-spacing: .08em; text-transform: uppercase; cursor: pointer; }
.lt-hist svg { width: 15px; height: 15px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.lh-box { max-height: calc(var(--app-h, 100dvh) - 60px); overflow-y: auto; }
.lh-box h2 { padding-right: 44px; }
.lh-sub { margin: -4px 0 8px; color: var(--muted); font-size: 13px; }
.lh-day { border-top: 1px solid var(--line); padding: 10px 0; }
.lh-top { display: flex; flex-wrap: wrap; align-items: baseline; justify-content: space-between; gap: 2px 10px; margin-bottom: 4px; }
.lh-top b { font-family: var(--f-label); font-size: 16px; letter-spacing: .03em; }
.lh-top span { font-size: 12px; color: var(--muted); }
.lh-day.last .lh-top b { color: var(--accent); }
.lh-set { display: grid; grid-template-columns: 76px minmax(0, 1fr); gap: 8px; padding: 3px 0; font-size: 14px; font-variant-numeric: tabular-nums; }
.lh-set .lh-n { font-family: var(--f-label); font-size: 12px; letter-spacing: .06em; text-transform: uppercase; color: var(--muted); align-self: center; }
.lh-set.wu .lh-v { color: var(--muted); }
.lh-set.top .lh-v { font-weight: 700; }
.lh-rir, .lh-note { margin: 4px 0 0; font-size: 12.5px; color: var(--muted); }
.lh-note { font-style: italic; color: var(--ink); }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
