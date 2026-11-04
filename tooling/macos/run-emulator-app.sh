#!/bin/bash
# Launch Flutter Chrome against local demo emulators, never cloud Firebase.
set -euo pipefail
. "$(dirname "$0")/common.sh"
if [ "${1:-}" = "--self-test" ]; then
  test -f "$FS_ROOT/mobile/pubspec.yaml" || { fs_fail 'Flutter project missing.'; exit 1; }
  fs_ok 'Mac emulator Flutter launcher self-test passed.'
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'Mac Flutter emulator launcher requires macOS.'; exit 1; }
fs_flutter_version_ok || { fs_fail 'Pinned Flutter SDK missing. Run launchers/mac/1 - Set up this computer.command.'; exit 1; }
for fs_port in 9099 8080 9199; do
  if ! fs_has nc || ! nc -G 2 -z 127.0.0.1 "$fs_port" >/dev/null 2>&1; then
    fs_fail "Local Firebase emulator port $fs_port is not responding. Start launchers/mac/3 - Start practice Firebase.command first."
    exit 1
  fi
done
fs_info 'Running against local demo-forgedandsent ONLY (FS_ENV=emulator).'
cd "$FS_ROOT/mobile"
"$FS_FLUTTER" pub get
"$FS_FLUTTER" run -d chrome --dart-define=FS_ENV=emulator
