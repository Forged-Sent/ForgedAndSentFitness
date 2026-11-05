#!/bin/bash
set -euo pipefail
# Optional AI code review. Finder double-click entrypoint; does not bypass macOS security dialogs.
cd "$(dirname "$0")/../../.."
echo 'Forged & Sent: optional independent AI review (may consume paid model usage)'
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
exec "$fs_python" tooling/review/review.py "$@"
