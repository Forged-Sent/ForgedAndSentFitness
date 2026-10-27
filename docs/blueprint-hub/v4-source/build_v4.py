"""Build Planning Hub v4 from the published v3 page (index.html is canonical)."""
import pathlib, re, sys
HERE = pathlib.Path(__file__).parent
src = pathlib.Path(sys.argv[1]); out = pathlib.Path(sys.argv[2])
t = src.read_text()

def sub(old, new, count=1):
    global t
    assert old in t, "missing: " + old[:100]
    t = t.replace(old, new, count)

def cut(start, end, new):
    """Replace from start marker (inclusive) to end marker (exclusive)."""
    global t
    a = t.index(start); b = t.index(end, a)
    t = t[:a] + new + t[b:]

# ---- head ----
sub('<title>Forged &amp; Sent Blueprint</title>', '<title>Forged &amp; Sent Planning Hub</title>')
sub('<script src="https://cdn.jsdelivr.net/npm/marked@12.0.2/marked.min.js"></script>',
    '<script src="https://cdn.jsdelivr.net/npm/marked@12.0.2/marked.min.js"></script>\n<script src="https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js"></script>')
sub('/* Diagrams and review */', '''/* Planning hub v4 */
.pill.st-new { background: var(--sunk); color: var(--muted); }
.pill.st-discussing, .pill.st-deferred { background: var(--info-soft); color: var(--info); }
.pill.st-needs_decision { background: var(--warn-soft); color: var(--warn); }
.pill.st-approved, .pill.st-implemented { background: var(--ok-soft); color: var(--ok); }
.pill.st-implemented { outline: 1px solid var(--ok); }
.pill.st-rejected { background: var(--bad-soft); color: var(--bad); }
.outcome.st-approved, .outcome.st-implemented { background: var(--ok-soft); }
.outcome.st-discussing, .outcome.st-needs_decision, .outcome.st-new { background: var(--sunk); }
.pre { white-space: pre-line; }
.pill { white-space: nowrap; }
.small { font-size: .8rem; }
.links { display: flex; flex-wrap: wrap; gap: 6px; }
.lk { font: 500 .76rem/1 var(--mono); padding: 4px 7px; border: 1px solid var(--line); border-radius: 3px; text-decoration: none; color: var(--ink); background: var(--surface); }
a.lk:hover { border-color: var(--brass); }
.grid5 { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 8px; }
.grid5 input, .editor input[type="text"] { width: 100%; padding: 6px 8px; border: 1px solid var(--line); border-radius: var(--r); background: var(--surface); }
details.editor > summary { cursor: pointer; font-weight: 600; font-size: .88rem; }
details.editor[open] > summary { margin-bottom: 8px; }
details.hist-d > summary { font-size: .82rem; }
a.btn { text-decoration: none; display: inline-block; }
.dash { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px; margin-top: 22px; }
.dash .panel ul { margin: 0; padding-left: 1.1em; display: grid; gap: 5px; font-size: .9rem; }
.dash .panel h3 { display: flex; align-items: baseline; justify-content: space-between; gap: 8px; }
.dash .panel h3 small { font: 500 .78rem/1 var(--body); color: var(--muted); }
.flow { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; font-size: .86rem; margin-top: 6px; }
.flow span { padding: 5px 9px; border: 1px solid var(--line); border-radius: 99px; background: var(--surface); }
.flow i { color: var(--muted); font-style: normal; }
.iform { display: grid; gap: 10px; }
.iform input[type="text"], .iform select { padding: 8px 10px; border: 1px solid var(--line); border-radius: var(--r); background: var(--bg); width: 100%; }
.idea h4 { font-size: 1.15rem; }
.votes .fbtn[aria-pressed="true"] { background: var(--brass); border-color: var(--brass); color: var(--bg); }
.owners .row input.gh { padding: 5px 8px; border: 1px solid var(--line); border-radius: var(--r); background: var(--surface); max-width: 200px; }

/* Diagrams and review */''')
sub('pre.mermaid { margin: 0; background: transparent; }', 'pre.mermaid { margin: 0; background: transparent; white-space: pre; font: .78rem/1.4 var(--mono); }\npre.mermaid[data-processed] { white-space: normal; font: inherit; }')

# ---- header ----
sub('<div class="brand">Forged <b>&amp;</b> Sent · Blueprint</div>', '<div class="brand">Forged <b>&amp;</b> Sent · Planning Hub</div>')
sub('<a href="#overview">Overview</a><a href="#decisions">Decisions</a><a href="#suggestions">Suggestions</a>',
    '<a href="#overview">Overview</a><a href="#dashboard">Dashboard</a><a href="#decisions">Workshop &amp; decisions</a><a href="#ideas">Ideas</a>')

# ---- hero ----
cut('    <div class="eyebrow">Architecture · reconciled', '    <div class="banner" id="conn" hidden></div>', '''    <div class="eyebrow">Planning Hub · v4 · 27 Oct 2026 · architecture on branches arch/firebase-reconciliation + arch/planning-hub</div>
    <h1>Decide together. Build what we decided.</h1>
    <p class="lede">Forged &amp; Sent is a <b>fitness platform built around Christian discipleship</b>. Training, progress, nutrition, health and team challenges are the core pillars, and devotionals, Scripture, prayer, reflection and accountability run through all of them. This hub is where the two of us, and the friends we invite, propose ideas, weigh the options, vote and record decisions before and during the build. It's for planning only; it isn't the app.</p>
    <div class="eli5" style="margin-top:18px">Think of the prototype as a detailed sketch of a house that people have already lived in for a few days. We keep the furniture (the content and the lessons learned) and pour a real foundation on Firebase. This page is the job-site table where we lay out the plans and argue about them. GitHub is the signed set of drawings the builders, including the AI tools, have to follow.</div>
    <div class="flow" aria-label="How an idea becomes software"><span>Idea</span><i>→</i><span>Discussion</span><i>→</i><span>Vote</span><i>→</i><span>Owner decision</span><i>→</i><span>Decision log / ADR (GitHub)</span><i>→</i><span>Backlog issue</span><i>→</i><span>Implementation (PR)</span><i>→</i><span>Verification</span></div>
''')
cut('    <div class="grid3" style="margin-top:28px">\n      <div class="panel"><div class="eyebrow">1 · Read', '  </div>\n</section>\n\n<!-- DECISIONS -->', '')

# ---- dashboard section (inserted before DECISIONS) ----
DASH = '''<!-- DASHBOARD -->
<section class="sec" id="dashboard">
  <div class="wrap">
    <div class="sec-head"><div class="eyebrow">Progress</div><h2>Dashboard</h2>
      <p class="muted">What's blocking, what's waiting on you, what's new, and what's ready to build. Click any item to jump to it.</p></div>
    <div class="stats" aria-live="polite">
      <div class="stat"><b id="st-decided">0</b><span>of <span id="st-total">0</span> decisions ruled</span><div class="bar"><i id="st-bar"></i></div></div>
      <div class="stat"><b id="st-block">0</b><span>blocking, not yet decided</span></div>
      <div class="stat"><b id="st-mine">–</b><span>waiting for your vote</span></div>
      <div class="stat"><b id="st-ideas">0</b><span>ideas submitted</span></div>
      <div class="stat"><b id="st-git">0</b><span>rulings not yet in GitHub</span></div>
      <div class="stat"><b id="st-ready">0</b><span>ready for development</span></div>
      <div class="stat"><b id="st-people">0</b><span>people have weighed in</span></div>
    </div>
    <div class="people" id="people"></div>
    <div class="dash">
      <div class="panel"><h3>Blocking, not decided <small>owners</small></h3><ul id="dl-block"></ul></div>
      <div class="panel"><h3>Waiting for your vote <small>you</small></h3><ul id="dl-mine"></ul></div>
      <div class="panel"><h3>New ideas <small>anyone</small></h3><ul id="dl-new"></ul></div>
      <div class="panel"><h3>Needs an owner decision <small>owners</small></h3><ul id="dl-needs"></ul></div>
      <div class="panel"><h3>Ruled, not yet in GitHub <small>owners</small></h3><ul id="dl-git"></ul><p class="muted small">Export, run <code>tools/planning/import_hub_export.py</code>, open a PR, then add the DEC id to the ruling.</p></div>
      <div class="panel"><h3>Ready for development <small>builders</small></h3><ul id="dl-ready"></ul></div>
    </div>
    <div class="panel" id="ratify" style="margin-top:16px" hidden>
      <h3>Ratify the aligned decisions</h3>
      <p><b id="ratify-n">0</b> architecture decisions were reconciled as aligned with the direction you approved on 27 Oct and need no further choice (for example D01 rebuild, D02 Flutter, D03 Firebase). Ratifying records an <i>Approved</i> ruling for each, with the reconciliation as the reason. They still need to go into the GitHub decision log.</p>
      <div class="row"><button class="btn" type="button" id="ratify-btn">Ratify these</button><span class="saved" id="ratify-msg" role="status"></span></div>
    </div>
    <div class="grid2" style="margin-top:16px">
      <div class="panel owners"><h3>Who decides</h3><div id="owners-list"></div>
        <details class="more" id="owners-ed" hidden><summary>Set the project owners (page owner only)</summary>
          <p class="muted small">Tick the two project owners and add their GitHub handles. Only their rulings count on this page, and the handles go into the decision log.</p>
          <div id="owners-body" style="display:grid;gap:6px"></div>
          <div class="row"><button class="btn" type="button" id="owners-save">Save owners</button><span class="saved" id="owners-msg" role="status"></span></div></details>
        <p class="muted small">Votes are advice, not approval. Anyone with access can vote, comment and add ideas. Only the owners rule, and a ruling becomes binding on the code only when it's merged into <code>docs/planning/decision-log.yaml</code> with both owners' approval.</p></div>
      <div class="panel"><h3>Statuses</h3><div class="tbl"><table><thead><tr><th>Status</th><th>Meaning</th><th>Set by</th></tr></thead><tbody id="st-defs"></tbody></table></div></div>
    </div>
    <div class="row" style="margin-top:16px">
      <button class="btn ghost exp-json" type="button">Export everything (JSON)</button>
      <button class="btn ghost copy-md" type="button">Copy summary (Markdown)</button>
      <span class="saved" role="status"></span>
    </div>
  </div>
</section>

<!-- DECISIONS -->'''
sub('<!-- DECISIONS -->', DASH)

# ---- decisions section ----
sub('<div class="sec-head"><div class="eyebrow">The register</div><h2>Decisions to make</h2>\n      <p class="muted">Blocking decisions (brass edge) must be settled before building starts. Recommendations come from the review; none of them are final until the group agrees.</p></div>',
    '<div class="sec-head"><div class="eyebrow">The register</div><h2>Owner workshop and architecture decisions</h2>\n      <p class="muted">W01–W12 are the product decisions only the owners can make; each has a recommended default so work can proceed. D01–D35 are the architecture decisions, reconciled on 27 Oct. Blocking items (brass edge) must be ruled before the milestone that needs them. Recommendations are advice; nothing is final until an owner rules and it\'s recorded in GitHub.</p></div>')
sub('''      <button class="btn ghost" type="button" id="exp-json">Export everything (JSON)</button>
      <button class="btn ghost" type="button" id="copy-md">Copy decision summary</button>
      <span class="saved" id="exp-msg" role="status"></span>''', '''      <button class="btn ghost exp-json" type="button">Export everything (JSON)</button>
      <button class="btn ghost copy-md" type="button">Copy summary (Markdown)</button>
      <span class="saved" role="status"></span>''')

# ---- ideas section ----
cut('<!-- SUGGESTIONS -->', '<!-- THE PLAN -->', '''<!-- IDEAS -->
<section class="sec" id="ideas">
  <div class="wrap">
    <div class="sec-head"><div class="eyebrow">Anyone can propose</div><h2>Ideas, concerns and alternatives</h2>
      <p class="muted">Propose a feature, an improvement, an architecture alternative, a concern or a question. Others vote and comment. When it's ready, the author marks it <b>Ready for decision</b> and an owner rules. If it's approved and touches architecture, data, security or long-term behavior, it also gets an ADR.</p></div>
    <div class="grid2">
      <form class="panel iform" id="iform">
        <h3>Add an idea</h3>
        <input type="text" id="i-title" maxlength="140" placeholder="Short title, e.g. 'Let wives join prayer requests'" aria-label="Idea title" required>
        <div class="grid2" style="gap:8px"><select id="i-type" aria-label="Type"></select><select id="i-area" aria-label="Area"><option value="general">General</option></select></div>
        <select id="i-impact" aria-label="Impact"></select>
        <textarea id="i-problem" maxlength="2000" placeholder="The problem or reason: what's wrong or missing, and for whom?" aria-label="Problem"></textarea>
        <textarea id="i-proposal" maxlength="2000" placeholder="Your proposal. Options and trade-offs help the owners decide." aria-label="Proposal"></textarea>
        <div class="row"><button class="btn" type="submit">Add idea</button><span class="saved" id="i-msg" role="status"></span></div>
      </form>
      <div style="display:grid;gap:10px;align-content:start">
        <div class="filters" style="margin:0"><select id="if-status" aria-label="Idea status filter"><option value="open">Open ideas</option><option value="all">All ideas</option><option value="closed">Decided</option><option value="new">New</option><option value="discussing">Discussing</option><option value="needs_decision">Needs decision</option><option value="approved">Approved</option><option value="deferred">Deferred</option><option value="rejected">Rejected</option><option value="implemented">Implemented</option></select>
          <select id="if-type" aria-label="Idea type filter"><option value="all">All types</option></select><span class="saved" id="i-count"></span></div>
        <div class="dlist" id="ilist"><div class="empty">No ideas yet. Use the form to add the first one.</div></div>
      </div>
    </div>
  </div>
</section>

''')

# ---- roadmap → milestones ----
cut('    <div class="sec-head"><div class="eyebrow">Migration</div><h2>Roadmap in vertical slices</h2>', '<!-- RISKS -->', '''    <div class="sec-head"><div class="eyebrow">Proposed sequence (W02)</div><h2>Five milestones, each used by real people</h2>
      <p class="muted">The men start using the app at M2, before competition exists. Each milestone ends with a test that must pass. No dates on purpose: dates come after the blocking decisions. Detail: <code>docs/planning/05-mvp-roadmap-milestones.md</code>.</p></div>
    <div class="tbl"><table>
      <thead><tr><th>Milestone</th><th>Who uses it</th><th>What gets built</th><th>Done when</th></tr></thead>
      <tbody>
        <tr><td><b>0 · Plan</b></td><td>The two of us</td><td>Architecture, ADRs, requirements, this hub, the GitHub decision log</td><td>Both owners merge the branches; W01, W02, W07 and W12 ruled</td></tr>
        <tr><td><b>M1 · Train with purpose</b></td><td>Owners + 3 testers</td><td>Sign-in, onboarding (level, equipment, lift days), Today, guided offline workout (Forged program), devotional before, after, in rests, or alone, private journal, faithfulness calendar, history and PRs</td><td>Both owners use it daily for 2 weeks; an airplane-mode workout survives an app kill and syncs exactly once</td></tr>
        <tr><td><b>M2 · Brotherhood</b> (pilot alpha)</td><td>The men's group</td><td>Invites, group, encouragement feed, prayer requests with chosen audiences, partners, reminders, report/block/moderation, account deletion and export</td><td>4 weeks meeting the W11 targets; app-store safety checklist passes</td></tr>
        <tr><td><b>M3 · Practice season</b></td><td>The men, in teams</td><td>Teams, weekly challenge (Standard/Foundation + alternates), 1 mission a week, video proof with review and appeal, server scoring, team standings</td><td>A 4-week practice season runs end to end; results re-run to the same fingerprint; retrospective with the pastor</td></tr>
        <tr><td><b>M4 · Fuel &amp; recover</b></td><td>The men</td><td>Food log through a provider, hydration, steps from Health, bounded nutrition points, the other three programs</td><td>No client API keys; under-eating never rewarded (test); 1,460-day program match</td></tr>
        <tr><td><b>M5 · First real season</b></td><td>The men; store reviewers</td><td>Prod hardening, restore drill, privacy policy, store listings, the real season</td><td>Security gate passes; 2+ weeks with zero data loss; owners say go</td></tr>
      </tbody></table></div>
    <div class="grid3" style="margin-top:22px">
      <div class="panel"><div class="eyebrow">MVP = M1 + M2</div><p>A man can open the app at the gym with no signal, do today's program workout with the devotional where he wants it, write a private reflection, see his progress, and know his brothers are encouraging and praying with him.</p></div>
      <div class="panel"><div class="eyebrow">After beta feedback</div><ul class="clean"><li>Scripture memorization</li><li>Workout-specific faith content library</li><li>Private fasting</li><li>More equipment profiles</li><li>Leader settings in the app</li></ul></div>
      <div class="panel"><div class="eyebrow">Later or not yet</div><ul class="clean"><li>Multiple churches, leagues, admin console (Stage 2)</li><li>Households for couples and families (Stage 2, own design)</li><li>Youth (Stage 3+, own design)</li><li>Direct messages (need a safety design)</li><li>AI coach over private data (not planned)</li><li>Payments</li></ul></div>
    </div>
  </div>
</section>

''')

# ---- AI section ----
sub('<li>AI never approves theology or merges code</li>', '<li>AI never approves theology or merges code</li><li><b>Decision guard:</b> agents read the GitHub decision log before every task. If a task conflicts with an approved decision, they stop and propose an amendment for the owners; they can\'t edit the log (the guard blocks it)</li><li>Start small: four roles are active in M1 (an implementer, the architecture and security reviewers, the test engineer); the others switch on when their first task appears</li>')

# ---- footer ----
cut('    <p><b>Where this page keeps data.</b>', '  </div>\n</footer>', '''    <p><b>Where this page keeps data.</b> Votes, notes, ideas and rulings are saved with this page and shared with the people it's shared with. Each person's own entries (votes, ideas, history) can only be changed by that person. Rulings count only from the owners listed on the Dashboard. Use Export to download everything as JSON, then commit it to the repository with <code>tools/planning/import_hub_export.py</code>.</p>
    <p><b>Who can do what.</b> Viewers and commenters can read and comment. Voting and adding ideas needs Contributor access (or an Editor invite by email from outside the organization). Owners rule.</p>
    <p><b>Authoritative record:</b> <code>docs/planning/decision-log.yaml</code> and <code>docs/adr/</code> in the repository, on branches <code>arch/firebase-reconciliation</code> and <code>arch/planning-hub</code> until merged. This page's source is <code>docs/blueprint-hub/</code>; its spec is <code>docs/planning/09-planning-hub-spec.md</code>.</p>
''')

# ---- data ----
sub('var AREAS = {\n  foundation:', 'var AREAS = {\n  workshop: { label: "Owner workshop", blurb: "Product decisions that belong to the owners. Each has a recommended default so work can proceed." },\n  foundation:')
sub('{ k: "firebase", label: "Firebase / Firestore", pros: "Offline sync built in; very low operations", cons: "Weak fit for groups, roles and score integrity; per-read costs; harder to leave" }',
    '{ k: "firebase", label: "Firebase / Firestore (approved)", pros: "Offline sync built in; very low operations; one vendor for sign-in, data, files and push", cons: "Per-read costs reward careful queries; group and score integrity rely on tested rules and Functions-only writes; harder to leave" }')
sub('var GLOSSARY = [', '''var GLOSSARY = [
  ["Planning Hub", "This page: where ideas, votes and owner rulings happen. It's advisory. The repository's decision log is the binding record."],
  ["Decision log (DEC-####)", "docs/planning/decision-log.yaml in the repository: every owner decision with who, when, why and links. Both owners approve changes; AI agents can't edit it."],
  ["Ruling", "An owner's recorded decision on this page: status, chosen option, reason and links."],
  ["Workshop item (W##)", "One of the 12 product decisions only the owners can make."],''')

wjs = (HERE / "workshop.js").read_text()
rjs = (HERE / "runtime.js").read_text()
cut('(function () {\n  "use strict";', '</script>', wjs + "\n" + rjs + "\n")
out.write_text(t)
print("wrote", out, len(t))
