#!/usr/bin/env python3
"""Pause a live workout: Pause/Resume in the sticky workout clock. Paused time is left out of the workout time,
rest timers freeze with it, and the workout dims until he resumes. Finishing while paused ends the pause first.
Saved on the log as pausedAt (when the current pause began, 0 if running) and pausedMs (total paused).
Usage: patch_pause.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new, cnt=1):
    global s
    assert s.count(old) == cnt, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- markup: the button sits on the right of the clock
rep('<div class="wk-clock" id="wk-clock" hidden aria-live="off"><span class="label-caps" id="wk-clock-l">Workout time</span><b id="wk-clock-t">0:00</b></div>',
    '<div class="wk-clock" id="wk-clock" hidden aria-live="off"><span class="label-caps" id="wk-clock-l">Workout time</span><b id="wk-clock-t">0:00</b>'
    '<button type="button" class="wk-pause" id="wk-pause" hidden><svg viewBox="0 0 24 24" aria-hidden="true"><path class="ic-pause" d="M8 5v14M16 5v14"/><path class="ic-play" d="M7 4.5v15l12.5-7.5z"/></svg><span id="wk-pause-l">Pause</span></button></div>')

# ---- saved fields
rep('      o.startedAt = Number(r.startedAt) || 0; o.finishedAt = Number(r.finishedAt) || 0;\n',
    '      o.startedAt = Number(r.startedAt) || 0; o.finishedAt = Number(r.finishedAt) || 0; o.pausedAt = Number(r.pausedAt) || 0; o.pausedMs = Number(r.pausedMs) || 0;\n')
rep('startedAt: Number(x.startedAt) || 0, finishedAt: Number(x.finishedAt) || 0, ex: {}, extra: normExtra(x.extra) };',
    'startedAt: Number(x.startedAt) || 0, finishedAt: Number(x.finishedAt) || 0, pausedAt: Number(x.pausedAt) || 0, pausedMs: Number(x.pausedMs) || 0, ex: {}, extra: normExtra(x.extra) };')

# ---- elapsed time leaves out paused time
rep('    var ms = src.finishedAt && src.startedAt ? src.finishedAt - src.startedAt : 0;',
    '    var ms = src.finishedAt && src.startedAt ? src.finishedAt - src.startedAt - (Number(src.pausedMs) || 0) : 0;')
rep('    var ms = rec.finishedAt && rec.startedAt ? rec.finishedAt - rec.startedAt : 0;',
    '    var ms = rec.finishedAt && rec.startedAt ? rec.finishedAt - rec.startedAt - (Number(rec.pausedMs) || 0) : 0;')

PAUSE = r'''  /* Pause: the clock stops, rest timers freeze, the workout dims. pausedMs is left out of the workout time. */
  function wkElapsed(r) { var end = r.finishedAt || r.pausedAt || Date.now(); return Math.max(0, end - r.startedAt - (Number(r.pausedMs) || 0)); }
  function wkFoldPause(r) { if (r && r.pausedAt) { r.pausedMs = (Number(r.pausedMs) || 0) + Math.max(0, Date.now() - r.pausedAt); r.pausedAt = 0; } }
  function wkPaused() { return !!(wk && wk.rec && wk.rec.startedAt && !wk.rec.finishedAt && wk.rec.pausedAt); }
  function wkPauseToggle() {
    var r = wk && wk.rec; if (!r || !r.startedAt || r.finishedAt) return;
    var now = Date.now();
    if (!r.pausedAt) {
      r.pausedAt = now;
      Object.keys(wk.timers || {}).forEach(function (k) { var t = wk.timers[k]; if (!t.running) return; t.left = Math.max(1, Math.ceil((t.endAt - now) / 1000)); t.running = false; t.cd = false; t.held = true; cancelTone(t); paintTimer(t); });
    } else {
      wkFoldPause(r);
      Object.keys(wk.timers || {}).forEach(function (k) { var t = wk.timers[k]; if (t.held) { t.held = false; timerStart(t); } });
    }
    saveWkNow(); paintClock(); startWkTick();
  }
'''
rep('  function paintClock() {', PAUSE + '  function paintClock() {')
rep('''    $("wk-clock-l").textContent = fin ? "Finished in" : "Workout time";
    $("wk-clock-t").textContent = fmtElapsed((fin ? r.finishedAt : Date.now()) - r.startedAt);''',
    '''    var pz = !fin && !!r.pausedAt, live = !fin && key === todayKey(); box.classList.toggle("paused", pz);
    $("wk-clock-l").textContent = fin ? "Finished in" : pz ? "Paused" : "Workout time";
    $("wk-clock-t").textContent = fmtElapsed(wkElapsed(r));
    var pb = $("wk-pause"); pb.hidden = !live; pb.classList.toggle("on", pz); $("wk-pause-l").textContent = pz ? "Resume" : "Pause";
    pb.setAttribute("aria-label", pz ? "Resume workout" : "Pause workout");
    var bd = $("wkp-body"); if (bd) { bd.classList.toggle("is-paused", pz); bd.inert = pz; }''')

# finishing while paused ends the pause first
rep('    if (wk.rec && !wk.rec.finishedAt) wk.rec.finishedAt = Date.now();',
    '    if (wk.rec && !wk.rec.finishedAt) { wkFoldPause(wk.rec); wk.rec.finishedAt = Date.now(); }')
rep('        if (wk && wk.rec) wk.rec.finishedAt = Date.now(); saveWkNow();',
    '        if (wk && wk.rec) { wkFoldPause(wk.rec); wk.rec.finishedAt = Date.now(); } saveWkNow();')

# wire the button once
rep('  function startWkTick() {', '  document.addEventListener("click", function (ev) { var b = ev.target && ev.target.closest && ev.target.closest("#wk-pause"); if (b) wkPauseToggle(); });\n  function startWkTick() {')

# ---- css
rep('.wk-clock.fin { border-left-color: var(--brass, #b08d57); }', '''.wk-clock.fin { border-left-color: var(--brass, #b08d57); }
.wk-clock { align-items: center; }
.wk-clock b { margin-left: auto; }
.wk-pause { display: inline-flex; align-items: center; gap: 6px; flex: none; min-height: 36px; padding: 0 12px; border: 1px solid var(--line); border-radius: 18px; background: var(--surface); color: var(--ink); font-family: var(--f-label); font-weight: 700; font-size: 13px; letter-spacing: .08em; text-transform: uppercase; cursor: pointer; }
.wk-pause svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 2.6; stroke-linecap: round; stroke-linejoin: round; }
.wk-pause .ic-play { display: none; fill: currentColor; stroke-width: 1.5; }
.wk-pause.on { background: var(--accent); border-color: var(--accent); color: #fff; }
.wk-pause.on .ic-pause { display: none; } .wk-pause.on .ic-play { display: inline; }
.wk-clock.paused { border-left-color: var(--brass, #b08d57); }
.wk-clock.paused b { color: var(--muted); }
.wk-clock .wk-pause span { font-size: 13px; letter-spacing: .08em; color: inherit; }
.wk-pause.on { color: #111; }
#wkp-body.is-paused { opacity: .4; filter: grayscale(.6); pointer-events: none; user-select: none; }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
