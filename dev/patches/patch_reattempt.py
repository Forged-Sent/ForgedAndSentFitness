#!/usr/bin/env python3
"""After a submission the submit controls hide; Re-attempt on his latest tile brings them back with a Cancel.
Usage: patch_reattempt.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

rep('  var chalCur = null, chalForm = null;', '  var chalCur = null, chalForm = null, chalAgain = null;')
rep('  function openChallenge(id) { chalCur = id; chalForm = null; state.chalBr = null; go("chal"); }',
    '  function openChallenge(id) { chalCur = id; chalForm = null; chalAgain = null; state.chalBr = null; go("chal"); }')
# after a successful submit the controls hide again
rep('      proofKeep(c.id, []); chalForm = null; chalSave(c.id, list,', '      proofKeep(c.id, []); chalForm = null; chalAgain = null; chalSave(c.id, list,')

# Remove sits with a Re-attempt button on his newest tile (Re-attempt only while the controls are hidden)
rep('''        if (live) { var del = el("button", "mini", "Remove");''',
    '''        var acts = el("div", "ch-att-acts");
        if (live && ri === 0 && !(c.scoredBy === "completion") && chalAgain !== c.id && state.me && state.canWrite) { var ra = el("button", "mini on ch-again-btn", "Re-attempt"); ra.type = "button"; ra.addEventListener("click", function () { chalAgain = c.id; chalForm = null; drawChallengePage(); setTimeout(function () { var s0 = document.querySelector(".ch-again"); if (s0 && s0.scrollIntoView) s0.scrollIntoView({ block: "start", behavior: "smooth" }); }, 30); }); acts.appendChild(ra); }
        if (live) { var del = el("button", "mini", "Remove");''')
rep('''chalSave(c.id, s); }); }); r.appendChild(del); }''', '''chalSave(c.id, s); }); }); acts.appendChild(del); }
        if (acts.childNodes.length) r.appendChild(acts);''')

# hide the submit controls once he has a submission, unless he tapped Re-attempt
rep('''    if (!chalForm) chalForm = { mode: "standard", v: "", x: "", m: CH_MODES[0], note: "", files: [], busy: false, msg: "" };
''', '''    if (at.length && chalAgain !== c.id && !(chalForm && chalForm.busy)) {
      if (state.chalMsg) { var okm = el("p", "ch-ok", state.chalMsg); state.chalMsg = ""; var ps0 = body.querySelector(".ch-att"); if (ps0) ps0.parentNode.insertBefore(okm, ps0); else body.appendChild(okm); }
      return;
    }
    if (!chalForm) chalForm = { mode: "standard", v: "", x: "", m: CH_MODES[0], note: "", files: [], busy: false, msg: "" };
''')
# a Cancel bar on top of the re-attempt controls
rep('''      var pc = el("section", "ch-sec ch-rec");''', '''      var pc = el("section", "ch-sec ch-rec");
      if (chalAgain === c.id) {
        var ag = el("div", "ch-again"); ag.appendChild(el("span", "label-caps", "New attempt"));
        var cx = el("button", "mini", "Cancel"); cx.type = "button"; cx.disabled = !!chalForm.busy;
        cx.addEventListener("click", function () { if (chalSwInt) { clearInterval(chalSwInt); chalSwInt = null; } chalAgain = null; chalForm = null; proofKeep(c.id, []); drawChallengePage(); });
        ag.appendChild(cx); pc.insertBefore(ag, pc.firstChild);
      }''')
# the heading is replaced by the bar while re-attempting
rep('''    var sub = el("section", "ch-sec"); if (!(c.scoredBy === "completion" && at.length)) sub.appendChild(el("h2", "label-caps", at.length ? "Submit another attempt" : "Submit your result"));''',
    '''    var sub = el("section", "ch-sec"); if (!(c.scoredBy === "completion" && at.length) && !at.length) sub.appendChild(el("h2", "label-caps", "Submit your result"));''')

rep('.ch-att-t span { font-size: 13px; color: var(--muted); }', '''.ch-att-t span { font-size: 13px; color: var(--muted); }
.ch-att-acts { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.ch-again-btn { font-weight: 700; }
.ch-again { display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 8px 10px; border-left: 3px solid var(--accent); background: var(--surface); }
.ch-again .label-caps { font-size: 13px; color: var(--accent); }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
