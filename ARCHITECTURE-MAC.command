#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
printf '\n  FORGED & SENT / ARCHITECTURE ATLAS\n'
printf '  Indexing checked-in files, functions and dependencies...\n\n'
if ! command -v python3 >/dev/null 2>&1; then
  echo 'Install Python 3 first, then reopen this launcher.'
  if [ -t 0 ]; then read -r -p 'Press Enter to close...' _answer; fi
  exit 1
fi
if ! python3 tooling/architecture/build_explorer.py --write; then
  echo 'Generation failed. Confirm this is a real Git clone.'
  if [ -t 0 ]; then read -r -p 'Press Enter to close...' _answer; fi
  exit 1
fi
open "build/architecture-explorer/Architecture-Atlas.html"
printf 'Opened your local offline architecture explorer.\n'
