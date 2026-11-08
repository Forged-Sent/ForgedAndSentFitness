#!/usr/bin/env python3
"""Bodyweight lifts count the brother's body weight in training volume only (Curtis 2026-11-04, option 1).
A bodyweight set's volume = (most recent weigh-in on or before that day, else latest weigh-in, else Service record
weight) + any added weight, times reps. PRs and points are unchanged: they use liftStatsOf, not volOf.
Usage: patch_bwvol.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''  function volOf(rec, key, own) {
    if (!rec || !rec.ex) return 0;
    var wf = workoutFor(key), xs = normExtra(rec.extra).map(function (x) { return [x.g, x.rx]; });
    var exs = own ? xs : wf && wf.kind === "train" && wf.w ? wf.w.exercises.concat(xs) : null, tot = 0;
    Object.keys(rec.ex).forEach(function (k) {
      var arr = rec.ex[k]; if (!Array.isArray(arr)) return;
      var ps = exs && exs[+k] ? parseSets(exs[+k][1]) : null; if (ps && ps.time) return;
      arr.forEach(function (s) { if (!s || s.k === "w") return; var w = parseFloat(s.w), r = parseFloat(s.r); if (w > 0 && r > 0) tot += w * r; });''', '''  // Body weight for volume on a given day: latest weigh-in on or before it, else the latest one, else the Service record.
  function bwAsOf(key) {
    var m = weights(), ks = Object.keys(m).filter(function (k) { return Number(m[k]) > 0; }).sort(), on = ks.filter(function (k) { return k <= key; });
    var k = on.length ? on[on.length - 1] : ks[ks.length - 1]; if (k) return Number(m[k]);
    var b = state.settings && state.settings.body; return b && Number(b.wt) > 0 ? Number(b.wt) : 0;
  }
  function volOf(rec, key, own) {
    if (!rec || !rec.ex) return 0;
    var wf = workoutFor(key), xs = normExtra(rec.extra).map(function (x) { return [x.g, x.rx]; });
    var exs = own ? xs : wf && wf.kind === "train" && wf.w ? wf.w.exercises.concat(xs) : null, tot = 0, eq = (planCfg() || {}).equip, bwk = null;
    Object.keys(rec.ex).forEach(function (k) {
      var arr = rec.ex[k]; if (!Array.isArray(arr)) return;
      var ps = exs && exs[+k] ? parseSets(exs[+k][1]) : null; if (ps && ps.time) return;
      var g = exs && exs[+k] ? exs[+k][0] : null; if (g && !own && wf && wf.w && +k < wf.w.exercises.length) { try { g = effMove(rec, +k, g); } catch (e) {} }
      var isBw = false; try { isBw = !!g && !needsWeight(g, eq); } catch (e) { isBw = false; }
      if (isBw && bwk === null) bwk = bwAsOf(key) || 0;
      arr.forEach(function (s) { if (!s || s.k === "w") return; var w = parseFloat(s.w), r = parseFloat(s.r); if (isBw) w = (w > 0 ? w : 0) + bwk; if (w > 0 && r > 0) tot += w * r; });''')
rep('''don\\u2019t enter a weight. Leave the + box empty unless you add weight with a vest, belt or plate, and then enter only that added weight.",''',
    '''don\\u2019t enter a weight. Your training volume counts your most recent weigh-in for you. Leave the + box empty unless you add weight with a vest, belt or plate, and then enter only that added weight. PRs on these lifts still come from reps and added weight.",''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
