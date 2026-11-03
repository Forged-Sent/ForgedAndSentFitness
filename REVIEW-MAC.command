#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
echo 'Forged & Sent: optional independent AI review (may consume paid model usage)'
if command -v python3.12 >/dev/null 2>&1 && python3.12 -c 'import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)'; then
  exec python3.12 tooling/review/review.py "$@"
elif command -v python3 >/dev/null 2>&1 && python3 -c 'import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)'; then
  exec python3 tooling/review/review.py "$@"
fi
echo 'Python 3.11+ is missing. Run SETUP-DEVELOPER-MAC.command first.'
exit 1
