#!/bin/bash
# Finder friendly Mac wizard, no automatic cloud sign-in or deployment.
set -euo pipefail
. "$(dirname "$0")/common.sh"
if [ "${1:-}" = "--self-test" ]; then
  /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Preview --self-test
  /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Contributor --self-test
  /bin/bash "$FS_ROOT/tooling/macos/verify.sh" --self-test
  /bin/bash "$FS_ROOT/tooling/macos/start-emulators.sh" --self-test
  /bin/bash "$FS_ROOT/tooling/macos/run-emulator-app.sh" --self-test
  test -f "$FS_ROOT/docs/development/FIRST-CONTRIBUTION.md"
  fs_ok 'Mac wizard self-test passed.'
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'This wizard requires macOS.'; exit 1; }
FS_SELECTED_PROFILE=Preview
printf '\n==== Forged & Sent: first run on Mac ===\n'
printf 'Uses your existing Git clone. Firebase cloud and paid AI accounts are not required.\n'
while :; do
  printf '\n1. Just preview the Flutter app\n2. Set up Contributor tools\n3. Diagnose setup\n4. Run Flutter in Chrome\n5. Start local Firebase emulators in another window\n6. Run Flutter with local Firebase\n7. Open VS Code and first-contribution guide\n8. More options (Git identity, sign-in, Atlas)\n0. Exit\nYour choice: '
  IFS= read -r fs_choice || break
  case "$fs_choice" in
    1) FS_SELECTED_PROFILE=Preview; /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Preview || true;;
    2) FS_SELECTED_PROFILE=Contributor; /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Contributor || true;;
    3) /bin/bash "$FS_ROOT/tooling/macos/verify.sh" --profile "$FS_SELECTED_PROFILE" || true;;
    4) /bin/bash "$FS_ROOT/tooling/macos/run-app.sh" || true;;
    5) open "$FS_ROOT/START-EMULATORS-MAC.command";;
    6) open "$FS_ROOT/RUN-EMULATOR-APP-MAC.command";;
    7)
      fs_code_bin="$(fs_code || true)"
      if [ -n "$fs_code_bin" ]; then "$fs_code_bin" "$FS_ROOT"; else fs_warn 'VS Code missing. Run Contributor setup.'; fi
      open "$FS_ROOT/docs/development/FIRST-CONTRIBUTION.md"
      ;;
    8)
      printf '\n1. Git name/email\n2. GitHub CLI sign-in\n3. Open Architecture Atlas\n4. Read Mac quickstart\n0. Back\nChoice: '
      IFS= read -r fs_more || fs_more=0
      case "$fs_more" in
        1) fs_ensure_git_identity || true;;
        2) if fs_has gh && fs_question 'Sign in to GitHub CLI?'; then gh auth login; else fs_warn 'Login skipped or GitHub CLI missing.'; fi;;
        3) open "$FS_ROOT/ARCHITECTURE-MAC.command";;
        4) open "$FS_ROOT/docs/development/MACBOOK-QUICKSTART.md";;
      esac
      ;;
    0) break;;
    *) fs_warn 'Choose one of the displayed numbers.';;
  esac
done
