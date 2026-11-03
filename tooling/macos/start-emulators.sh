#!/bin/bash
# Run only the demo Auth, Firestore and Storage emulators. No cloud login.
set -euo pipefail
. "$(dirname "$0")/common.sh"
if [ "${1:-}" = "--self-test" ]; then
  test -f "$FS_ROOT/.firebaserc" && test -f "$FS_ROOT/firebase.json" || { fs_fail 'Demo configuration missing.'; exit 1; }
  fs_ok 'Local Mac emulator launcher configuration self-test passed.'
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'Mac Firebase launcher requires macOS.'; exit 1; }
fs_has firebase || { fs_fail 'Firebase CLI missing. Run SETUP-DEVELOPER-MAC.command.'; exit 1; }
fs_home="$(fs_java21_home || true)"
[ -n "$fs_home" ] || { fs_fail 'JDK 21 missing. Run SETUP-DEVELOPER-MAC.command.'; exit 1; }
export JAVA_HOME="$fs_home"
export PATH="$JAVA_HOME/bin:$PATH"
cd "$FS_ROOT"
fs_info 'Launching local demo-forgedandsent Auth, Firestore and Storage (NO cloud login).'
firebase emulators:start --project demo-forgedandsent --only auth,firestore,storage
