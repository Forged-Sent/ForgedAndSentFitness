#!/usr/bin/env python3
"""Coach Gideon's guidance starts closed every time he comes to a workout. If he opens it, it stays open while he
is on that workout (redraws don't snap it shut), and it closes again as soon as he leaves the page.
Usage: patch_coachclose.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('    var d = el("details", "coach-sec coach-big coach-brief"), sm = el("summary"); d.open = true;',
    '    var d = el("details", "coach-sec coach-big coach-brief"), sm = el("summary"); d.open = !!coachOpen;\n    d.addEventListener("toggle", function () { coachOpen = d.open; });')
rep('  var BRIEF_SECS = [', '  var coachOpen = false; // closed each time he arrives on a workout\n  var BRIEF_SECS = [')
rep('    state.page = p;\n', '    if (p !== state.page || p !== "workout") coachOpen = false;\n    state.page = p;\n')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
