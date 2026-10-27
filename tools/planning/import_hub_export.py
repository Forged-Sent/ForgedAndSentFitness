#!/usr/bin/env python3
"""Merge a Planning Hub export (fs-planning-hub-export/1) into docs/planning/decision-log.yaml.

    python3 tools/planning/import_hub_export.py forged-and-sent-planning-YYYY-MM-DD.json [--dry-run]

Only OFFICIAL owner rulings with a terminal status (approved, deferred, rejected, implemented) are imported.
Existing entries are matched by source.hub. A changed ruling updates the entry and appends a history line, so
earlier outcomes are kept. New entries get the next DEC id. Ratification stays false: it becomes true only in
the PR that both owners approve. Also writes docs/planning/hub-snapshots/<date>.json (votes, ideas, history) so the
planning record survives outside the hub.
"""
import json, pathlib, re, sys
import yaml

R = pathlib.Path(__file__).resolve().parents[2]
LOG = R / "docs/planning/decision-log.yaml"
TERMINAL = {"approved", "deferred", "rejected", "implemented"}
KIND_BY_AREA = {"foundation": "architecture", "privacy": "security", "competition": "product", "faith": "product",
                "ops": "process", "workshop": "product", "general": "product"}
KIND_BY_IMPACT = {"architecture": "architecture", "product": "product", "minor": "product"}


def as_list(v):
    if not v: return []
    return [x.strip() for x in re.split(r"[,\s]+", v) if x.strip()] if isinstance(v, str) else list(v)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry-run" in sys.argv
    if len(args) != 1: print(__doc__); sys.exit(2)
    exp = json.loads(pathlib.Path(args[0]).read_text())
    if exp.get("schema") != "fs-planning-hub-export/1": sys.exit("not a Planning Hub export (schema fs-planning-hub-export/1)")
    header = "".join(l for l in LOG.read_text().splitlines(True) if l.startswith("#"))
    doc = yaml.safe_load(LOG.read_text())
    decs = doc["decisions"]
    by_hub = {str((d.get("source") or {}).get("hub")): d for d in decs if (d.get("source") or {}).get("hub")}
    next_n = max([int(d["id"][4:]) for d in decs] + [0]) + 1
    changes = []
    for it in exp["items"]:
        r = it.get("ruling")
        if not r or not r.get("official") or r.get("status") not in TERMINAL: continue
        day = r["at"][:10]
        who = r.get("github") or r.get("byName") or "owner"
        links = r.get("links") or {}
        outcome = r.get("outcomeLabel") or r.get("outcome") or ""
        kind = KIND_BY_IMPACT.get(it.get("impact")) if it.get("kind") == "idea" else KIND_BY_AREA.get(it.get("area"), "product")
        cur = by_hub.get(it["id"])
        if cur is None:
            cur = {"id": f"DEC-{next_n:04d}", "title": it["title"], "kind": kind, "status": r["status"], "ratified": False,
                   "decided_at": day, "decided_by": [who], "source": {"hub": it["id"]}, "outcome": outcome,
                   "rationale": r.get("rationale", ""),
                   "links": {"adr": as_list(links.get("adr")), "requirements": as_list(links.get("fs")),
                             "issues": as_list(links.get("issue")), "prs": as_list(links.get("pr"))},
                   "history": [{"at": day, "status": r["status"], "by": who, "note": "Imported from Planning Hub ruling"}]}
            next_n += 1; decs.append(cur); by_hub[it["id"]] = cur
            changes.append(f"+ {cur['id']} {it['id']} {r['status']}: {it['title']}")
            continue
        if (cur["status"], cur.get("outcome", ""), cur.get("rationale", "")) == (r["status"], outcome, r.get("rationale", "")): continue
        cur["history"].append({"at": day, "status": r["status"], "by": who,
                               "note": f"Changed from {cur['status']}" + (f" ({cur.get('outcome')})" if cur.get("outcome") else "")})
        cur.update({"status": r["status"], "outcome": outcome, "rationale": r.get("rationale", ""), "decided_at": day, "ratified": False})
        if who not in cur["decided_by"]: cur["decided_by"].append(who)
        L = cur.setdefault("links", {})
        for k, src in (("adr", "adr"), ("requirements", "fs"), ("issues", "issue"), ("prs", "pr")):
            for v in as_list(links.get(src)):
                if v not in L.setdefault(k, []): L[k].append(v)
        changes.append(f"~ {cur['id']} {it['id']} -> {r['status']}")
    print("\n".join(changes) or "No new or changed owner rulings.")
    if dry: return
    LOG.write_text(header + yaml.safe_dump(doc, sort_keys=False, allow_unicode=True, width=120))
    snap = R / "docs/planning/hub-snapshots" / (exp["exportedAt"][:10] + ".json")
    snap.parent.mkdir(parents=True, exist_ok=True)
    snap.write_text(json.dumps(exp, indent=2, ensure_ascii=False) + "\n")
    print(f"Wrote {LOG.relative_to(R)} and {snap.relative_to(R)}. Open a PR labeled contract-change; both owners approve.")
    print("Then paste each new DEC id into its ruling on the hub (Decision log id field).")


if __name__ == "__main__":
    main()
