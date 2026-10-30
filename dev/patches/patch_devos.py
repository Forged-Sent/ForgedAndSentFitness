#!/usr/bin/env python3
"""Daily devotionals: load Curtis's updated set (366 days). Each day gains a headline, an "In Jesus" section
(between Reading and Reflect) and Sent / Spirit-led tags. February's Accelerate Your Marriage series labels are kept.
Usage: patch_devos.py <in> <out> <version> <devos.json>"""
import sys, re, json
src, dst, ver, dj = sys.argv[1:5]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

N = json.load(open(dj))
i = s.index('var DEVOS = ') + len('var DEVOS = ')
D, n = json.JSONDecoder().raw_decode(s[i:])
mon = {m['name']: int(k) for k, m in D['months'].items()}
days = {}
for x in N:
    k = '%02d-%02d' % (mon[x['month']], int(x['day']))
    assert k not in days, k
    ref = re.sub(r'\s*\(ESV\)\s*$', '', x['reference']).replace('Song Of Songs', 'Song of Songs')
    e = {"headline": x['headline'].strip(), "prayer": x['prayer'].strip(), "ref": ref, "text": x['reading'].strip(),
         "jesus": x['in_jesus'].strip(), "reflect": x['reflect'].strip(), "act": x['act'].strip()}
    if x.get('sent'): e['sent'] = True
    if x.get('spirit'): e['spirit'] = True
    old = D['days'].get(k, {})
    if old.get('series'): e['series'] = old['series']
    days[k] = e
assert set(days) == set(D['days']), set(D['days']) ^ set(days)
D['days'] = days
s = s[:i] + json.dumps(D, ensure_ascii=False, separators=(',', ':')) + s[i + n:]

# ---- markup
rep('        <p class="devo-series" id="devo-series" hidden></p>',
    '        <p class="devo-series" id="devo-series" hidden></p>\n        <p class="devo-hl" id="devo-hl" hidden></p>\n        <div class="devo-tags" id="devo-tags" hidden></div>')
rep('<section class="d-sec"><h2 class="d-lbl">Reflect</h2>',
    '<section class="d-sec" id="d-jesus-sec"><h2 class="d-lbl">In Jesus</h2><p id="d-jesus"></p></section>\n      <section class="d-sec"><h2 class="d-lbl">Reflect</h2>')

# ---- draw
rep('''    var dsr = $("devo-series"); if (dsr) { dsr.textContent = t.e.series || ""; dsr.hidden = !t.e.series; }''',
    '''    var dsr = $("devo-series"); if (dsr) { dsr.textContent = t.e.series || ""; dsr.hidden = !t.e.series; }
    var hl = $("devo-hl"); hl.textContent = t.e.headline || ""; hl.hidden = !t.e.headline;
    var tg = $("devo-tags"); tg.textContent = "";
    if (t.e.sent) { var a = el("span", "devo-tg sent"); a.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12h13M12 6l6 6-6 6"/></svg>'; a.appendChild(el("span", null, "Sent: take it to someone")); tg.appendChild(a); }
    if (t.e.spirit) { var b2 = el("span", "devo-tg spirit"); b2.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3c2.5 3 4.5 5.3 4.5 8.5a4.5 4.5 0 0 1-9 0c0-1.6.7-2.9 1.6-4 .3 1.4 1 2.3 2 2.6C11 8 11.2 5.5 12 3z"/></svg>'; b2.appendChild(el("span", null, "Spirit-led")); tg.appendChild(b2); }
    tg.hidden = !tg.childNodes.length;''')
rep('    $("d-reflect").textContent = t.e.reflect; $("d-act").textContent = t.e.act;',
    '    $("d-jesus").textContent = t.e.jesus || ""; $("d-jesus-sec").hidden = !t.e.jesus;\n    $("d-reflect").textContent = t.e.reflect; $("d-act").textContent = t.e.act;')

# ---- css
rep('.devo-end{margin-top:auto;', '''.devo-hl{margin:2px 0 4px;font-family:var(--f-display);font-weight:700;font-size:22px;line-height:1.15;text-transform:uppercase;letter-spacing:.01em;color:var(--ink);text-wrap:balance}
.devo-head.hero .devo-hl{color:var(--hero-ink) !important}
.devo-tags{display:flex;flex-wrap:wrap;gap:6px;margin:2px 0 4px}
.devo-tg{display:inline-flex;align-items:center;gap:5px;min-height:26px;padding:0 10px;border-radius:13px;font-family:var(--f-label);font-weight:700;font-size:12px;letter-spacing:.08em;text-transform:uppercase;border:1px solid currentColor}
.devo-tg svg{width:14px;height:14px;fill:none;stroke:currentColor;stroke-width:2.2;stroke-linecap:round;stroke-linejoin:round}
.devo-tg.sent{color:var(--accent)}
.devo-tg.spirit{color:var(--gold-2,var(--brass))}
.devo-head.hero .devo-tg.sent{color:var(--accent) !important}
#d-jesus{border-left:4px solid var(--accent);padding-left:14px}
.devo-end{margin-top:auto;''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst, len(days))
