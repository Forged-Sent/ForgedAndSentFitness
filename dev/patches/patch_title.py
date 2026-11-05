#!/usr/bin/env python3
"""Rename the app/artifact to "Forged and Sent Fitness" (page title). Requested by Curtis 2026-11-04.
Usage: patch_title.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
old = '<title>Forged &amp; Sent</title>'
assert s.count(old) == 1
s = s.replace(old, '<title>Forged and Sent Fitness</title>')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
