import sys
S = ''  # set to the folder that holds v256/app-v256.html and v257/add2.js
src = open(S + 'v256/app-v256.html', encoding='utf-8').read()
add = open(S + 'v257/add2.js', encoding='utf-8').read()
def rep(old, new, count=1):
    global src
    n = src.count(old)
    if n != count: sys.exit('expected %d, found %d: %r' % (count, n, old[:90]))
    src = src.replace(old, new)
rep('var APP_VERSION = "v256";', 'var APP_VERSION = "v257";')
rep('/* First-time setup */', '''/* v257: set timer, timed rounds, keypad */
#wkp-body .setrow[data-timed]:not(.one) { grid-template-columns: 52px minmax(0, 1fr) minmax(0, 1fr) 26px 78px; }
#wkp-body .sup-round .setrow[data-timed]:not(.one) { grid-template-columns: 96px minmax(0, 1fr) minmax(0, 1fr) 26px 78px; }
.st-go { min-height: 40px; min-width: 0; padding: 0 8px; font-size: 12px; border-color: var(--accent); color: var(--accent); white-space: nowrap; display: inline-flex; align-items: center; justify-content: center; gap: 5px; }
.st-ic { width: 17px; height: 17px; flex: none; }
#wkp-body .setrow .field { min-height: 38px !important; height: 38px; padding: 4px 8px !important; font-size: 16px; } /* 16px: a smaller box font makes iPhones zoom the page on focus */
#wkp-body .setrow .st-go { min-height: 38px; }
#wkp-body .setrow.rnd .setck-btn { min-height: 40px; min-width: 40px; }
#wkp-body .setrow:not(.one) { margin-top: 6px; }
#wkp-body .setrow.rnd:not(.one) { grid-template-columns: 70px minmax(0, 1fr) 78px 48px; } .setrow.rnd .sn { white-space: nowrap; }
.rnd-t { font-size: 13.5px; color: var(--muted); } .setrow.rnd.ok .rnd-t { color: var(--ink); }
.setrow.rnd.ok .setck-btn { background: var(--accent); border-color: var(--accent); color: var(--accent-ink); }
.rnd-n { margin: 6px 0 0; font-size: 12.5px; color: var(--muted); }
.st-ov { z-index: 170; align-items: center; padding-top: 16px; }
.st-box { border-color: var(--brass); text-align: center; align-items: stretch; gap: 8px; } .st-box.hold { border-color: var(--accent); }
.st-k { font-size: 12px; color: var(--muted); }
.st-l { font-family: var(--f-label); font-weight: 800; letter-spacing: .12em; text-transform: uppercase; font-size: 16px; color: var(--brass); } .st-box.hold .st-l { color: var(--accent); }
.st-big { font-family: var(--f-label); font-weight: 800; font-size: 112px; line-height: 1; font-variant-numeric: tabular-nums; padding: 10px 0; }
.st-sub { margin: 0; font-size: 13.5px; color: var(--muted); } .st-say { position: absolute; width: 1px; height: 1px; overflow: hidden; clip-path: inset(50%); }
.kp { position: fixed; left: 0; right: 0; bottom: 0; z-index: 60; background: var(--bg); border-top: 2px solid var(--accent); padding: 5px max(12px, env(safe-area-inset-right, 0px)) calc(6px + env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px)); display: flex; flex-direction: column; gap: 5px; box-shadow: 0 -8px 24px rgba(0,0,0,.35); }
.kp > * { width: 100%; max-width: 560px; margin: 0 auto; }
.kp-h { display: flex; align-items: baseline; gap: 10px; font-size: 12px; color: var(--muted); } .kp-h b { font-family: var(--f-label); font-weight: 800; font-size: 15px; letter-spacing: .04em; text-transform: uppercase; color: var(--ink); min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; } .kp-h span { flex: 1 1 auto; text-align: right; white-space: nowrap; }
.kp-x { flex: none; background: none; border: 0; min-height: 26px; padding: 0 2px; font-family: var(--f-label); font-weight: 700; letter-spacing: .1em; text-transform: uppercase; font-size: 12px; color: var(--muted); }
.kp-f { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; } .kp-f.one { grid-template-columns: 1fr; }
.kp-fld { display: flex; align-items: baseline; justify-content: space-between; gap: 8px; text-align: left; border: 1px solid var(--line); border-radius: var(--radius, 4px); background: var(--surface); padding: 4px 10px; min-height: 0; color: var(--ink); } .kp-fld.on { border: 2px solid var(--accent); padding: 3px 9px; }
.kp-fld span { font-family: var(--f-label); font-weight: 700; font-size: 10.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--muted); }
.kp-fld b { font-family: var(--f-label); font-weight: 800; font-size: 22px; line-height: 1.05; font-variant-numeric: tabular-nums; } .kp-fld b.e { color: var(--muted); opacity: .6; }
.kp-q { display: flex; gap: 6px; } .kp-qb { flex: 1 1 0; min-height: 30px; padding: 0 4px; border: 1px solid var(--line); border-radius: var(--radius, 4px); background: transparent; font-family: var(--f-label); font-weight: 700; font-size: 13px; color: var(--brass); white-space: nowrap; }
.kp-pad { display: grid; grid-template-columns: repeat(3, 1fr); gap: 5px; }
.kp-k { min-height: 38px; border: 0; border-radius: var(--radius, 4px); background: var(--surface-2); color: var(--ink); font-family: var(--f-label); font-weight: 700; font-size: 20px; } .kp-k.d { background: transparent; border: 1px solid var(--line); color: var(--muted); } .kp-k:disabled { opacity: .3; }
.kp-go { width: 100%; min-height: 42px; }
body.kp-on #scroll { padding-bottom: 340px; }
/* First-time setup */''')
rep('  function numField(cls, label, ph, val, max, onVal) {', add + '  function numField(cls, label, ph, val, max, onVal) {')
rep('''      var ex = el("div", "wx" + (e[2] ? " wx-add" : "")), ps = parseSets(e[1]);''', '''      var ex = el("div", "wx" + (e[2] ? " wx-add" : "")), ps = parseSets(e[1]), rd = ps ? null : stRounds(e[1]);''')
rep('''            } else row.appendChild(el("span"));
            ex.appendChild(row);''', '''            } else if (ps.time && !editing && isToday && !off && stSecs(ps.target)) {
              var tb = stGoBtn("Start the timer for " + lab + " of " + shownName);
              tb.addEventListener("click", function () {
                saveWkNow();
                openSetTimer({ title: shownName, label: lab, secs: stSecs(ps.target), sides: /per side|each side/i.test(e[1]), onDone: function (held) { s.r = held; saveWkNow(); drawWorkoutPage(true); stRest(idx); } });
              });
              row.appendChild(tb); row.dataset.timed = "1";
            } else row.appendChild(el("span"));
            Array.prototype.forEach.call(row.querySelectorAll("input"), function (q) { q.setAttribute("inputmode", "none"); });
            ex.appendChild(row);''')
rep('''        } else {
          var d0 = a[0], r0 = el("div", "setrow one"''', '''        } else if (rd) {
          drawRounds(ex, a, rd, { idx: idx, name: shownName, can: !editing && isToday && !off });
        } else {
          var d0 = a[0], r0 = el("div", "setrow one"''')
rep('''        else ex.appendChild(restBar(idx, e[2] ? e[3] :''', '''        else if (rd) { /* stretch rounds: no rest bar, he moves on when ready */ }
        else ex.appendChild(restBar(idx, e[2] ? e[3] :''')
rep('''    if (p !== "workout") { closeExPicker(); closeSwap(); }''', '''    if (p !== "workout") { closeExPicker(); closeSwap(); kpClose(); stClose(); }''')
rep('''    body.textContent = ""; $("wkp-date").textContent = longDate(key); paintClock(); loadWkHist();''', '''    kpClose(); body.textContent = ""; $("wkp-date").textContent = longDate(key); paintClock(); loadWkHist();''')
rep('''      var ae = document.activeElement, t = ev.target; if (!ae || !/^(INPUT|TEXTAREA|SELECT)$/.test(ae.tagName)) return;
      if (t && t.closest && t.closest("button, a, summary, [role=button]")''', '''      var ae = document.activeElement, t = ev.target; if (!ae || !/^(INPUT|TEXTAREA|SELECT)$/.test(ae.tagName)) return;
      if (t && t.closest && (t.closest("#kp") || t.closest("[class^=kp-], .kp-go"))) return;
      if (t && t.closest && t.closest("button, a, summary, [role=button]")''')
# Stop . Pain button removed from the lifts at the maintainer's direction of 2026-11-24. The check before a workout still asks about pain.
i = src.index('      if (live && !editing && isToday && !off && wk.loaded && !skipped) {\n        var spb = el("button", "mini sp-btn"'); j = src.index('      ex.appendChild(top);', i)
src = src[:i] + src[j:]
open(S + 'v257/app-v257.html', 'w', encoding='utf-8').write(src)
print('ok', len(src))
