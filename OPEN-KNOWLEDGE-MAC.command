#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
printf '\n  FORGED & SENT / KNOWLEDGE WORKSPACE\n'
printf '  No cloud account or Obsidian plugin required.\n'
fs_python=''
if command -v python3.12 >/dev/null 2>&1 && python3.12 -c 'import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)'; then
  fs_python=python3.12
elif command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)'; then
  fs_python=python3
else
  echo 'Python 3.11+ is required. Run SETUP-DEVELOPER-MAC.command and retry.'
  if [ -t 0 ]; then read -r -p 'Press Return to close...' _answer; fi
  exit 1
fi
printf '  Keep this window open. Press Ctrl+C to stop the preview.\n'
if ! "$fs_python" tooling/preview/serve_project.py --build-atlas --open-browser; then
  echo 'Preview failed. Check the error above and whether port 43117 is already used.'
  if [ -t 0 ]; then read -r -p 'Press Return to close...' _answer; fi
  exit 1
fi
