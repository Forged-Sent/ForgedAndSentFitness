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
    Node|Npm|GitHubCLI|FirebaseCLI|Java21|DemoConfig) [ "$FS_PROFILE" != Preview ]; return;;
    AndroidStudio|Maestro|Java) [ "$FS_PROFILE" = Mobile ] || [ "$FS_PROFILE" = Maintainer ]; return;;
    DevCloudIdentity) [ "$FS_PROFILE" = Maintainer ]; return;;
    *) return 1;;
  esac
}
if [ "$FS_SELFTEST" -eq 1 ]; then
  fs_required Git || exit 1
  FS_PROFILE=Preview; if fs_required Maestro; then exit 1; fi
  FS_PROFILE=Mobile; fs_required Maestro || exit 1
  FS_PROFILE=Contributor; fs_required Java21 || exit 1
  if fs_required EmulatorWiring; then fs_fail 'Live handshake must not be a static readiness requirement.'; exit 1; fi
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
    if [ "$fs_kind" = REQUIRED ] && [ "$fs_state" != NotApplicable ]; then fs_failed=1; fi
  fi
}
fs_probe(){
  if fs_has "$2"; then fs_record "$1" Ready '' ''
  else fs_record "$1" Missing 'Executable not detected.' "$3"; fi
}
fs_line "Forged & Sent MacBook diagnostic | $FS_PROFILE"
fs_line 'Configured MCP servers are NOT Ready until a live initialize + tools/list handshake succeeds.'
fs_line 'No user names, account tokens, project IDs or private file paths are included.'
fs_line 'Installed tools are separate from live emulator and MCP connections; no Firebase cloud account is required.'
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
fs_probe Java java 'Java is optional for Preview; Contributor uses JDK 21.'
if fs_java21_home >/dev/null 2>&1; then
  fs_record Java21 Ready '' ''
else
  fs_record Java21 Missing 'JDK 21 is unavailable for local Firebase emulators.' 'Run SETUP-DEVELOPER-MAC.command; do not use Firebase cloud login.'
fi
if [ -f "$FS_ROOT/.firebaserc" ] && [ -f "$FS_ROOT/firebase.json" ] &&
   grep -Eq '"default"[[:space:]]*:[[:space:]]*"demo-forgedandsent"' "$FS_ROOT/.firebaserc"; then
  fs_record DemoConfig Ready '' ''
else
  fs_record DemoConfig Missing 'Demo Firebase config is missing or not the demo project.' 'Use the complete current PR #4 Git branch.'
fi
fs_all_emulators=1
for fs_port in 9099 8080 9199; do
  if ! fs_has nc || ! nc -G 2 -z 127.0.0.1 "$fs_port" >/dev/null 2>&1; then fs_all_emulators=0; fi
done
if [ "$fs_all_emulators" -eq 1 ]; then
  fs_record EmulatorPorts Ready 'Three local TCP ports respond, but this is not an app handshake.' ''
else
  fs_record EmulatorPorts ConfiguredNotConnected 'One or more local Auth/Firestore/Storage ports are not listening.' 'Run START-EMULATORS-MAC.command in another Terminal window.'
fi
fs_record EmulatorWiring ConfiguredNotConnected 'The Flutter SDK is wired to the demo emulators, but diagnostics cannot verify a live app round-trip.' 'Run RUN-EMULATOR-APP-MAC.command after starting emulators and check its status.'
fs_record DevCloudIdentity AuthRequired 'Cloud DEV access is not included in local setup.' 'Provision a separate least-privilege DEV project later if needed; no PROD credentials.'
if [ ! -f "$FS_ROOT/.vscode/mcp.json" ] || [ ! -f "$FS_ROOT/.mcp.json" ]; then
  fs_record FirebaseMCPIsolation Failed 'One or more required project MCP configurations are missing.' 'Restore the complete trusted project files.'
elif grep -Eq '"firebase"[[:space:]]*:' "$FS_ROOT/.vscode/mcp.json" "$FS_ROOT/.mcp.json"; then
  fs_record FirebaseMCPIsolation Failed 'Firebase cloud MCP found in default settings.' 'Remove default Firebase MCP.'
else fs_record FirebaseMCPIsolation Ready '' ''; fi
for fs_mcp in dart playwright maestro github context7 figma google-developer-knowledge; do
  if grep -Eq "^[[:space:]]{4}\"$fs_mcp\"[[:space:]]*:" "$FS_ROOT/.vscode/mcp.json"; then
    fs_record "MCP:$fs_mcp" ConfiguredNotConnected 'Configured but no MCP tools/list handshake performed.' 'Connect from VS Code to verify tools/list.'
  else fs_record "MCP:$fs_mcp" Missing 'MCP declaration not found.' 'Restore .vscode/mcp.json.'; fi
done
# Build a separate, secret-free prompt for optional troubleshooting with an AI assistant.
fs_ai="$(mktemp -t ForgedAndSent-Mac-AskAI)"
chmod 600 "$fs_ai"
{
  printf '%s\n' "Help me fix Forged & Sent MacBook setup for the $FS_PROFILE profile."
  printf '%s\n' 'Suggest safe steps; never request tokens, passwords, Firebase PROD credentials or bypass security.'
  grep -E '^\[|^  WHY:|^  FIX:' "$fs_report" | grep -v '^\[Ready\]' || true
} > "$fs_ai"
printf 'Local diagnostic file: %s\n' "$fs_report"
printf 'Review-before-sharing AI repair prompt: %s\n' "$fs_ai"
if [ -t 0 ] && fs_has pbcopy && fs_question 'Copy the sanitized AI help prompt to the clipboard?'; then
  pbcopy < "$fs_ai"
  fs_ok 'Copied the diagnostics prompt. Review it before sharing.'
fi
if [ "$fs_failed" -eq 1 ]; then fs_warn 'Required items are missing or not yet implemented.'; exit 1; fi
fs_ok 'All required local installation checks passed.'
