#!/bin/bash
# Run the app on an iPhone simulator. Uses practice Firebase if it is running,
# otherwise Preview mode; never cloud Firebase.
set -euo pipefail
. "$(dirname "$0")/common.sh"
if [ "${1:-}" = "--self-test" ]; then
  test -f "$FS_ROOT/mobile/pubspec.yaml" || { fs_fail 'Flutter project missing.'; exit 1; }
  fs_ok 'Mac iPhone simulator launcher self-test passed.'
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'The iPhone simulator needs macOS.'; exit 1; }
fs_flutter_version_ok || { fs_fail 'Pinned Flutter SDK missing. Run launchers/mac/1 - Set up this computer.command.'; exit 1; }
[ -d "$FS_ROOT/mobile/ios" ] && fs_has xcrun || { fs_fail 'iPhone testing is not set up. Run START-MAC.command > 8 > 5.'; exit 1; }
open -a Simulator
# Boot the newest available iPhone if none is running yet.
fs_device="$(xcrun simctl list devices booted -j | python3 -c 'import json,sys
d=json.load(sys.stdin)["devices"]
print(next((x["udid"] for r in d.values() for x in r if x.get("name","").startswith("iPhone")), ""))')"
if [ -z "$fs_device" ]; then
  fs_device="$(xcrun simctl list devices available -j | python3 -c 'import json,sys
d=json.load(sys.stdin)["devices"]
phones=[x["udid"] for k in sorted(d, reverse=True) if "iOS" in k for x in d[k] if x.get("name","").startswith("iPhone")]
print(phones[0] if phones else "")')"
  [ -n "$fs_device" ] || { fs_fail 'No iPhone simulator found. Open Xcode > Settings > Components and add an iOS simulator.'; exit 1; }
  xcrun simctl boot "$fs_device" 2>/dev/null || true
fi
fs_mode=preview
if fs_has nc && nc -G 1 -z 127.0.0.1 9099 >/dev/null 2>&1 && nc -G 1 -z 127.0.0.1 8080 >/dev/null 2>&1 && nc -G 1 -z 127.0.0.1 9199 >/dev/null 2>&1; then fs_mode=emulator; fi
fs_info "Running on the iPhone simulator in $fs_mode mode (practice Firebase only when it is running). Press q here to stop."
cd "$FS_ROOT/mobile"
"$FS_FLUTTER" pub get
if [ "$fs_mode" = emulator ]; then
  "$FS_FLUTTER" run -d "$fs_device" --dart-define=FS_ENV=emulator
else
  "$FS_FLUTTER" run -d "$fs_device"
fi
