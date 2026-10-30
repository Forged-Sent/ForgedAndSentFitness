#!/usr/bin/env python3
"""Challenges: every Standard submission scores 25-50 against the bracket leader (floor = 30% off the leader),
4 tier lines with 'X to the next tier', Alternate/Scaled flat 25, proof optional (honor system).
Usage: patch_tiers.py <in> <out> <version>"""
import sys, re, json
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- config
i = s.index('var CHAL = ') + len('var CHAL = ')
C, n = json.JSONDecoder().raw_decode(s[i:])
st = C['scoring']['standard']
st['maxPoints'] = 50; st['minPoints'] = 25; st['floorPct'] = 0.3; st['tiers'] = 4; st['belowTargetPoints'] = 25
st['formula'] = {"note": "Leader in the bracket = 50. Floor = 30% off the leader. Between: 50 - 25 x gap / span. Every submission scores at least 25."}
C['scoring']['scaled']['completionPoints'] = 25; C['scoring']['scaled']['maxPoints'] = 25
C['scoring']['proofRequired'] = False
s = s[:i] + json.dumps(C, ensure_ascii=False, separators=(',', ':')) + s[i + n:]

# ---- scoring: every standard result is ranked and scored between min and max
rep('      if (best && chalQualifies(c, best)) (groups[row.g] = groups[row.g] || []).push(row);',
    '      if (best) (groups[row.g] = groups[row.g] || []).push(row);')
old_start = '    var lower = chalLowerBetter(c), roundTo = CHAL.scoring.standard.rounding || 1;'
i = s.index(old_start); j = s.index('    return rows;\n  }', i)
s = s[:i] + r'''    var lower = chalLowerBetter(c), roundTo = CHAL.scoring.standard.rounding || 1, sd = CHAL.scoring.standard, top = sd.maxPoints || 50, minP = sd.minPoints || 25, pct = sd.floorPct || 0.3;
    Object.keys(groups).forEach(function (g) {
      var list = groups[g], vals = list.map(function (r) { return chalRaw(c, r.best); });
      var lead = lower ? Math.min.apply(null, vals) : Math.max.apply(null, vals), floorV = lower ? lead * (1 + pct) : lead * (1 - pct), span = Math.abs(floorV - lead);
      list.forEach(function (r) {
        var v = chalRaw(c, r.best), gap = lower ? v - lead : lead - v, sc = span > 0 ? top - (top - minP) * gap / span : top;
        r.score = Math.max(minP, Math.min(top, Math.round(sc / roundTo) * roundTo)); r.n = list.length; r.lead = lead; r.floorV = floorV;
      });
      list.sort(function (a, b) { return lower ? chalRaw(c, a.best) - chalRaw(c, b.best) : chalRaw(c, b.best) - chalRaw(c, a.best); });
      var prev = null, rank = 0; list.forEach(function (r, i) { var v = chalRaw(c, r.best); if (v !== prev) { rank = i + 1; prev = v; } r.rank = rank; });
    });
    rows.forEach(function (r) {
      var flatPts = r.flat ? (c.scoredBy === "completion" ? CHAL.scoring.family.completionPoints : CHAL.scoring.scaled.completionPoints) : 0;
      r.pts = Math.max(flatPts, r.best ? (r.score || minP) : 0);
    });
''' + s[j:]

# ---- tier lines and distance to the next tier
TIERS = r'''  /* Tier lines for a bracket: evenly spaced from the leader (max points) to the floor (min points). */
  function chalTiers(c, lead, floorV) {
    var sd = CHAL.scoring.standard, top = sd.maxPoints || 50, minP = sd.minPoints || 25, k = Math.max(2, sd.tiers || 4), lower = chalLowerBetter(c), out = [];
    for (var t = 0; t < k; t++) {
      var v = lead + (floorV - lead) * t / (k - 1);
      v = c.scoredBy === "fastest_time" ? (lower ? Math.ceil(v) : Math.floor(v)) : c.scoredBy === "longest_hold" || c.scoredBy === "most_reps" || c.scoredBy === "highest_total" ? Math.ceil(v) : Math.round(v * 100) / 100;
      out.push({ pts: Math.round(top - (top - minP) * t / (k - 1)), v: v });
    }
    return out;
  }
  function chalGapText(c, d) {
    if (c.scoredBy === "fastest_time" || c.scoredBy === "longest_hold") { d = Math.ceil(d); return d < 60 ? d + " sec" : clockOf(d); }
    if (c.scoredBy === "most_reps") { d = Math.ceil(d); return d + (d === 1 ? " rep" : " reps"); }
    if (c.scoredBy === "greatest_distance") return fmtW(Math.round(d * 100) / 100) + " mi";
    return fmt(Math.ceil(d));
  }
  function chalTierBox(host, c, rowsInGroup) {
    if (!rowsInGroup.length || c.scoredBy === "most_rounds") return;
    var r0 = rowsInGroup[0], tiers = chalTiers(c, r0.lead, r0.floorV), lower = chalLowerBetter(c), box = el("div", "ch-tiers");
    box.appendChild(el("div", "ch-tiers-h", "Point lines in this bracket"));
    tiers.forEach(function (t, k) {
      var row = el("div", "ch-tier"), last = k === tiers.length - 1, txt = chalResultText(c, { mode: "standard", v: t.v });
      row.appendChild(el("b", null, t.pts + " pts"));
      row.appendChild(el("span", null, k === 0 ? txt + " (the leader)" : last ? txt + (lower ? " or slower" : " or less") + ". Every finisher scores at least this." : txt + (lower ? " or faster" : " or more")));
      box.appendChild(row);
    });
    var me = rowsInGroup.filter(function (r) { return r.uid === state.me; })[0];
    if (me && me.best) {
      var v = chalRaw(c, me.best), next = null;
      for (var k2 = tiers.length - 1; k2 >= 0; k2--) { var t2 = tiers[k2]; if (t2.pts > me.score && (lower ? v > t2.v : v < t2.v)) { next = t2; break; } }
      var nx = el("p", "ch-next");
      if (!next || me.score >= (CHAL.scoring.standard.maxPoints || 50)) nx.textContent = "You hold the top line in your bracket.";
      else nx.textContent = "You: " + me.score + " pts. " + chalGapText(c, Math.abs(v - next.v)) + " " + (lower ? "faster" : "more") + " reaches the " + next.pts + "-point line.";
      box.appendChild(nx);
    }
    host.appendChild(box);
  }
'''
rep('  function chalModeLabel(m) {', TIERS + '  function chalModeLabel(m) {')
rep('        var bd = el("div", "board");\n        groups[state.chalBr]',
    '        chalTierBox(stS, c, groups[state.chalBr]);\n        var bd = el("div", "board");\n        groups[state.chalBr]')

# ---- words
rep('ranked ? "Ranked in your age bracket. Up to " + CHAL.scoring.standard.maxPoints + " points."', 'ranked ? "Ranked in your age bracket. " + CHAL.scoring.standard.minPoints + " to " + CHAL.scoring.standard.maxPoints + " points."')
old_how = s[s.index('      how.appendChild(el("li", null, "Standard: the best result in your age bracket scores " + CHAL.scoring.standard.maxPoints'):]
k = old_how.index('    } else how.appendChild(el("li", null, "Complete it for "')
old_how = old_how[:k]
rep(old_how, '''      how.appendChild(el("li", null, "Standard: the best result in your age bracket scores " + CHAL.scoring.standard.maxPoints + ". Everyone else scores between " + CHAL.scoring.standard.minPoints + " and " + CHAL.scoring.standard.maxPoints + ": the closer you are to the leader, the more you get. " + Math.round(100 * (CHAL.scoring.standard.floorPct || 0.3)) + "% or more off the leader scores " + CHAL.scoring.standard.minPoints + "."));
      how.appendChild(el("li", null, "Every man who submits scores. The target is the goal, not a cutoff."));
      how.appendChild(el("li", null, "Alternate or Scaled: a flat " + CHAL.scoring.scaled.completionPoints + " points, not ranked. If you do both, your higher score counts."));
      how.appendChild(el("li", null, "Your best attempt counts. Ties get the same score. If you're the only man in your bracket, you score " + CHAL.scoring.standard.maxPoints + ". Scores can move until the deadline as brothers post."));
      how.appendChild(el("li", null, "Honor system: proof is optional. Add a photo or video if you want the brothers to see it."));
''')
rep('row("Points", ranked ? "Standard: up to " + CHAL.scoring.standard.maxPoints + " · Alternate or Scaled: " + CHAL.scoring.scaled.completionPoints',
    'row("Points", ranked ? "Standard: " + CHAL.scoring.standard.minPoints + " to " + CHAL.scoring.standard.maxPoints + " · Alternate or Scaled: " + CHAL.scoring.scaled.completionPoints')
rep('"Iron builds strength and Endure builds your engine. Do the Standard version and you\'re scored 0 to 50 against the best result in your age bracket. The leader gets 50.",',
    '"Iron builds strength and Endure builds your engine. Do the Standard version and you score 25 to 50 against the best result in your age bracket. The leader gets 50, and every man who submits gets at least 25.",')
rep('"Enter your score and add a photo or video as proof. Proof is required, like a screenshot of your mile run showing distance and time. You can submit more than once. Your best attempt counts.",',
    '"Enter your score. It\'s on your honor: a photo or video is optional, and brothers can tap the icon by your name to see it. You can submit more than once. Your best attempt counts.",')
rep('"Alternate (for injuries) and Scaled earn a flat 25 points and aren\'t ranked.",', '"Alternate (for injuries) and Scaled earn a flat 25 points and aren\'t ranked.",')

# ---- proof optional
rep('      if (!isFam && !F.files.length) { F.msg = "Add a photo or video as proof. A screenshot from your watch or app works."; drawChallengePage(); return; }\n', '')
rep('go2.disabled = F.busy || (!canUp && !isFam); form.appendChild(go2);', 'go2.disabled = F.busy; form.appendChild(go2);')
rep('pc.appendChild(el("p", "error", "Photo and video uploads aren’t available here, and proof is required to submit. Try again from your phone."));',
    'pc.appendChild(el("p", "fnote", "Photo and video uploads aren’t available here. Proof is optional, so you can still submit your result."));')
rep('Proof (required)', 'Proof (optional)')
rep('"Film it here, or upload videos and photos you already took. Pick several at once, up to " + CHMAX + " (videos up to 3 minutes each)."',
    '"Optional, on your honor. Film it here or upload videos and photos you already took, up to " + CHMAX + " (videos up to 3 minutes each)."')

# ---- css
rep('.ch-rec-cap { margin: 0; }', '''.ch-rec-cap { margin: 0; }
.ch-tiers { border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: var(--radius, 4px); padding: 8px 10px; margin: 0 0 10px; background: var(--surface); }
.ch-tiers-h { font-family: var(--f-label); font-weight: 700; font-size: 12px; letter-spacing: .1em; text-transform: uppercase; color: var(--muted); margin-bottom: 4px; }
.ch-tier { display: grid; grid-template-columns: 58px minmax(0, 1fr); gap: 8px; padding: 4px 0; border-top: 1px dashed var(--line); font-size: 13.5px; align-items: baseline; }
.ch-tier:first-of-type { border-top: 0; }
.ch-tier b { font-family: var(--f-label); color: var(--accent); }
.ch-tier span { min-width: 0; overflow-wrap: anywhere; }
.ch-next { margin: 6px 0 0; font-size: 13.5px; font-weight: 600; color: var(--ink); }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
