#!/usr/bin/env python3
"""Long prescriptions in the program picker wrap instead of running off the screen. Usage: patch_wrap.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:80], s.count(old))
    s = s.replace(old, new)
rep('.pinfo .pi-day span:last-child { color: var(--muted); text-align: right; flex: none; }',
    '.pinfo .pi-day span:first-child { min-width: 0; }\n.pinfo .pi-day span:last-child { color: var(--muted); text-align: right; flex: 0 1 auto; max-width: 55%; min-width: 0; overflow-wrap: anywhere; }')
rep('.pinfo .pi-ex span:last-child { color: var(--accent); font-weight: 600; text-align: right; flex: none; }',
    '.pinfo .pi-ex span:first-child { flex: 1 1 45%; min-width: 0; overflow-wrap: anywhere; }\n.pinfo .pi-ex span:last-child { color: var(--accent); font-weight: 600; text-align: right; flex: 0 1 55%; min-width: 0; overflow-wrap: anywhere; }')
rep('.pts-row b { flex: none; font-family: var(--f-label); font-weight: 700; color: var(--accent); text-align: right; }',
    '.pts-row > span { min-width: 0; }\n.pts-row b { flex: 0 1 auto; max-width: 62%; min-width: 0; overflow-wrap: anywhere; font-family: var(--f-label); font-weight: 700; color: var(--accent); text-align: right; }')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
