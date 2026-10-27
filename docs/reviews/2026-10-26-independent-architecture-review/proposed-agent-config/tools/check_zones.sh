#!/usr/bin/env bash
# PROPOSED. Protected-zone guard. CI mode: tools/check_zones.sh <base-ref>
# Hook mode (--hook): reads the Claude Code tool-call JSON on stdin; exits 2 to block edits to protected zones
# unless FS_ALLOW_ZONE=1 is set for a task that explicitly owns the zone.
set -euo pipefail
ZONES='^(contracts/|supabase/migrations/|docs/adr/|docs/rules/|content/.*/approved\.yaml)'
if [[ "${1:-}" == "--hook" ]]; then
  path=$(python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("file_path",""))')
  rel=${path#"$(git rev-parse --show-toplevel)/"}
  if [[ "$rel" =~ $ZONES && "${FS_ALLOW_ZONE:-0}" != "1" ]]; then
    echo "Blocked: $rel is a protected zone. Propose the change in the PR description (AGENTS.md)." >&2; exit 2
  fi
  exit 0
fi
base=${1:-origin/main}
changed=$(git diff --name-only "$base"...HEAD)
# 1. merged migrations are append-only
if git diff --name-status "$base"...HEAD -- supabase/migrations | grep -E '^(M|D|R)'; then
  echo "ERROR: existing migration modified/deleted"; exit 1; fi
# 2. zone changes need the label (CI passes PR labels in $PR_LABELS) and an ADR reference in $PR_BODY
if echo "$changed" | grep -Eq "$ZONES"; then
  [[ "${PR_LABELS:-}" == *contract-change* ]] || { echo "ERROR: protected zone changed without 'contract-change' label"; exit 1; }
  [[ "${PR_BODY:-}" =~ ADR-[0-9]{3} ]] || { echo "ERROR: protected zone changed without ADR reference"; exit 1; }
fi
echo "zones OK"
