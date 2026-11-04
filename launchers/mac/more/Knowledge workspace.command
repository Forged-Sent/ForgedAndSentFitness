#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
printf '\n  FORGED & SENT / KNOWLEDGE WORKSPACE\n'
printf '  No cloud account or Obsidian plugin required.\n'
fs_python=''
# Newest first; Homebrew may expose only a versioned name such as python3.13.
for fs_candidate in python3.13 python3.12 python3.11 python3; do
  if command -v "$fs_candidate" >/dev/null 2>&1 &&
     "$fs_candidate" -c 'import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)' 2>/dev/null; then
    fs_python="$fs_candidate"
    break
  fi
done
if [ -z "$fs_python" ]; then
  echo 'Python 3.11+ is required. Double-click START-MAC.command, choose 2 to set up as a Contributor, and retry.'
  if [ -t 0 ]; then read -r -p 'Press Return to close...' _answer; fi
  exit 1
fi
printf '  Keep this window open. To stop the preview, press Ctrl+C or close the window.\n'
if ! "$fs_python" tooling/preview/serve_project.py --build-atlas --open-browser; then
  echo 'Preview failed. Check the error above and whether port 43117 is already used.'
  if [ -t 0 ]; then read -r -p 'Press Return to close...' _answer; fi
  exit 1
fi
