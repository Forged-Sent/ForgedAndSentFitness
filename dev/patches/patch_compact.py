#!/usr/bin/env python3
"""Challenge result form sized down; play/stop glyphs become drawn icons (no emoji). Usage: patch_compact.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new, n=1):
    global s
    assert s.count(old) == n, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- drawn icons
ICONS = r'''  /* Drawn icons so iPhones never swap in emoji. */
  var IC_PLAY = '<svg class="ic" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l10.5-6.5z"/></svg>';
  var IC_WATCH = '<svg class="ic ic-w" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"/><path d="M12 13.5V9.5M10 2.5h4M12 2.5V6M18.2 6.8l1.4-1.4"/></svg>';
  var IC_STOP = '<svg class="ic" viewBox="0 0 24 24" aria-hidden="true"><rect x="6.5" y="6.5" width="11" height="11" rx="1.5"/></svg>';
  function icSpan(cls, svg) { var sp = el("span", cls); sp.innerHTML = svg; return sp; }
'''
rep('  function drawChallengePage() {', ICONS + '  function drawChallengePage() {')

# challenge stopwatch button
rep('        swb.textContent = F.sw.run ? "■ Stop timer" : (F.mm || F.ss ? "▶ Start over" : "▶ Start timer");',
    '        swb.innerHTML = F.sw.run ? IC_STOP : IC_WATCH; swb.appendChild(el("span", null, F.sw.run ? "Stop timer" : (F.mm || F.ss ? "Start over" : "Start timer")));')
# exercise name link, warm-up timer, exercise thumbnail, video page
rep('        nb.appendChild(el("span", "pl", "▶︎")); nb.appendChild(el("span", null, shown));', '        nb.appendChild(icSpan("pl", IC_PLAY)); nb.appendChild(el("span", null, shown));')
rep('tb.appendChild(el("span", "wu-play", "▶︎")); tb.appendChild(tl);', 'tb.appendChild(icSpan("wu-play", IC_PLAY)); tb.appendChild(tl);')
rep('        if (moveVideo(mg)) th0.appendChild(el("span", "pl", "\\u25B6\\uFE0E"));', '        if (moveVideo(mg)) th0.appendChild(icSpan("pl", IC_PLAY));')
rep('      a.appendChild(el("span", "vd-pb", "\\u25B6\\uFE0E"));', '      a.appendChild(icSpan("vd-pb", IC_PLAY));')

# ---- compact sizes
rep('.ch-vers button { flex: 1 1 0; min-height: 54px;', '.ch-vers button { flex: 1 1 0; min-height: 40px;')
CSS = '''
/* Challenge result form: compact */
.ch-vers button { font-size: 14px; }
.ch-bigrow { gap: 8px; }
.ch-bigl { gap: 4px; }
.ch-bigcap { font-size: 11px; }
.ch-big { height: 52px; font-size: 26px; border-width: 1.5px; }
.ch-colon { padding-bottom: 12px; font-size: 22px; }
.ch-sw { min-height: 44px; font-size: 14px; border-width: 1.5px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; }
.ch-form > .btn[type="submit"] { min-height: 48px; font-size: 15px; }
.ch-form textarea.field { min-height: 64px; }
.ic { width: 1em; height: 1em; display: block; fill: currentColor; }
.ic-w { fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; }
.ch-sw .ic { width: 18px; height: 18px; }
.ch-sw .ic:not(.ic-w) { fill: currentColor; }
.wu-play .ic { width: 14px; height: 14px; }
.wlink .pl .ic { width: 12px; height: 12px; }
.ex-thumb .pl .ic { width: 9px; height: 9px; margin-left: 1px; }
.vd-pb .ic { width: 22px; height: 22px; margin-left: 2px; }
.wu-play, .wlink .pl { display: inline-grid; place-items: center; }
'''
rep('.ch-form > .btn[type="submit"] { min-height: 60px; font-size: 17px; }', '.ch-form > .btn[type="submit"] { min-height: 60px; font-size: 17px; }' + CSS)
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
