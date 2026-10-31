#!/usr/bin/env python3
"""Workout page keeps its place: every redraw of the open workout (removing a set or warm-up, adding one, data
arriving from the server, PR checks) holds the page height while it rebuilds and puts the scroll back where it was.
Opening a workout still starts at the top (go() resets the scroll first).
Usage: patch_keepscroll.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new, cnt=1):
    global s
    assert s.count(old) == cnt, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

rep('  function drawWorkoutPage(force) {\n',
    '''  /* Redraws never move him: hold the height, rebuild, put the scroll back, then release the height. */
  function drawWorkoutPage(force) {
    var sc = $("scroll"), body = $("wkp-body"), keep = state.page === "workout" && sc && body;
    if (!keep) return drawWorkoutPageNow(force);
    var t = sc.scrollTop, h = body.offsetHeight, ae = document.activeElement;
    // a focused button that is about to be rebuilt (like the set's remove button) is let go first, so Safari doesn't jump
    if (ae && ae !== document.body && body.contains(ae) && ae.tagName !== "INPUT" && ae.blur) ae.blur();
    body.style.minHeight = h + "px";
    try { drawWorkoutPageNow(force); } finally {
      sc.scrollTop = t;
      requestAnimationFrame(function () { body.style.minHeight = ""; if (Math.abs(sc.scrollTop - t) > 2 && sc.scrollHeight - sc.clientHeight >= t) sc.scrollTop = t; });
    }
  }
  function drawWorkoutPageNow(force) {
''')
# the delete/add path no longer needs its own scroll juggling, but keep the name working
rep('function redrawKeepScroll() { var sc = $("scroll"), t = sc.scrollTop; drawWorkoutPage(true); sc.scrollTop = t; }',
    'function redrawKeepScroll() { drawWorkoutPage(true); }')
# both confirm dialogs (Remove and the other one) hand focus back to the removed button's spot, not the top of the page
rep('''    function close() { back.remove(); try { if (prev && prev.focus && document.body.contains(prev)) prev.focus({ preventScroll: true }); } catch (e) {} }''',
    '''    function close() { var sc = $("scroll"), t = sc ? sc.scrollTop : 0; back.remove(); try { if (prev && prev.focus && document.body.contains(prev)) prev.focus({ preventScroll: true }); } catch (e) {} if (sc && sc.scrollTop !== t) sc.scrollTop = t; }''', 2)
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
