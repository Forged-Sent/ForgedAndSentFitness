#!/bin/bash
# Mac diagnostics are read-only and do not authenticate cloud providers.
set -euo pipefail
. "$(dirname "$0")/common.sh"
FS_PROFILE=Preview
FS_SELFTEST=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile) FS_PROFILE="$2"; shift 2;;
    --self-test) FS_SELFTEST=1; shift;;
    *) fs_fail "Unknown option $1"; exit 2;;
  esac
done
case "$FS_PROFILE" in Preview|Contributor|Mobile|Maintainer) ;; *) fs_fail 'Unknown profile'; exit 2;; esac
fs_required(){
  case "$1" in
    AppleCLT|Git|Flutter|Chrome|VSCode|FirebaseMCPIsolation) return 0;;
    Node|Npm|GitHubCLI|FirebaseCLI|CodexCLI|ClaudeCLI|EmulatorWiring) [ "$FS_PROFILE" != Preview ]; return;;
    AndroidStudio|Maestro|Java) [ "$FS_PROFILE" = Mobile ] || [ "$FS_PROFILE" = Maintainer ]; return;;
    DevCloudIdentity) [ "$FS_PROFILE" = Maintainer ]; return;;
    *) return 1;;
  esac
}
if [ "$FS_SELFTEST" -eq 1 ]; then
  fs_required Git || exit 1
  FS_PROFILE=Preview; if fs_required Maestro; then exit 1; fi
  FS_PROFILE=Mobile; fs_required Maestro || exit 1
  fs_ok 'Mac diagnostic profile self-tests passed. No system state was changed.'
  exit 0
fi
fs_report="$(mktemp -t ForgedAndSent-Mac)"
chmod 600 "$fs_report"
fs_failed=0
fs_line(){ printf '%s\n' "$1" | tee -a "$fs_report"; }
fs_record(){
  fs_id="$1"; fs_state="$2"; fs_reason="$3"; fs_fix="$4"
  if fs_required "$fs_id"; then fs_kind=REQUIRED; else fs_kind=OPTIONAL; fi
  fs_line "[$fs_state] $fs_id ($fs_kind)"
  if [ "$fs_state" != Ready ]; then
    fs_line "  WHY: $fs_reason"
    fs_line "  FIX: $fs_fix"
    if [ "$fs_kind" = REQUIRED ]; then fs_failed=1; fi
  fi
}
fs_probe(){
  if fs_has "$2"; then fs_record "$1" Ready '' ''
  else fs_record "$1" Missing 'Executable not detected.' "$3"; fi
}
fs_line "Forged & Sent MacBook diagnostic | $FS_PROFILE"
fs_line 'Configured MCP servers are NOT Ready until a live initialize + tools/list handshake succeeds.'
fs_line 'No user names, account tokens, project IDs or private file paths are included.'
if xcode-select -p >/dev/null 2>&1; then fs_record AppleCLT Ready '' ''; else fs_record AppleCLT Missing 'Apple Command Line Tools missing.' 'Complete the macOS developer tools installation dialog.'; fi
fs_probe Git git 'Install Apple Command Line Tools.'
if [ -d '/Applications/Google Chrome.app' ] || [ -d "$HOME/Applications/Google Chrome.app" ]; then fs_record Chrome Ready '' ''; else fs_record Chrome Missing 'Chrome not found.' 'Run SETUP-MAC.command.'; fi
if fs_code >/dev/null 2>&1; then fs_record VSCode Ready '' ''; else fs_record VSCode Missing 'VS Code not found.' 'Run SETUP-MAC.command.'; fi
if fs_flutter_version_ok; then fs_record Flutter Ready '' ''; else fs_record Flutter Outdated 'Flutter 3.47.8 not available in the project-pinned SDK location.' 'Run SETUP-MAC.command.'; fi
fs_probe Node node 'Run SETUP-DEVELOPER-MAC.command.'
fs_probe Npm npm 'Install Node with Contributor setup.'
fs_probe GitHubCLI gh 'Run SETUP-DEVELOPER-MAC.command.'
if fs_has firebase && [ "$(firebase --version 2>/dev/null || true)" = "$FS_FIREBASE_VERSION" ]; then fs_record FirebaseCLI Ready '' ''; else fs_record FirebaseCLI Outdated 'Pinned local Firebase CLI unavailable.' 'Run SETUP-DEVELOPER-MAC.command, no Firebase login needed.'; fi
fs_probe CodexCLI codex 'Run Contributor setup. Sign in separately.'
fs_probe ClaudeCLI claude 'Run Contributor setup. Sign in separately.'
if [ -d '/Applications/Android Studio.app' ]; then fs_record AndroidStudio Ready '' ''; else fs_record AndroidStudio Missing 'Android Studio not installed.' 'Mobile setup is PR #4.'; fi
fs_probe Maestro maestro 'Maestro mobile runner is part of PR #4.'
fs_probe Java java 'JDK 21 configuration belongs to PR #4.'
fs_record EmulatorWiring NotApplicable 'Firebase emulator-to-app wiring is not implemented in PR #3.' 'Complete demo-* emulator tests in PR #4.'
fs_record DevCloudIdentity AuthRequired 'Maintainer cloud credentials are not configured.' 'PR #4 DEV-only, least-privilege opt-in; no production credentials.'
if grep -Eq '"firebase"[[:space:]]*:' "$FS_ROOT/.vscode/mcp.json" "$FS_ROOT/.mcp.json"; then
  fs_record FirebaseMCPIsolation Failed 'Firebase cloud MCP found in default settings.' 'Remove default Firebase MCP.'
else fs_record FirebaseMCPIsolation Ready '' ''; fi
for fs_mcp in dart playwright maestro github context7 figma google-developer-knowledge; do
  if grep -Fq "\"$fs_mcp\"" "$FS_ROOT/.vscode/mcp.json"; then
    fs_record "MCP:$fs_mcp" ConfiguredNotConnected 'Configured but no MCP tools/list handshake performed.' 'Connect from VS Code to verify tools/list.'
  else fs_record "MCP:$fs_mcp" Missing 'MCP declaration not found.' 'Restore .vscode/mcp.json.'; fi
done
fs_line "Local diagnostic file: $fs_report"
if [ "$fs_failed" -eq 1 ]; then fs_warn 'Required items are missing or not yet implemented.'; exit 1; fi
fs_ok 'All required local installation checks passed.'
