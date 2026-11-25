import sys
S = ''  # set to the folder that holds v259/app-v259.html and v260/add5.js
src = open(S + 'v259/app-v259.html', encoding='utf-8').read()
add = open(S + 'v260/add5.js', encoding='utf-8').read()
def rep(old, new, count=1):
    global src
    n = src.count(old)
    if n != count: sys.exit('expected %d, found %d: %r' % (count, n, old[:90]))
    src = src.replace(old, new)
rep('var APP_VERSION = "v259";', 'var APP_VERSION = "v260";')
rep('/* First-time setup */', '''/* v260: total lifted */
.tl { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 2px 12px; margin-top: 8px; padding: 8px 12px; border: 1px solid var(--line); border-radius: var(--radius, 4px); background: var(--surface); }
.tl.ask { border-style: dashed; } .tl.plain { border: 0; background: none; padding: 2px 0; }
.tl-l { display: flex; flex-direction: column; min-width: 0; } .tl-k { font-family: var(--f-label); font-weight: 700; letter-spacing: .14em; text-transform: uppercase; font-size: 11px; color: var(--muted); }
.tl-s { font-size: 12.5px; color: var(--muted); } .tl-v { font-family: var(--f-label); font-weight: 800; font-size: 22px; color: var(--accent); font-variant-numeric: tabular-nums; white-space: nowrap; }
.tl-a { font-size: 12.5px; color: var(--brass); text-align: right; } .tl-n { flex: 1 1 100%; font-size: 11.5px; color: var(--muted); }
/* First-time setup */''')
rep('  function numField(cls, label, ph, val, max, onVal) {', add + '  function numField(cls, label, ph, val, max, onVal) {', 1)
rep('''      } else if (Array.isArray(rec.ex[idx])) {
        var line = fmtSetLine(rec.ex[idx], ps && ps.time); if (line) ex.appendChild(el("span", "wlog", "Logged: " + line));
      }''', '''        if (!skipped) { var tlb = tlBox(function () { return rec.ex[idx]; }, mg, ps, p.equip, key); if (tlb) { ex.insertBefore(tlb, ex.querySelector(".rest")); TL_LIVE.push(tlb); } }
      } else if (Array.isArray(rec.ex[idx])) {
        var line = fmtSetLine(rec.ex[idx], ps && ps.time); if (line) ex.appendChild(el("span", "wlog", "Logged: " + line));
        var tlv = tlBox(function () { return rec.ex[idx]; }, mg, ps, p.equip, key); if (tlv) ex.appendChild(tlv);
      }''')
rep('''    if (KP) setTimeout(kpRelocate, 0); body.textContent = "";''', '''    if (KP) setTimeout(kpRelocate, 0); TL_LIVE = []; body.textContent = "";''')
open(S + 'v260/app-v260.html', 'w', encoding='utf-8').write(src)
print('ok', len(src))
