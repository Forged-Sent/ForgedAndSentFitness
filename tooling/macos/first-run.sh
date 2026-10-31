#!/bin/bash
# Finder friendly Mac first-run wizard. No automatic cloud logins.
set -euo pipefail
. "$(dirname "$0")/common.sh"
if [ "$#" -gt 0 ] && [ "$1" = --self-test ]; then
  /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Preview --self-test
  /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Contributor --self-test
  /bin/bash "$FS_ROOT/tooling/macos/verify.sh" --self-test
  fs_ok 'Mac wizard self-test passed.'
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'This wizard requires a MacBook.'; exit 1; }
printf '\n===== Forged & Sent MacBook first run =====\n'
printf 'No Firebase login, PROD credentials, or remote script execution is automatic.\n'
while :; do
  printf '\n1. Set up browser Preview\n2. Set up Contributor tools\n3. Diagnose Mac setup\n4. Run Flutter preview in Chrome\n5. Sign in to GitHub (optional)\n6. Read Mac quickstart\n0. Exit\nYour choice: '
  IFS= read -r fs_choice || break
  case "$fs_choice" in
    1) /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Preview || true;;
    2) /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Contributor || true;;
    3) /bin/bash "$FS_ROOT/tooling/macos/verify.sh" --profile Contributor || true;;
    4) /bin/bash "$FS_ROOT/tooling/macos/run-app.sh" || true;;
    5) if fs_has gh && fs_question 'Run interactive GitHub login?'; then gh auth login; else fs_warn 'GitHub login declined or CLI missing.'; fi;;
    6) open "$FS_ROOT/docs/development/MACBOOK-QUICKSTART.md";;
    0) break;;
    *) fs_warn 'Choose one of the menu numbers.';;
  esac
done
