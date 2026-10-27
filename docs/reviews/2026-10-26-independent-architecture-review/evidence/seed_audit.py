"""Non-destructive audit of Forged & Sent seed data and embedded constants.
Usage: python3 -I seed_audit.py <path-to-repo>   (reviewed at a71efab)"""
import json, re, sys, collections, pathlib
R = pathlib.Path(sys.argv[1]); S = R / "seed"
ld = lambda f: json.loads((S / f).read_text())
out = []
p = lambda *a: out.append(" ".join(str(x) for x in a))

# 1. Embedded data vs seed files
lines = (R / "index.html").read_text().split("\n")
def var(name):
    for i, l in enumerate(lines):
        m = re.match(r"\s*var " + name + r" = (.*);\s*$", l)
        if m: return i + 1, json.loads(m.group(1))
for n, f in [("CHAL", "weekly-challenges.json"), ("STANDARDS", "movement-standards.json"), ("DEVOS", "devotionals.json"), ("ALT", "alternates.json")]:
    ln, v = var(n); p(f"[embed] {n} at index.html L{ln}: {'identical to' if v == ld(f) else 'DIFFERS from'} seed/{f}")
ln, PLAN = var("PLAN")
W, Ws = PLAN["W"], ld("workouts.json")
p(f"[embed] PLAN at L{ln}: PLAN.W identical to seed/workouts.json? {W == Ws}")
stripped = sum(1 for prog in Ws for d in Ws[prog] for e in d["exercises"] if re.search(r"RPE|RIR", e[1]))
p(f"[embed] seed exercise prescriptions containing RPE/RIR: {stripped}; in embedded PLAN: "
  f"{sum(1 for prog in W for d in W[prog] for e in d['exercises'] if re.search(r'RPE|RIR', e[1]))}")
f1, f4 = W["Forged"][0], W["Forged"][21]
p(f"[embed] Forged wk1 day1 {f1['exercises'][0]} vs wk4 (deload) day1 {f4['exercises'][0]} -> deload indistinguishable: {f1['exercises'][0] == f4['exercises'][0]}")

# 2. Workouts structure and duplication
mv = ld("movements.json")
for prog, days in Ws.items():
    bodies = {(d["templateDay"], json.dumps(d["exercises"]), json.dumps(d["warmup"])) for d in days}
    missing = {e[0] for d in days for e in d["exercises"] if e[0] not in mv}
    dupwu = sum(1 for d in days if len({w[0] for w in d["warmup"]}) != len(d["warmup"]))
    p(f"[workouts] {prog}: {len(days)} materialized days, {len(bodies)} distinct day bodies, unresolved movements={len(missing)}, warm-ups repeating a movement={dupwu}")
fmts = collections.Counter(re.sub(r"\d+", "N", e[1]) for prog in Ws for d in Ws[prog] for e in d["exercises"])
p(f"[workouts] distinct free-text prescription formats: {len(fmts)} (parsed by regex at runtime)")
for d in Ws["Forged"][:29:7]:
    p(f"[workouts] Forged week {d['week']} block {d['block']}: {d['exercises'][0]}")

# 3. Devotionals
dv = ld("devotionals.json")["days"]
p(f"[devos] entries={len(dv)} distinct refs={len(set(v['ref'] for v in dv.values()))} has Feb 29={'02-29' in dv}")
wc = [len((v['prayer'] + ' ' + v['reflect'] + ' ' + v['act']).split()) for v in dv.values()]
p(f"[devos] words per entry excluding the verse: mean {sum(wc)/len(wc):.0f}, min {min(wc)}, max {max(wc)}; fields: {sorted(next(iter(dv.values())).keys())} (no translation/source/version field)")

# 4. Challenges
C = ld("weekly-challenges.json"); sc = C["scoring"]
p(f"[chal] scoring.status={sc['status']!r} weekRunsTo={sc['weekRunsTo']!r} (code deadline: Sunday 08:00 Arizona) soloBracketScores={sc['soloBracketScores']}")
fam = [c for w in C["weeks"] for c in w["challenges"] if c["slot"] == "family"]
wife = [c["id"] for c in fam if re.search(r"\bwife\b", c["description"], re.I)]
kids = [c["id"] for c in fam if re.search(r"\b(kids|child|children)\b", c["description"], re.I)]
p(f"[chal] family challenges={len(fam)}; mention wife={len(wife)}; mention kids/child={len(kids)}; mention family/household={sum(1 for c in fam if re.search(r'famil', c['description'], re.I))}")
p("[chal] scoredBy counts:", dict(collections.Counter((c["slot"], c["scoredBy"]) for w in C["weeks"] for c in w["challenges"])))
for cid in ("w12-family", "w20-family", "w50-family"):
    c = next(c for w in C["weeks"] for c in w["challenges"] if c["id"] == cid); p(f"[chal] {cid}: {c['description']} | record: {c['record']}")
# Incentive example (code: pts = max(flat 50 if any non-standard attempt, 100*leader/result))
lead, me = 390, 840
p(f"[chal] Mile trial, leader 6:30, man 14:00 standard -> {round(100*lead/me)} pts; logging a 'brisk 1 mile walk' scaled attempt too -> 50 pts")

# 5. Daily points (seed/tasks.json + constants in index.html)
T = ld("tasks.json")
daily = sum(t["points"] for t in T.values() if t["kind"] not in ("weigh", "photos"))
p(f"[points] daily box points={daily} (+3 custom habits); devotional={T['t_devo']['points']}/day = {7*T['t_devo']['points']}/week; one PR=25")
def step_bonus(n):
    k = (min(max(int(n), 0), 200000) - 10000) // 1000
    return 0 if k <= 0 else min(k, 5) + max(0, k - 5) * 0.5
p(f"[points] manual steps 200,000 (UI max) -> step bonus {step_bonus(200000)} pts in one day; 18,000 -> {step_bonus(18000)}")
p(f"[points] prs.n capped at 20 by normPrs -> max PR points/day = {20*25}")

# 6. Access rules
rules = ld("db-rules.json")["capabilities"]["db"]["rules"]
ruled = sorted({r["path"].split("/")[0] for r in rules})
used = sorted(set(re.findall(r'db\.collection\("([a-z]+)"\)', "\n".join(lines))) | {"diag"})  # top-level only; data/users/<id>/* is platform-private
p(f"[rules] collections with rules: {ruled}")
p(f"[rules] shared collections used by code WITHOUT rules: {[c for c in used if c not in ruled]}")
print("\n".join(out))
