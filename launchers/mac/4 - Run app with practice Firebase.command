#!/bin/bash
# Run app with practice Firebase. Finder double-click entrypoint; does not bypass macOS security dialogs.
cd "$(dirname "$0")/../.." || exit 1
if [ ! -f tooling/macos/common.sh ]; then
  echo 'The project files around this launcher are missing. Use a full Git clone (see docs/development/MACBOOK-QUICKSTART.md).'
  exit 1
fi
/bin/bash tooling/macos/run-emulator-app.sh "$@"
status=$?
if [ -t 0 ] && [ -z "${CI:-}" ]; then printf '\nPress Return to close this window...'; IFS= read -r _unused || true; fi
exit "$status"
