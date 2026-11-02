#!/usr/bin/env python3
"""Settings leaves the bottom bar (6 tabs: Today, Fuel, Train, Board, Campaign, Rally). Settings opens from your
profile: tap your picture at the top of any page, then the labeled Settings button. The tour mentions it and gains a
Campaign stop. Requested by Curtis 2026-11-01. Usage: patch_nosettab.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
m = re.search(r'\n  <button type="button" data-page="settings">.*?Settings</button>', s); assert m; s = s.replace(m.group(0), '')
rep('''  display: grid; grid-template-columns: repeat(7, minmax(0, 1fr));''', '''  display: grid; grid-template-columns: repeat(6, minmax(0, 1fr));''')
rep('''@media (max-width: 430px) { .tabbar.tabbar button { font-size: 9.5px; letter-spacing: 0; } .tabbar.tabbar svg { width: 22px; height: 22px; } }''',
    '''@media (max-width: 430px) { .tabbar.tabbar button { font-size: 10.5px; letter-spacing: .02em; } }''')
# labeled Settings button on your own profile
m = re.search(r'<button class="icon-btn" type="button" id="prof-gear" aria-label="Settings">(<svg.*?</svg>)</button>', s); assert m
s = s.replace(m.group(0), '<button class="mini prof-set" type="button" id="prof-gear">' + m.group(1) + 'Settings</button>')
rep('''.icon-btn{width:44px;height:44px;''', '''.prof-set{display:inline-flex;align-items:center;gap:6px}.prof-set svg{width:18px;height:18px;stroke:currentColor;stroke-width:2;fill:none;stroke-linecap:square}
.icon-btn{width:44px;height:44px;''')
# tour
rep('''["board", "Board", ["Kingdom Warrior ranks the men by points: Today, This week and All time.", "Use the menu to see top PRs on each lift.", "Tap How points work for the full breakdown."]],''',
    '''["board", "Board", ["Kingdom Warrior ranks the men by points: Today, This week and All time.", "Individual and Campaign buttons switch boards. The menu shows top PRs on each lift.", "Tap How points work for the full breakdown."]],
    ["camp", "Campaign", ["Team battles of 6 to 8 men for 6 weeks. Raise a banner or answer a captain\\u2019s invite.", "Your team, Wall Held, this week\\u2019s double points and team chat live here.", "Standings and points stay on the Board."]],''')
rep('''"Keep it real. No judgment, no gossip."]]''', '''"Keep it real. No judgment, no gossip.", "Settings: tap your picture at the top of any page, then Settings."]]''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
