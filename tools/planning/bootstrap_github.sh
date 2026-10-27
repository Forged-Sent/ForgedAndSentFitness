#!/usr/bin/env bash
# One-time GitHub setup for the planning workflow (docs/planning/09-planning-hub-spec.md §7).
# Needs: gh CLI authenticated with admin rights on the repo. Safe to re-run (labels are upserted).
set -euo pipefail
REPO="${1:-sfcsmithc-afk/ForgedAndSentFitness}"
python3 - "$REPO" <<'PY'
import subprocess, sys, yaml, pathlib
repo = sys.argv[1]
for l in yaml.safe_load(pathlib.Path(".github/labels.yml").read_text()):
    subprocess.run(["gh", "label", "create", l["name"], "--repo", repo, "--color", l["color"], "--description", l["description"], "--force"], check=True)
    print("label", l["name"])
PY
echo
echo "Optional: create a Projects board (needs the 'project' scope: gh auth refresh -s project)"
echo "  gh project create --owner \"${REPO%%/*}\" --title 'Forged & Sent planning'"
echo "  Then add views grouped by label status:* (Decisions, Backlog, In progress, Done)."
echo
echo "Branch protection for main (required checks + CODEOWNERS review), via the web UI or:"
echo "  gh api -X PUT repos/$REPO/branches/main/protection --input tools/planning/branch-protection.json"
