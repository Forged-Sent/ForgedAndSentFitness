#!/usr/bin/env bash
# Protected-zone guard (ADR-0015, FS-DEV-001, TC-058).
# CI:   PR_LABELS="..." PR_BODY="..." tools/check_zones.sh origin/main
# Hook: tools/check_zones.sh --hook  (reads Claude Code PreToolUse JSON on stdin; exit 2 blocks)
set -euo pipefail
ZONES='^(docs/adr/|docs/requirements/|contracts/|firebase/firestore\.rules|firebase/storage\.rules|firebase/firestore\.indexes\.json|functions/src/scoring/|content/.*/approved\.yaml)'
LEGACY='^(index\.html|versions/|seed/)'
if [[ "${1:-}" == "--hook" ]]; then
  path=$(python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("file_path",""))')
  root=$(git rev-parse --show-toplevel); rel=${path#"$root/"}
  if [[ "$rel" =~ $ZONES && "${FS_ALLOW_ZONE:-0}" != "1" ]]; then
    echo "Blocked: $rel is a protected zone (AGENTS.md). Propose the change in the PR description, or have a human set FS_ALLOW_ZONE=1 for a contract-change task." >&2; exit 2; fi
  if [[ "$rel" =~ $LEGACY && "${FS_ALLOW_LEGACY:-0}" != "1" ]]; then
    echo "Blocked: $rel is the frozen prototype (ADR-0001)." >&2; exit 2; fi
  exit 0
fi
base=${1:-origin/main}
changed=$(git diff --name-only "$base"...HEAD || true)
fail=0
if echo "$changed" | grep -Eq "$ZONES"; then
  [[ "${PR_LABELS:-}" == *contract-change* ]] || { echo "✗ protected zone changed without label 'contract-change'"; fail=1; }
  [[ "${PR_BODY:-}" =~ ADR-[0-9]{4} ]] || { echo "✗ protected zone changed without an ADR-#### reference in the PR body"; fail=1; }
fi
if echo "$changed" | grep -Eq "$LEGACY"; then
  [[ "${PR_LABELS:-}" == *legacy-change* ]] || { echo "✗ prototype files changed without label 'legacy-change'"; fail=1; }
fi
exit $fail
