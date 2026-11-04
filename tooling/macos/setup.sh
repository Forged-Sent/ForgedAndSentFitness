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
  Mobile|Maintainer) fs_fail 'Mac automatic setup currently supports Preview and Contributor. Native device setup and cloud DEV authorization are separate manual workflows.'; exit 2;;
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
FS_AI_CHOICE=none
if [ "$FS_PROFILE" = Contributor ] && [ -t 0 ]; then
  printf '\nOptional AI assistant (one is enough): 0=None, 1=Codex, 2=Claude, 3=GitHub Copilot [0]: '
  IFS= read -r fs_choice || fs_choice=0
  case "$fs_choice" in 1) FS_AI_CHOICE=codex;; 2) FS_AI_CHOICE=claude;; 3) FS_AI_CHOICE=copilot;; esac
fi
fs_editor_extensions "$FS_AI_CHOICE"
if [ "$FS_PROFILE" = Contributor ]; then
  fs_brew_formula node node
  fs_node_major="$(node -p 'Number(process.versions.node.split(".")[0])' 2>/dev/null || printf '0')"
  if [ "$fs_node_major" -lt 20 ]; then fs_fail 'Node.js 20+ is required for the pinned Firebase CLI. Update Node before retrying; no existing install was changed.'; exit 1; fi
  fs_brew_formula gh gh
  fs_npm_firebase
  fs_ensure_java21
  fs_ensure_python
  fs_brew_formula gitleaks gitleaks
  fs_enable_git_hooks
  if [ "$FS_AI_CHOICE" = codex ]; then fs_brew_cask codex '' codex; fi
  if [ "$FS_AI_CHOICE" = claude ]; then fs_brew_cask claude-code '' claude; fi
  fs_offer_flutter_path
  # A typo here must never abort the rest of setup. The wizard asks again after
  # setup (even a failed one), so it sets FS_FROM_WIZARD to avoid a double prompt.
  if [ -t 0 ] && [ -z "${FS_FROM_WIZARD:-}" ]; then
    fs_ensure_git_identity || fs_warn 'Git name/email not set yet. Before your first commit: START-MAC.command > 8 > 1.'
  fi
  fs_info 'No Firebase cloud authentication, production access, or Firebase cloud MCP is installed.'
fi
cd "$FS_ROOT/mobile"
"$FS_FLUTTER" create --platforms=web --project-name=forged_and_sent --org=com.forgedandsent .
"$FS_FLUTTER" pub get
"$FS_FLUTTER" analyze
"$FS_FLUTTER" test
"$FS_FLUTTER" build web --release
fs_ok 'Flutter browser preview build and tests passed.'
if [ "$FS_PROFILE" = Contributor ]; then
  fs_info 'Local Firebase wiring is implemented. Test it with launchers/mac/3 - Start practice Firebase.command and launchers/mac/4 - Run app with practice Firebase.command.'
  fs_warn 'Live emulator handshake and agent MCP connections still require hands-on verification.'
fi
fs_info 'Double-click launchers/mac/2 - Run the app.command to launch Chrome.'
