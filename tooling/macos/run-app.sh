#!/bin/bash
set -euo pipefail
. "$(dirname "$0")/common.sh"
[ "$(uname -s)" = Darwin ] || { fs_fail 'Mac preview launcher requires macOS.'; exit 1; }
fs_flutter_version_ok || { fs_fail 'Flutter 3.47.8 missing. Run SETUP-MAC.command.'; exit 1; }
cd "$FS_ROOT/mobile"
if [ ! -f web/index.html ]; then "$FS_FLUTTER" create --platforms=web --project-name=forged_and_sent --org=com.forgedandsent .; fi
"$FS_FLUTTER" pub get
"$FS_FLUTTER" run -d chrome
