#!/bin/bash
set -euo pipefail
# Architecture Atlas. Finder double-click entrypoint; does not bypass macOS security dialogs.
cd "$(dirname "$0")/../../.."
printf '\n  FORGED & SENT / ARCHITECTURE ATLAS\n'
printf '  Indexing checked-in files, functions and dependencies...\n'
fs_python=''
for fs_candidate in python3.13 python3.12 python3.11 python3; do
  if command -v "$fs_candidate" >/dev/null 2>&1 &&
     "$fs_candidate" -c 'import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)' 2>/dev/null; then
    fs_python="$fs_candidate"; break
  fi
done
if [ -z "$fs_python" ]; then
  echo 'Python 3.11+ is missing. Double-click START-MAC.command, choose 1 to set up this computer, and retry.'
  if [ -t 0 ]; then read -r -p 'Press Return to close...' _answer; fi
  exit 1
fi
if ! "$fs_python" tooling/architecture/build_explorer.py --write; then
  echo 'Architecture Atlas generation failed. Check the error and confirm a complete Git clone.'
  if [ -t 0 ]; then read -r -p 'Press Return to close...' _answer; fi
  exit 1
fi
open "build/architecture-explorer/Architecture-Atlas.html"
echo 'Offline Architecture Atlas opened.'
