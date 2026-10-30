#!/usr/bin/env python3
"""Last time's numbers sit inside each set row of the live workout (under the set label). Usage: patch_prevsets.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# Last time box: when the sets are shown in the rows, skip the one-line list.
rep('  function lastTimeEl(g, key, rxNow, weighted, name) {', '  function lastTimeEl(g, key, rxNow, weighted, name, inRows) {')
rep('    if (last) {\n      var work = last.sets.filter(function (x) { return !x.k; });\n      var sl = el("span", "lt-sets");',
    '    if (last) {\n      var work = last.sets.filter(function (x) { return !x.k; });\n      var sl = el("span", "lt-sets" + (inRows ? " in-rows" : ""));')
rep('var lt0 = lastTimeEl(mg, key, e[1], needsWeight(mg, p.equip), shownName);', 'var lt0 = lastTimeEl(mg, key, e[1], needsWeight(mg, p.equip), shownName, live);')
# previous session for this lift, split into warm-ups and working sets, read once per lift
rep('''        if (ps) {
          var setNo = 0, wNo = 0, afRows = [];''', '''        if (ps) {
          var setNo = 0, wNo = 0, afRows = [], prevDay = ps.time ? null : liftSessions(mg, key)[0], prevW = prevDay ? prevDay.sets.filter(function (x) { return x.k; }) : [], prevS = prevDay ? prevDay.sets.filter(function (x) { return !x.k; }) : [], prevWt = needsWeight(mg, p.equip);''')
rep('''            row.appendChild(el("span", "sn", lab));
            var ck = el("span", "setck", "\\u2713");''', '''            var pv = isX ? null : isW ? prevW[wNo - 1] : prevS[setNo - 1], snb = el("span", "sn"); snb.appendChild(el("span", "sn-l", lab));
            if (pv) { var pvs = el("span", "sn-prev", (pv.w ? (prevWt ? "" : "+") + fmtW(pv.w) + "\\u00D7" : "") + pv.r); pvs.title = "Last time: " + setText(pv, prevWt); pvs.setAttribute("aria-label", "Last time " + setText(pv, prevWt)); snb.appendChild(pvs); }
            row.appendChild(snb);
            var ck = el("span", "setck", "\\u2713");''')
rep('.setrow .sn { ', '.setrow .sn { display: flex; flex-direction: column; line-height: 1.15; ')
s = s.replace('.lh-note { font-style: italic; color: var(--ink); }', '''.lh-note { font-style: italic; color: var(--ink); }
.wk-last .lt-sets.in-rows { display: none; }
.setrow .sn-prev { margin-top: 2px; font-family: var(--f-body); font-size: 11px; font-weight: 500; letter-spacing: 0; text-transform: none; color: var(--brass); font-variant-numeric: tabular-nums; white-space: nowrap; }
#wkp-body .setrow:not(.one) { grid-template-columns: 52px minmax(0, 1fr) minmax(0, 1fr) 26px 32px; }''', 1)
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
