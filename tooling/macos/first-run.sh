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
  test -f "$FS_ROOT/launchers/mac/3 - Start practice Firebase.command"
  test -f "$FS_ROOT/launchers/mac/4 - Run app with practice Firebase.command"
  fs_ok 'Mac wizard self-test passed.'
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'This wizard requires macOS.'; exit 1; }
FS_SELECTED_PROFILE="$(fs_installed_profile)"
fs_setup_preview() {
  FS_SELECTED_PROFILE=Preview; fs_remember_profile Preview
  /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Preview
}
fs_setup_contributor() {
  local fs_status=0
  FS_SELECTED_PROFILE=Contributor; fs_remember_profile Contributor
  FS_FROM_WIZARD=1 /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Contributor || {
    fs_status=$?; fs_warn 'Contributor setup needs attention; see the messages above, then run 5 - Check my setup.'; }
  # Always offered, even after an install warning; only prompts if not yet set.
  printf '\n=== Your Git commit name and email ===\n'
  fs_ensure_git_identity || fs_warn 'Git name/email not set yet. Before your first commit: START-MAC.command > 8 > 1.'
  return "$fs_status"
}
fs_check_setup() {
  printf 'Checking your setup as: %s (choose 1 or 2 in START-MAC.command to switch).\n' "$FS_SELECTED_PROFILE"
  /bin/bash "$FS_ROOT/tooling/macos/verify.sh" --profile "$FS_SELECTED_PROFILE"
}
# Numbered launchers in launchers/mac run one step, then show what to do next.
if [ "${1:-}" = "--action" ]; then
  fs_status=0
  case "${2:-}" in
    contributor) fs_setup_contributor || fs_status=$?;;
    preview) fs_setup_preview || fs_status=$?;;
    check) fs_check_setup || fs_status=$?;;
    *) fs_fail "Unknown action '${2:-}'. Use contributor, preview or check."; exit 2;;
  esac
  printf '\n=== What to do next ===\n'
  printf 'Open the launchers/mac folder and double-click the next numbered file:\n'
  printf '  2 - Run the app.command                     (the app in Chrome)\n'
  printf '  3 - Start practice Firebase.command         (local practice database; keep it open)\n'
  printf '  4 - Run app with practice Firebase.command  (after step 3 says ready)\n'
  printf 'Then read docs/development/FIRST-CONTRIBUTION.md to make your first change.\n'
  exit "$fs_status"
fi
printf '\n==== Forged & Sent: first run on Mac ===\n'
printf 'Uses your existing Git clone. Firebase cloud and paid AI accounts are not required.\n'
while :; do
  printf '\n1. Just preview the Flutter app (quickest; view only)\n2. Set up as a Contributor (full setup: edit, test, submit PRs)\n3. Check or repair my setup\n4. Run Flutter in Chrome\n5. Start local Firebase emulators in another window\n6. Run Flutter with local Firebase\n7. Open VS Code and first-contribution guide\n8. More options (Git identity, sign-in, Atlas)\n0. Exit\nYour choice: '
  IFS= read -r fs_choice || break
  case "$fs_choice" in
    1) fs_setup_preview || true;;
    2) fs_setup_contributor || true;;
    3) fs_check_setup || true;;
    4) /bin/bash "$FS_ROOT/tooling/macos/run-app.sh" || true;;
    5) open "$FS_ROOT/launchers/mac/3 - Start practice Firebase.command";;
    6) open "$FS_ROOT/launchers/mac/4 - Run app with practice Firebase.command";;
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
        3) open "$FS_ROOT/launchers/mac/more/Architecture Atlas.command";;
        4) open "$FS_ROOT/docs/development/MACBOOK-QUICKSTART.md";;
      esac
      ;;
    0) break;;
    *) fs_warn 'Choose one of the displayed numbers.';;
  esac
done
