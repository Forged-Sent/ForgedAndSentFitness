#!/usr/bin/env python3
"""Switch every quoted verse in Forged & Sent to the ESV and add Crossway's notice.
Usage: patch_esv.py <in.html> <out.html> <esv.json> [version]"""
import sys, re, json
src, dst, esvf = sys.argv[1:4]; ver = sys.argv[4] if len(sys.argv) > 4 else None
s = open(src).read()
E = {k.replace('–', '-'): v for k, v in json.load(open(esvf)).items()}

def rep(old, new, count=1):
    global s
    assert s.count(old) == count, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

def smart(t):
    """Straight quotes to curly, capitalized start, and a clean full stop at the end."""
    out, dq = [], 0
    for i, ch in enumerate(t):
        prev = t[i - 1] if i else ' '
        if ch == '"':
            opening = prev in ' —(‘' or i == 0
            out.append('“' if opening else '”')
        elif ch == "'":
            if prev.isalpha() or prev in '.,!?': out.append('’')
            else: out.append('‘')
        else: out.append(ch)
    t = ''.join(out)
    # close an opening double quote that the verse range leaves open
    if t.count('“') > t.count('”'): t = re.sub(r'[,;:]?$', '', t) + ('' if t.endswith(('.', '!', '?')) else '.') + '”'
    t = re.sub(r'[,;:]$', '.', t)
    if not re.search(r'[.!?”’)]$', t): t += '.'
    m = re.match(r'^([“‘]?)([a-z])', t)
    if m: t = m.group(1) + m.group(2).upper() + t[m.end():]
    return t

# ---- the 366 devotionals
i = s.index('var DEVOS'); j = s.index('=', i) + 1
while s[j] == ' ': j += 1
D, n = json.JSONDecoder().raw_decode(s[j:])
orig = s[j:j + n]
changed = 0
for k, d in D['days'].items():
    r = d['ref'].replace('–', '-')
    assert r in E, r
    new = smart(E[r])
    if new != d['text']: d['text'] = new; changed += 1
newjson = json.dumps(D, ensure_ascii=False, separators=(',', ':'))
s = s[:j] + newjson + s[j + n:]
print('devotionals changed', changed)

# ---- labels
rep('$("d-ref").textContent = "— " + t.e.ref + " (BSB)";', '$("d-ref").textContent = "— " + t.e.ref + " (ESV)";')
rep('q.appendChild(el("cite", null, v[1] + " (BSB)"));', 'q.appendChild(el("cite", null, v[1] + " (ESV)"));')
rep('// One devotional per calendar date (MM-DD). Scripture: Berean Standard Bible (public domain).', '// One devotional per calendar date (MM-DD). Scripture: ESV (Crossway), quoted under its 500-verse permission.')
rep('"\\u201CCome with Me privately to a solitary place, and let us rest for a while.\\u201D Mark 6:31 (BSB)"',
    '"\\u201CCome away by yourselves to a desolate place and rest a while.\\u201D Mark 6:31 (ESV)"')

# ---- the Settings notice
rep('<p class="note" style="margin-top:0">Scripture quotations are from the Berean Standard Bible (BSB), which is in the public domain, except as noted below.</p>\n      <p class="note">1 Corinthians 16:13&ndash;14 on Today is from the ESV&reg; Bible (The Holy Bible, English Standard Version&reg;), &copy; 2001 by Crossway, a publishing ministry of Good News Publishers. Used by permission. All rights reserved.</p>',
    '<p class="note" style="margin-top:0">Scripture quotations are from the ESV&reg; Bible (The Holy Bible, English Standard Version&reg;), &copy; 2001 by Crossway, a publishing ministry of Good News Publishers. Used by permission. All rights reserved.</p>')

# ---- other places a verse is quoted
pairs = [
 ('\\u201CMan shall not live on bread alone, but on every word that comes from the mouth of God.\\u201D', '\\u201CMan shall not live by bread alone, but by every word that comes from the mouth of God.\\u201D'),
 ('"Be on the alert. Stand firm in the faith. Be men of courage. Be strong.", "1 Corinthians 16:13"', '"Be watchful, stand firm in the faith, act like men, be strong.", "1 Corinthians 16:13"'),
 ('"No, I discipline my body and make it my slave.", "1 Corinthians 9:27"', '"I discipline my body and keep it under control.", "1 Corinthians 9:27"'),
 ('"Whatever you do, work at it with your whole being, for the Lord and not for men.", "Colossians 3:23"', '"Whatever you do, work heartily, as for the Lord and not for men.", "Colossians 3:23"'),
 ('"As iron sharpens iron, so one man sharpens another.", "Proverbs 27:17"', '"Iron sharpens iron, and one man sharpens another.", "Proverbs 27:17"'),
 ('"Whoever is faithful with very little will also be faithful with much.", "Luke 16:10"', '"One who is faithful in a very little is also faithful in much.", "Luke 16:10"'),
 ('"Let us not grow weary in well-doing, for in due time we will reap a harvest if we do not give up.", "Galatians 6:9"', '"And let us not grow weary of doing good, for in due season we will reap, if we do not give up.", "Galatians 6:9"'),
 ('"Well done, good and faithful servant!", "Matthew 25:21"', '"Well done, good and faithful servant.", "Matthew 25:21"'),
 ('"Have I not commanded you to be strong and courageous? Do not be afraid; do not be discouraged, for the LORD your God is with you wherever you go.", "Joshua 1:9"', '"Have I not commanded you? Be strong and courageous. Do not be frightened, and do not be dismayed, for the LORD your God is with you wherever you go.", "Joshua 1:9"'),
 ('["For though a righteous man may fall seven times, he still gets up.", "Proverbs 24:16"]', '["For the righteous falls seven times and rises again.", "Proverbs 24:16"]'),
 ('["Therefore confess your sins to each other and pray for each other so that you may be healed.", "James 5:16"]', '["Therefore, confess your sins to one another and pray for one another, that you may be healed.", "James 5:16"]'),
 ('["Carry one another\\u2019s burdens, and in this way you will fulfill the law of Christ.", "Galatians 6:2"]', '["Bear one another\\u2019s burdens, and so fulfill the law of Christ.", "Galatians 6:2"]'),
]
for a, b in pairs: rep(a, b)

if ver:
    m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst, len(s))
