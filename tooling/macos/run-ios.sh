#!/bin/bash
# Run the app on an iPhone simulator. Uses practice Firebase if it is running,
# otherwise Preview mode; never cloud Firebase.
set -euo pipefail
. "$(dirname "$0")/common.sh"
if [ "${1:-}" = "--self-test" ]; then
  test -f "$FS_ROOT/mobile/pubspec.yaml" || { fs_fail 'Flutter project missing.'; exit 1; }
  # Window app choice: Simulator.app first, then DeviceHub.app (Xcode 27), then none.
  fs_t="$(mktemp -d)"; trap 'rm -rf "$fs_t"' EXIT
  mkdir -p "$fs_t/none/Contents/Developer" "$fs_t/hub/Contents/Developer" "$fs_t/hub/Contents/Applications/DeviceHub.app" \
    "$fs_t/both/Contents/Developer/Applications/Simulator.app" "$fs_t/both/Contents/Applications/DeviceHub.app"
  if fs_simulator_window_app "$fs_t/none/Contents/Developer" >/dev/null; then fs_fail 'Found a simulator window app where there is none.'; exit 1; fi
  [ "$(fs_simulator_window_app "$fs_t/hub/Contents/Developer")" = "$fs_t/hub/Contents/Applications/DeviceHub.app" ] || { fs_fail 'DeviceHub.app fallback not chosen.'; exit 1; }
  [ "$(fs_simulator_window_app "$fs_t/both/Contents/Developer")" = "$fs_t/both/Contents/Developer/Applications/Simulator.app" ] || { fs_fail 'Simulator.app not preferred.'; exit 1; }
  if fs_in_synced_folder "$fs_t/none"; then fs_fail 'A plain temporary folder was reported as cloud-synced.'; exit 1; fi
  if [ -x /usr/bin/xattr ] && /usr/bin/xattr -w com.apple.file-provider-domain-id self-test "$fs_t/hub" 2>/dev/null; then
    fs_in_synced_folder "$fs_t/hub/Contents" || { fs_fail 'A folder inside a cloud-synced folder was not detected.'; exit 1; }
  fi
  fs_ok 'Mac iPhone simulator launcher self-test passed.'
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'The iPhone simulator needs macOS.'; exit 1; }
fs_flutter_version_ok || { fs_fail 'Pinned Flutter SDK missing. Run launchers/mac/1 - Set up this computer.command.'; exit 1; }
{ [ -d "$FS_ROOT/mobile/ios" ] && fs_has xcrun && [ -d /Applications/Xcode.app ]; } || { fs_fail 'iPhone testing is not set up (Xcode missing). Run START-MAC.command > 8 > 5.'; exit 1; }
fs_xcode_version_ok || { fs_fail "$FS_XCODE_TOO_OLD"; exit 1; }
fs_warn_synced_folder
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
fs_open_simulator_window
fs_mode=preview
if fs_has nc && nc -G 1 -z 127.0.0.1 9099 >/dev/null 2>&1 && nc -G 1 -z 127.0.0.1 8080 >/dev/null 2>&1 && nc -G 1 -z 127.0.0.1 9199 >/dev/null 2>&1; then fs_mode=emulator; fi
fs_info "Running on the iPhone simulator in $fs_mode mode (practice Firebase only when it is running). Press q here to stop."
cd "$FS_ROOT/mobile"
# Flutter copies Swift Package Manager plugins with rsync, already during pub get.
# Homebrew's rsync, when it is ahead of /usr/bin/rsync on PATH, fails unless this
# folder already exists.
mkdir -p "$FS_ROOT/mobile/build/ios/SourcePackages"
"$FS_FLUTTER" pub get
if [ "$fs_mode" = emulator ]; then
  "$FS_FLUTTER" run -d "$fs_device" --dart-define=FS_ENV=emulator
else
  "$FS_FLUTTER" run -d "$fs_device"
fi
