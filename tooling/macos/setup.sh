#!/bin/bash
# Mac Preview and Contributor only. No cloud Firebase MCP or automatic login.
set -euo pipefail
. "$(dirname "$0")/common.sh"
FS_PROFILE=Preview
FS_CI=0
FS_SELFTEST=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile) FS_PROFILE="$2"; shift 2;;
    --ci) FS_CI=1; shift;;
    --self-test) FS_SELFTEST=1; shift;;
    *) fs_fail "Unknown option: $1"; exit 2;;
  esac
done
case "$FS_PROFILE" in
  Preview|Contributor) ;;
  Mobile|Maintainer) fs_fail 'Full Mobile and Maintainer installers are scheduled for PR #4.'; exit 2;;
  *) fs_fail 'Unknown profile'; exit 2;;
esac
if [ "$FS_SELFTEST" -eq 1 ]; then
  [ -f "$FS_ROOT/mobile/pubspec.yaml" ] && [ -f "$FS_ROOT/.vscode/mcp.json" ] || fs_fail 'Repository is incomplete.'
  fs_ok "Mac $FS_PROFILE bootstrap self-test passed (no changes made)."
  exit 0
fi
[ "$(uname -s)" = Darwin ] || { fs_fail 'This installer runs on macOS.'; exit 1; }
if [ "$FS_CI" -eq 1 ]; then
  fs_has flutter || { fs_fail 'CI must preinstall Flutter.'; exit 1; }
  fs_ok 'Mac CI non-mutating bootstrap check passed.'
  exit 0
fi
fs_info "Forged & Sent MacBook setup ($FS_PROFILE)"
fs_require_clt || exit 2
fs_require_brew || exit 2
fs_brew_cask visual-studio-code 'Visual Studio Code.app' code
fs_brew_cask google-chrome 'Google Chrome.app' ''
fs_ensure_flutter
"$FS_FLUTTER" config --enable-web
fs_editor_extensions
if [ "$FS_PROFILE" = Contributor ]; then
  fs_brew_formula node node
  fs_node_major="$(node -p 'Number(process.versions.node.split(".")[0])' 2>/dev/null || printf '0')"
  if [ "$fs_node_major" -lt 20 ]; then fs_fail 'Node.js 20+ is required for the pinned Firebase CLI. Update Node before retrying; no existing install was changed.'; exit 1; fi
  fs_brew_formula gh gh
  fs_npm_firebase
  fs_brew_cask codex '' codex
  fs_brew_cask claude-code '' claude
  fs_info 'No Firebase cloud authentication, production access, or Firebase cloud MCP is installed.'
fi
cd "$FS_ROOT/mobile"
"$FS_FLUTTER" create --platforms=web --project-name=forged_and_sent --org=com.forgedandsent .
"$FS_FLUTTER" pub get
"$FS_FLUTTER" analyze
"$FS_FLUTTER" test
"$FS_FLUTTER" build web --release
fs_ok 'Flutter browser preview build and tests passed.'
if [ "$FS_PROFILE" = Contributor ]; then fs_warn 'App-to-emulator wiring remains a PR #4 requirement; Contributor readiness is incomplete.'; fi
fs_info 'Double-click RUN-APP-MAC.command to launch Chrome.'
