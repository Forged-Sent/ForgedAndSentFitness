#!/usr/bin/env python3
"""Bug fix: the Paul & Timothy info sheet opened scrolled to the bottom because focus jumped to the Got it button.
It now opens at the top (focus on the sheet title without scrolling). Usage: patch_infotop.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
old = '''back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); back.remove(); } }); document.body.appendChild(back); cl.focus();
  }
  function drawMentorToday() {'''
assert s.count(old) == 1, s.count(old)
s = s.replace(old, '''back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); back.remove(); } }); document.body.appendChild(back);
    h.tabIndex = -1; try { h.focus({ preventScroll: true }); } catch (e) {} box.scrollTop = 0;
  }
  function drawMentorToday() {''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
