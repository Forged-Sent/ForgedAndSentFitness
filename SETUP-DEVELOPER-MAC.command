#!/bin/bash
# Finder double-click entrypoint; does not bypass macOS security dialogs.
cd "$(dirname "$0")" || exit 1
/bin/bash tooling/macos/setup.sh --profile Contributor "$@"
status=$?
if [ -t 0 ] && [ -z "$CI" ]; then printf "\nPress Return to close this window..."; IFS= read -r unused || true; fi
exit "$status"
