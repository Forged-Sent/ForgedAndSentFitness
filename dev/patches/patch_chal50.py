#!/usr/bin/env python3
"""Challenges: Standard tops out at 50 (was 100); Alternate/Scaled pay a flat 25 (was 50). Family stays 50.
Usage: patch_chal50.py <in> <out> <version>"""
import sys, re, json
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- the challenge data
i = s.index('var CHAL = ') + len('var CHAL = ')
C, n = json.JSONDecoder().raw_decode(s[i:])
sc = C['scoring']
sc['standard']['maxPoints'] = 50
sc['standard']['formula'] = {"higherIsBetter": "50 * result / leaderResult", "lowerIsBetter": "50 * leaderResult / result"}
sc['scaled']['completionPoints'] = 25; sc['scaled']['maxPoints'] = 25
sc['soloBracketScores'] = 50
sc['maxWeek'] = {"allStandard": sc['family']['completionPoints'] + 50 + 50, "allScaled": sc['family']['completionPoints'] + 25 + 25}
changed = 0
for w in C['weeks']:
    for c in w['challenges']:
        if c['slot'] in ('iron', 'endure') and c.get('points') == 100: c['points'] = 50; changed += 1
s = s[:i] + json.dumps(C, ensure_ascii=False, separators=(',', ':')) + s[i + n:]
print('challenges set to 50:', changed, 'maxWeek', sc['maxWeek'])

# ---- scoring math uses the configured top score
rep('sc = lower ? 100 * lead / v : 100 * v / lead; r.score = Math.max(0, Math.min(100, Math.round(sc / roundTo) * roundTo));',
    'top = CHAL.scoring.standard.maxPoints || 50, sc = lower ? top * lead / v : top * v / lead; r.score = Math.max(0, Math.min(top, Math.round(sc / roundTo) * roundTo));')
rep('fl.style.width = r.score + "%";', 'fl.style.width = Math.round(100 * r.score / (CHAL.scoring.standard.maxPoints || 50)) + "%";')

# ---- words
rep('ranked ? "Ranked in your age bracket. Up to 100 points."', 'ranked ? "Ranked in your age bracket. Up to " + CHAL.scoring.standard.maxPoints + " points."')
rep('"Standard: the best result in your age bracket scores 100. Everyone else scores against him: " + (chalLowerBetter(c) ? "100 \\u00D7 leader\'s time \\u00F7 your time." : "100 \\u00D7 your result \\u00F7 the leader\'s result.")',
    '"Standard: the best result in your age bracket scores " + CHAL.scoring.standard.maxPoints + ". Everyone else scores against him: " + (chalLowerBetter(c) ? CHAL.scoring.standard.maxPoints + " \\u00D7 leader\'s time \\u00F7 your time." : CHAL.scoring.standard.maxPoints + " \\u00D7 your result \\u00F7 the leader\'s result.")')
rep('If you\'re the only man in your bracket, you score 100."', 'If you\'re the only man in your bracket, you score " + CHAL.scoring.standard.maxPoints + "."')
rep('row("Points", ranked ? "Standard: up to 100 · Alternate or Scaled: 50"', 'row("Points", ranked ? "Standard: up to " + CHAL.scoring.standard.maxPoints + " · Alternate or Scaled: " + CHAL.scoring.scaled.completionPoints')
rep('"Iron builds strength and Endure builds your engine. Do the Standard version and you\'re scored 0 to 100 against the best result in your age bracket. The leader gets 100.",',
    '"Iron builds strength and Endure builds your engine. Do the Standard version and you\'re scored 0 to 50 against the best result in your age bracket. The leader gets 50.",')
rep('"Alternate (for injuries) and Scaled earn a flat 50 points and aren\'t ranked.",', '"Alternate (for injuries) and Scaled earn a flat 25 points and aren\'t ranked.",')
rep('/* Scoring: Family, Scaled and Alternate earn a flat 50. Standard Iron and Endure earn 0-100 against the\n     best result in the man\'s age bracket (100 x result / leader, or leader / result for time). */',
    '/* Scoring: Family earns a flat 50, Scaled and Alternate a flat 25. Standard Iron and Endure earn 0-50 against the\n     best result in the man\'s age bracket (50 x result / leader, or leader / result for time). */')

# anything else still promising 100 challenge points?
left = [m.start() for m in re.finditer(r'(?i)(up to 100|scores 100|0 to 100|flat 50 points)', s)]
print('leftover 100-point phrases:', len(left))
for p in left[:5]: print('  ', s[p-80:p+40].replace('\n', ' '))
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
