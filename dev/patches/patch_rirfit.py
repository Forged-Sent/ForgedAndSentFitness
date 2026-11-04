#!/usr/bin/env python3
"""Effort chips ("how many more could you have done?") fit on one line on the workout page (Curtis 2026-11-04).
Usage: patch_rirfit.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''.rate-chips .mini { min-height: 34px; padding: 4px 10px; font-size: 12px; }''', '''.rate-chips .mini { min-height: 34px; padding: 4px 10px; font-size: 12px; }
.rir-q .rate-chips { flex-wrap: nowrap; gap: 4px; }
.rir-q .rate-chips .mini { flex: 1 1 auto; min-width: 0; min-height: 34px; padding: 4px 2px; font-size: clamp(9px, 2.75vw, 11.5px); letter-spacing: 0; white-space: nowrap; }
.sup-card .rir-q .rate-chips .mini { font-size: clamp(8.5px, 2.6vw, 11.5px); padding: 4px 1px; }''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
