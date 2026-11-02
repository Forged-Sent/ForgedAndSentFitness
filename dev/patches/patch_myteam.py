#!/usr/bin/env python3
"""Campaign tab, live: the line above your team read "Campaign 1 · Week 3 of 6 · dates" right under the page title
"Campaign", so Campaign showed twice. It now reads "My team", and the campaign/week/dates move inside the team card
(replacing "Your team"). Not on a team: the line reads "This campaign". Usage: patch_myteam.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''      box.appendChild(el("p", "label-caps cpg-wk", "Campaign " + n + " \u00B7 Week " + (w + 1) + " of " + CAMP_WEEKS + " \u00B7 " + campDateText(c.start) + " \u2013 " + campDateText(campEnd(c))));''',
    '''      var wkLine = "Campaign " + n + " \u00B7 Week " + (w + 1) + " of " + CAMP_WEEKS + " \u00B7 " + campDateText(c.start) + " \u2013 " + campDateText(campEnd(c));
      box.appendChild(el("h2", "label-caps cpg-sh", mine ? "My team" : "This campaign"));''')
rep('''mt.appendChild(el("span", "label-caps cmp-k acc", "Your team"));''', '''mt.appendChild(el("span", "label-caps cmp-k acc", wkLine));''')
rep('''ntx.appendChild(el("div", "label-caps cmp-k acc", "Not on a team"));''', '''ntx.appendChild(el("div", "label-caps cmp-k acc", wkLine));''')
rep('''.cpg-wk { color: var(--muted); margin: 0 0 10px; }''', '''.cpg-wk { color: var(--muted); margin: 0 0 10px; }
.cpg-sh { margin: 0 0 8px; }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
