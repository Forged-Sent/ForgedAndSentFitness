#!/usr/bin/env python3
"""Superset set rows: lift names shrink to fit instead of breaking mid-word; the tag, name and last-time numbers
are centered under each other (Curtis 2026-11-04). Usage: patch_suplabel.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''.sup-round .sn .sn-l span { font-size: 12px; hyphens: auto; overflow-wrap: anywhere; display: -webkit-box;''',
    '''.sup-round .sn { align-items: center; text-align: center; }
.sup-round .sn .sn-prev { align-self: center; text-align: center; }
.sup-round .sn .sn-l.sup-l { flex-direction: column; align-items: center; gap: 1px; width: 100%; }
.sup-round .sn .sn-l span { font-family: var(--f-label); font-weight: 600; font-size: 14px; line-height: 1.1; letter-spacing: .01em; hyphens: none; overflow-wrap: normal; word-break: keep-all; width: 100%; display: -webkit-box;''')
# shrink each name until its longest word fits on a line and it takes at most two lines
rep('''lb.textContent = ""; lb.appendChild(el("i", null, tag));''', '''lb.textContent = ""; lb.classList.add("sup-l"); lb.appendChild(el("i", null, tag));''')
rep('''    var nSets = Math.max(rows[0].s.length, rows[1].s.length);''', '''    setTimeout(function () { supFit(card); }, 0);
    var nSets = Math.max(rows[0].s.length, rows[1].s.length);''')
rep('''  function supGroup(body, L, items) {''', '''  function supFit(card) {
    Array.prototype.forEach.call(card.querySelectorAll(".sup-round .sn-l span"), function (sp) {
      var fs = 14; sp.style.webkitLineClamp = "unset"; sp.style.display = "block"; sp.style.fontSize = fs + "px";
      function bad() { var lh = fs * 1.1; return sp.scrollWidth > sp.clientWidth + 1 || sp.scrollHeight > lh * 2 + 2; }
      while (bad() && fs > 9.5) { fs -= 0.5; sp.style.fontSize = fs + "px"; }
    });
  }
  function supGroup(body, L, items) {''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
