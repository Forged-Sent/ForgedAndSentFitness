#!/usr/bin/env python3
"""Challenge patches: a custom badge for every challenge (shape = slot, drawn icon = the challenge, ribbon = its number),
on the Train challenge cards (in place of 01/02/03) and big at the top of each challenge page.
Usage: patch_badges.py <in> <out> <version>"""
import sys, re, os
src, dst, ver = sys.argv[1:4]
s = open(src).read()
LIB = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'badges', 'chal-badges.js')).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('  function drawChallengeButtons() {', LIB + '  function drawChallengeButtons() {')
rep('      b.appendChild(el("span", "cb-n", pad(w.challenges.indexOf(c) + 1)));',
    '      var bdg = el("span", "cb-n cb-badge"); bdg.innerHTML = chalBadgeSvg(c, w.gauntlet); b.appendChild(bdg);')
rep('''    head.appendChild(el("div", "label-caps ch-k", slot.label + " · Week " + w.week + (w.gauntlet ? " · Gauntlet" : "")));
    head.appendChild(el("h1", "pg", c.name.replace(/^Gauntlet:\\s*/, "")));''',
    '''    var hb = el("div", "ch-hbadge"); hb.innerHTML = chalBadgeSvg(c, w.gauntlet); head.appendChild(hb); head.classList.add("has-badge");
    head.appendChild(el("div", "label-caps ch-k", slot.label + " · Week " + w.week + (w.gauntlet ? " · Gauntlet" : "")));
    head.appendChild(el("h1", "pg", c.name.replace(/^Gauntlet:\\s*/, "")));''')
CSS = '''
/* Challenge patches */
.chb { display: block; width: 100%; height: 100%; overflow: visible; --slotc: #7d8c45; --chb-ink: var(--ink); }
.chb-family { --slotc: var(--gold-2, #e0c46c); } .chb-endure { --slotc: #d0642f; } .chb-iron { --slotc: #8f9f50; }
.chb-fr { fill: #16130e; fill: color-mix(in srgb, var(--slotc) 14%, #14120d); stroke: var(--slotc); stroke-width: 2.6; stroke-linejoin: round; }
.chb-st { fill: none; stroke: var(--slotc); stroke-width: 1; stroke-dasharray: 2.2 2; opacity: .55; }
.chb-o { fill: none; stroke: var(--chb-ink); stroke-width: 1.9; stroke-linecap: round; stroke-linejoin: round; }
.chb-f { fill: var(--chb-ink); }
.chb-rib { fill: var(--slotc); }
.chb-tx { fill: #14120d; font-family: var(--f-label); font-weight: 800; letter-spacing: .03em; }
.chb-gold { fill: none; stroke: var(--gold-2, #e0c46c); stroke-width: 1.6; }
.chb-star { fill: var(--gold-2, #e0c46c); stroke: #14120d; stroke-width: .8; }
.chal-btn .cb-n.cb-badge { width: 52px !important; height: 52px !important; border: 0 !important; display: block !important; --chb-ink: #f1e9d2; }
.chal-btn .cb-n.cb-badge .chb { --chb-ink: #f1e9d2; }
.chal-btn { grid-template-columns: 52px 1fr auto !important; }
.ch-head.has-badge { display: grid; grid-template-columns: 84px 1fr; column-gap: 14px; align-items: center; }
.ch-head.has-badge .ch-hbadge { grid-row: 1 / span 2; width: 84px; height: 84px; }
.ch-head.has-badge .ch-hbadge .chb { --chb-ink: var(--hero-ink, #f1e9d2); }
.ch-head.has-badge > :not(.ch-hbadge) { grid-column: 2; min-width: 0; }
.ch-head.has-badge > .ch-desc { grid-column: 1 / -1; }
'''
rep('/* Devotional reading */', CSS + '/* Devotional reading */')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
