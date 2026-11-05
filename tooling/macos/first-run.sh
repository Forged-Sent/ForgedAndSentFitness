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
FS_IOS_STATUS=skipped
fs_setup_ios_step() {
  local fs_rc=0
  printf '\n=== iPhone testing (Xcode + iOS simulator) ===\n'
  fs_setup_ios || fs_rc=$?
  case "$fs_rc" in 0) FS_IOS_STATUS=ready;; 2) FS_IOS_STATUS=xcode-pending;; *) FS_IOS_STATUS=failed; fs_warn 'iPhone setup needs attention; the rest of setup is fine.';; esac
}
fs_setup_contributor() {
  local fs_status=0 fs_ios=0
  FS_SELECTED_PROFILE=Contributor; fs_remember_profile Contributor
  # Asked before the long install so the person can walk away afterwards.
  printf 'Also set up iPhone testing? Needs Xcode from the App Store (your Apple ID) and about 40 GB free.\n'
  if [ -t 0 ] && fs_question 'Set up iPhone testing too?'; then fs_ios=1; fi
  FS_FROM_WIZARD=1 /bin/bash "$FS_ROOT/tooling/macos/setup.sh" --profile Contributor || {
    fs_status=$?; fs_warn 'Contributor setup needs attention; see the messages above, then run 5 - Check my setup.'; }
  # Always offered, even after an install warning; only prompts if not yet set.
  printf '\n=== Your Git commit name and email ===\n'
  fs_ensure_git_identity || fs_warn 'Git name/email not set yet. Before your first commit: START-MAC.command > 8 > 1.'
  if [ "$fs_status" -eq 0 ] && [ "$fs_ios" -eq 1 ]; then fs_setup_ios_step; fi
  if [ "$fs_status" -eq 0 ]; then fs_walkthrough; fi
  return "$fs_status"
}
fs_practice_firebase_up() {
  local fs_port
  fs_has nc || return 1
  for fs_port in 9099 8080 9199; do nc -G 1 -z 127.0.0.1 "$fs_port" >/dev/null 2>&1 || return 1; done
}
# After a successful Contributor setup: start practice Firebase, open the app on it,
# let the person confirm what they saw, then print a short checklist.
FS_WALKTHROUGH_RAN=0
fs_walkthrough() {
  local fs_up=0 fs_app=0 fs_waited=0 fs_reply fs_git=' '
  printf '\n=== Try it now (about 2 minutes) ===\n'
  printf 'This starts practice Firebase in a second Terminal window, then opens the app connected to it.\n'
  printf 'Try it now? [Y/n]: '
  IFS= read -r fs_reply || fs_reply=n
  case "$fs_reply" in n|N|no|NO|No) return 0;; esac
  FS_WALKTHROUGH_RAN=1
  if fs_practice_firebase_up; then fs_up=1; else
    open "$FS_ROOT/launchers/mac/3 - Start practice Firebase.command"
    printf 'A second Terminal window opened for practice Firebase. Leave it open.\n'
    while [ "$fs_waited" -lt 180 ]; do
      sleep 3; fs_waited=$((fs_waited + 3))
      printf '  waiting for practice Firebase to be ready...\n'
      if fs_practice_firebase_up; then fs_up=1; break; fi
    done
  fi
  if [ "$fs_up" -eq 1 ]; then
    fs_ok 'Practice Firebase is ready.'
    printf '\nChrome will now open the app. Look for this line on the page:\n'
    printf '  Verified local Auth, Firestore and Storage emulators (demo-forgedandsent).\n'
    printf 'Then come back to THIS window and press q to stop the app.\n'
    if /bin/bash "$FS_ROOT/tooling/macos/run-emulator-app.sh"; then
      printf 'Did the page show "Verified local Auth, Firestore and Storage emulators"? [Y/n]: '
      IFS= read -r fs_reply || fs_reply=n
      case "$fs_reply" in n|N|no|NO|No) ;; *) fs_app=1;; esac
    fi
  else
    fs_warn 'Practice Firebase did not report ready within 3 minutes. Read the messages in its window.'
  fi
  [ -n "$(git -C "$FS_ROOT" config --get user.email 2>/dev/null || true)" ] && fs_git=x
  printf '\n=== Your checklist ===\n'
  printf '  [x] Tools installed\n'
  printf '  [%s] Git commit name and email%s\n' "$fs_git" "$([ "$fs_git" = x ] || printf '  (START-MAC.command > 8 > 1)')"
  printf '  [%s] Practice Firebase started%s\n' "$([ "$fs_up" -eq 1 ] && printf x || printf ' ')" "$([ "$fs_up" -eq 1 ] || printf '  (launchers/mac/3 - Start practice Firebase.command)')"
  printf '  [%s] App connected to practice Firebase%s\n' "$([ "$fs_app" -eq 1 ] && printf x || printf ' ')" "$([ "$fs_app" -eq 1 ] || printf '  (launchers/mac/4 - Run app with practice Firebase.command)')"
  case "$FS_IOS_STATUS" in
    ready) printf '  [x] iPhone simulator (run launchers/mac/more/Run app on iPhone simulator.command)\n';;
    xcode-pending) printf '  [ ] iPhone: install Xcode from the App Store, then run step 1 again and answer yes\n';;
    failed) printf '  [ ] iPhone: see the messages above, then START-MAC.command > 8 > 5\n';;
    *) printf '  iPhone testing: optional, START-MAC.command > 8 > 5. Android on a Mac is not automated yet.\n';;
  esac
  printf '\nNext: make your first change with docs/development/FIRST-CONTRIBUTION.md (menu 7 opens it with VS Code).\n'
  if [ "$fs_up" -eq 1 ]; then printf 'Close the practice Firebase window (Control-C) when you are done for the day.\n'; fi
}
fs_check_setup() {
  printf 'Checking your setup as: %s (choose 1 or 6 in START-MAC.command to switch).\n' "$FS_SELECTED_PROFILE"
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
  if [ "$fs_status" -ne 0 ] && [ "${2:-}" != check ]; then
    printf '\n=== Setup did not finish ===\n'
    printf 'Fix the first [ERROR] shown above (it says what to do), then double-click the same\n'
    printf 'setup file again. Finished parts are reused, so nothing is downloaded twice.\n'
    printf 'Still stuck? Run 5 - Check my setup.command.\n'
    exit "$fs_status"
  fi
  if [ "$FS_WALKTHROUGH_RAN" -eq 1 ]; then exit 0; fi
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
  # 1-5 match the numbered files in launchers/mac.
  printf '\n1. Set up this computer (full setup: edit, test, submit PRs)\n2. Run the app in Chrome\n3. Start practice Firebase (opens another window)\n4. Run the app with practice Firebase\n5. Check my setup\n6. Preview-only setup (quickest; view only)\n7. Open VS Code and first-contribution guide\n8. More options (Git identity, sign-in, Atlas)\n0. Exit\nYour choice: '
  IFS= read -r fs_choice || break
  case "$fs_choice" in
    1) fs_setup_contributor || true;;
    2) /bin/bash "$FS_ROOT/tooling/macos/run-app.sh" || true;;
    3) open "$FS_ROOT/launchers/mac/3 - Start practice Firebase.command";;
    4) open "$FS_ROOT/launchers/mac/4 - Run app with practice Firebase.command";;
    5) fs_check_setup || true;;
    6) fs_setup_preview || true;;
    7)
      fs_code_bin="$(fs_code || true)"
      if [ -n "$fs_code_bin" ]; then "$fs_code_bin" "$FS_ROOT"; else fs_warn 'VS Code missing. Run Contributor setup.'; fi
      open "$FS_ROOT/docs/development/FIRST-CONTRIBUTION.md"
      ;;
    8)
      printf '\n1. Git name/email\n2. GitHub CLI sign-in\n3. Open Architecture Atlas\n4. Read Mac quickstart\n5. iPhone testing (Xcode + iOS simulator)\n0. Back\nChoice: '
      IFS= read -r fs_more || fs_more=0
      case "$fs_more" in
        1) fs_ensure_git_identity || true;;
        2) if fs_has gh && fs_question 'Sign in to GitHub CLI?'; then gh auth login; else fs_warn 'Login skipped or GitHub CLI missing.'; fi;;
        3) open "$FS_ROOT/launchers/mac/more/Architecture Atlas.command";;
        4) open "$FS_ROOT/docs/development/MACBOOK-QUICKSTART.md";;
        5) fs_setup_ios_step;;
      esac
      ;;
    0) break;;
    *) fs_warn 'Choose one of the displayed numbers.';;
  esac
done
