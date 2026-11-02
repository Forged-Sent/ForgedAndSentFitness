#!/usr/bin/env python3
"""Fuel › Copy a previous day: make the action obvious. Every row gets a visible "+ Add" button (the Entire day row
gets a solid "+ Add all"), the calories sit under the button, and the note says what Add does.
Usage: patch_copyadd.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''    function row(title, items, tap, label) {
      var t = mealSum(items), b = el("button", "af-row"); b.type = "button"; b.disabled = off; b.setAttribute("aria-label", label);
      var tx = el("span", "txt"); tx.appendChild(el("span", "name", title)); tx.appendChild(el("span", "sub", items.length + (items.length === 1 ? " food" : " foods") + " \\u00B7 " + items.map(function (e) { return e.name; }).join(", ")));
      b.appendChild(tx); b.appendChild(el("span", "nums", fmt(t.kcal) + " cal")); b.addEventListener("click", tap); return b;
    }''', '''    function row(title, items, tap, label, all) {
      var t = mealSum(items), b = el("button", "af-row cp-row" + (all ? " cp-all" : "")); b.type = "button"; b.disabled = off; b.setAttribute("aria-label", label);
      var tx = el("span", "txt"); tx.appendChild(el("span", "name", title)); tx.appendChild(el("span", "sub", items.length + (items.length === 1 ? " food" : " foods") + " \\u00B7 " + fmt(t.kcal) + " cal \\u00B7 " + items.map(function (e) { return e.name; }).join(", ")));
      b.appendChild(tx); b.appendChild(el("span", "cp-add", all ? "+ Add all" : "+ Add")); b.addEventListener("click", tap); return b;
    }''')
rep('''    }, "Copy the entire day into today"));''', '''    }, "Copy the entire day into today", true));''')
rep('''    w.appendChild(el("p", "fnote", a.whole ? "Entire day copies every meal into the same meal today. Tap one meal to copy just that meal." : "Entire day copies every meal into the same meal today. Tap one meal to copy it into today\\u2019s " + m.label.toLowerCase() + "."));''',
'''    w.appendChild(el("p", "fnote", a.whole ? "Add all puts every meal from that day into the same meal today. Add on one meal copies just that meal." : "Add all puts every meal from that day into the same meal today. Add on one meal copies it into today\\u2019s " + m.label.toLowerCase() + "."));''')
rep('''.af-rowwrap{display:flex;align-items:center;gap:8px}''', '''.af-rowwrap{display:flex;align-items:center;gap:8px}
.cp-row{padding:12px 2px}
.cp-add{flex:none;display:inline-flex;align-items:center;justify-content:center;min-width:84px;min-height:40px;padding:8px 14px;border:1px solid var(--accent);border-radius:20px;color:var(--accent);font-family:var(--f-label);font-weight:800;font-size:13.5px;letter-spacing:.08em;text-transform:uppercase;white-space:nowrap}
.cp-all{margin-bottom:6px;padding:12px;border:1px solid var(--accent);border-radius:8px;background:var(--surface)}
.cp-all .cp-add{background:var(--accent);color:#111}
.cp-row:disabled .cp-add{opacity:.45}''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
