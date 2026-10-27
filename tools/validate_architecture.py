#!/usr/bin/env python3
"""Forged & Sent architecture validator (stdlib + PyYAML). Run from repo root:  python3 tools/validate_architecture.py
Exit code 1 on any failure. Checks are deliberately simple and deterministic."""
import json, pathlib, re, sys
try:
    import yaml
except ImportError:
    print("PyYAML required: pip install pyyaml"); sys.exit(2)

R = pathlib.Path(__file__).resolve().parent.parent
errors, notes = [], []
def err(m): errors.append(m)

# 1. ADRs
adrs = {}
for f in sorted((R / "docs/adr").glob("ADR-*.md")):
    t = f.read_text()
    m = re.match(r"---\n(.*?)\n---\n", t, re.S)
    if not m: err(f"{f.name}: missing frontmatter"); continue
    fm = yaml.safe_load(m.group(1))
    i = fm.get("id")
    if i in adrs: err(f"duplicate ADR id {i}")
    if fm.get("status") not in ("Proposed", "Accepted", "Rejected", "Superseded"): err(f"{i}: bad status {fm.get('status')}")
    if fm.get("status") == "Superseded" and "superseded by" not in str(fm.get("relations", "")).lower(): err(f"{i}: Superseded without 'superseded by'")
    if not f.name.startswith(i): err(f"{f.name}: filename does not start with {i}")
    adrs[i] = fm
accepted_titles = {}
for i, fm in adrs.items():
    if fm["status"] == "Accepted":
        key = re.sub(r"\W+", " ", fm["title"].lower()).strip()
        if key in accepted_titles: err(f"{i} and {accepted_titles[key]} both Accepted with the same decision title")
        accepted_titles[key] = i
notes.append(f"ADRs: {len(adrs)} ({sum(1 for a in adrs.values() if a['status']=='Accepted')} accepted, {sum(1 for a in adrs.values() if a['status']=='Proposed')} proposed)")

# 2. Requirements and test catalog
req = yaml.safe_load((R / "docs/requirements/requirements.yaml").read_text())["requirements"]
tcs = {t["id"]: t for t in yaml.safe_load((R / "docs/requirements/test-catalog.yaml").read_text())["tests"]}
od_text = (R / "docs/requirements/open-decisions.md").read_text()
ods = set(re.findall(r"^\| (OD-\d\d) \|", od_text, re.M))
ids = set()
for r in req:
    if r["id"] in ids: err(f"duplicate requirement {r['id']}")
    ids.add(r["id"])
    for k in ("type", "text", "acceptance", "components", "adr", "verification", "status"):
        if k not in r: err(f"{r['id']}: missing {k}")
    for a in r.get("adr", []):
        if a not in adrs: err(f"{r['id']}: unknown ADR {a}")
    for v in r.get("verification", []):
        if v not in tcs: err(f"{r['id']}: unknown test {v}")
    if r.get("status") == "open" and r.get("open_decision") not in ods: err(f"{r['id']}: open without a registered open_decision")
notes.append(f"Requirements: {len(ids)}; tests catalogued: {len(tcs)}; open decisions: {len(ods)}")
required_tc = [f"TC-{n:03d}" for n in range(1, 16)]
for t in required_tc:
    if t not in tcs: err(f"required quality-gate test {t} missing from catalog")
    elif not any(t in r.get("verification", []) for r in req): err(f"{t} not traced to any requirement")

# 3. Reconciliation matrix completeness
mx = (R / "docs/architecture/00-reconciliation-matrix.md").read_text()
rows = re.findall(r"^\| (D\d\d) \|", mx, re.M)
want = [f"D{n:02d}" for n in range(1, 36)]
if sorted(set(rows)) != want or len(rows) != 35: err(f"reconciliation summary must list D01..D35 exactly once (found {len(rows)})")
for d in want:
    if f"### {d}" not in mx and not re.search(rf"### D\d\d[–-]{d[1:]}|### {d}[–-]", mx) and not re.search(rf"### D\d\d[–-]D{d[1:]}", mx):
        # ranges like "### D18–D19" cover both
        rng = [(int(a), int(b)) for a, b in re.findall(r"### D(\d\d)[–-]D(\d\d)", mx)]
        if not any(a <= int(d[1:]) <= b for a, b in rng): err(f"reconciliation detail missing for {d}")

# 4. Every OD referenced in docs exists
for f in list((R / "docs").rglob("*.md")):
    if "reviews" in f.parts: continue
    for od in set(re.findall(r"OD-\d\d", f.read_text())):
        if od not in ods: err(f"{f.relative_to(R)} references unregistered {od}")

# 5. Diagrams
required_d = ["01-system-context", "02-component-architecture", "03-deployment", "04-domain-model", "05-data-relationships",
              "06-group-role-access", "07-devotional-workout-state-machine", "08-offline-workout-logging", "09-offline-sync-sequence",
              "10-challenge-submission", "11-team-scoring", "12-video-proof-lifecycle", "13-content-approval", "14-household-youth-separation"]
for d in required_d:
    if not (R / f"docs/diagrams/{d}.mmd").exists(): err(f"missing diagram {d}.mmd")

# 6. Schemas: banned fields / criteria
rs = json.loads((R / "contracts/ruleset.schema.json").read_text())
blob = json.dumps(rs).lower()
for banned in ("prize", "wager", "entryfee", "entry_fee", "journal", "reflectiontext", "prayertext"):
    if re.search(rf'"{banned}', blob): err(f"ruleset schema contains banned field '{banned}'")
et = json.loads((R / "contracts/experience-template.schema.json").read_text())
comp = et["properties"]["stages"]["items"]["properties"]["completion"]["enum"]
for banned in ("min_time", "dwell", "scroll", "word_count", "words"):
    if any(banned in c for c in comp): err(f"experience template allows banned completion '{banned}'")

# 7. Static bans in code (when code exists)
for sub in ("app/lib/features/proof", "functions/src/proof"):
    p = R / sub
    if p.exists():
        for f in p.rglob("*"):
            if f.is_file() and "getDownloadURL" in f.read_text(errors="ignore"): err(f"{f.relative_to(R)} uses getDownloadURL (banned for proof, ADR-0010)")

# 8. Stale-backend guard: Supabase may only appear in decision history
allowed = {"docs/architecture/00-reconciliation-matrix.md", "docs/adr/README.md"}
for f in list((R / "docs/architecture").rglob("*.md")) + [R / "AGENTS.md", R / "CLAUDE.md"] + list((R / "docs/adr").glob("*.md")):
    if not f.exists(): continue
    rel = str(f.relative_to(R))
    if rel in allowed or rel.startswith("docs/adr/ADR-0003"): continue
    for ln, line in enumerate(f.read_text().splitlines(), 1):
        if re.search(r"supabase|postgres(ql)?\b|row level security|\bRLS\b", line, re.I) and not re.search(r"\b(no|not|rejected|superseded|never)\b", line, re.I):
            err(f"{rel}:{ln} mentions Supabase/PostgreSQL/RLS outside decision history (ADR-0003)")

# 9. Skills mirror (Codex reads .agents/skills, Claude Code reads .claude/skills)
a, c = R / ".agents/skills", R / ".claude/skills"
if a.exists() or c.exists():
    def tree(p): return {str(x.relative_to(p)): x.read_bytes() for x in p.rglob("*") if x.is_file()} if p.exists() else {}
    ta, tc = tree(a), tree(c)
    fs_a = {k: v for k, v in ta.items() if k.startswith("fs-")}
    fs_c = {k: v for k, v in tc.items() if k.startswith("fs-")}
    if fs_a != fs_c: err("project skills differ between .agents/skills and .claude/skills (run tools/sync_skills.py)")

# 10. Owner decision log (docs/planning/decision-log.yaml): the binding record agents must not reverse
dl = R / "docs/planning/decision-log.yaml"
if dl.exists():
    d = yaml.safe_load(dl.read_text()) or {}
    if d.get("schema") != "fs-decision-log/1": err("decision-log.yaml: schema must be fs-decision-log/1")
    seen = {}
    KINDS = {"product", "architecture", "data-contract", "security", "process", "content"}
    STATUSES = {"approved", "deferred", "rejected", "implemented", "superseded"}
    for e in d.get("decisions") or []:
        i = e.get("id", "?")
        if not re.fullmatch(r"DEC-\d{4}", str(i)): err(f"decision-log: bad id {i}")
        if i in seen: err(f"decision-log: duplicate id {i}")
        seen[i] = e
        if e.get("kind") not in KINDS: err(f"{i}: kind must be one of {sorted(KINDS)}")
        if e.get("status") not in STATUSES: err(f"{i}: status must be one of {sorted(STATUSES)}")
        if not e.get("title"): err(f"{i}: missing title")
        if not e.get("decided_by"): err(f"{i}: decided_by is empty")
        if e.get("status") in ("approved", "rejected", "deferred", "implemented") and not str(e.get("rationale", "")).strip(): err(f"{i}: a {e.get('status')} decision needs a rationale")
        links = e.get("links") or {}
        for a in links.get("adr") or []:
            if a not in adrs: err(f"{i}: unknown ADR {a}")
        if e.get("kind") in ("architecture", "data-contract", "security") and e.get("status") in ("approved", "implemented") and not links.get("adr"):
            err(f"{i}: an approved {e.get('kind')} decision must cite an ADR")
        if e.get("status") == "implemented" and not links.get("prs"): err(f"{i}: implemented needs at least one PR in links.prs")
        if e.get("ratified") is True and any(str(w) == "project-owners" for w in e.get("decided_by") or []):
            err(f"{i}: ratified decisions must name the owners' GitHub handles in decided_by")
        h = e.get("history") or []
        if not h: err(f"{i}: history must have at least one entry")
        if h and h[-1].get("status") != e.get("status"): err(f"{i}: last history entry ({h[-1].get('status')}) does not match status ({e.get('status')}); record every change in history")
    for i, e in seen.items():
        if e.get("status") == "superseded":
            s = e.get("superseded_by")
            if s not in seen: err(f"{i}: superseded without a valid superseded_by")
    notes.append(f"decision log: {len(seen)} owner decisions ({sum(1 for e in seen.values() if e.get('ratified'))} ratified)")

for n in notes: print("•", n)
if errors:
    print(f"\n{len(errors)} problem(s):"); [print("  ✗", e) for e in errors]; sys.exit(1)
print("\nAll architecture checks passed.")
