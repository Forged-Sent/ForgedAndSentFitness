#!/usr/bin/env python3
"""Bug fix: checked boxes vanished after a republish/reload. On load the app runs small automatic saves for today
(Sabbath workout box, fast day). If those ran before today's check-in and food log had arrived from the database, the
save was built from an empty day and overwrote the real one. Now every day-save waits until today's check-ins and logs
have loaded (it retries for up to 15 seconds), so it always builds on what's already saved.
Usage: patch_loadguard.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''  function writeDay(fn) {
    if (!state.me || !state.canWrite) return;''', '''  function writeDay(fn, tries) {
    if (!state.me || !state.canWrite) return;
    // Never build today's save from an empty day: wait until today's check-ins and food log have loaded.
    if (B.db && (!state.checksLoaded || !state.logsLoaded)) { tries = (tries || 0) + 1; if (tries <= 60) setTimeout(function () { writeDay(fn, tries); }, 250); return; }''')
rep('''      unsub.checks = B.watchChecks(low, function (rows) { state.checks = keepLocal(''', '''      state.checksLoaded = false; unsub.checks = B.watchChecks(low, function (rows) { state.checksLoaded = true; state.checks = keepLocal(''')
rep('''      unsub.logs = B.watchLogs(state.me, low, function (rows) { state.logs = keepLocal(''', '''      state.logsLoaded = false; unsub.logs = B.watchLogs(state.me, low, function (rows) { state.logsLoaded = true; state.logs = keepLocal(''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
