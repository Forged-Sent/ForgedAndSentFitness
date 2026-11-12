#!/bin/bash
# Optional personal zsh setup; Return declines.
cd "$(dirname "$0")/../../.." || exit 1
if [ ! -f tooling/macos/forge-shell.sh ]; then
  echo 'Use the complete Git clone; see docs/development/MACBOOK-QUICKSTART.md.'
  exit 1
fi
/bin/bash tooling/macos/forge-shell.sh "$@"
status=$?
if [ -t 0 ] && [ -z "${CI:-}" ]; then printf '\nPress Return to close this window...'; IFS= read -r _unused || true; fi
exit "$status"
