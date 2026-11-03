#!/bin/bash
cd "$(dirname "$0")" || exit 1
/bin/bash tooling/macos/start-emulators.sh "$@"
status=$?
if [ -t 0 ] && [ -z "${CI:-}" ]; then
  printf '\nPress Return to close this window...'
  IFS= read -r answer || true
fi
exit "$status"
