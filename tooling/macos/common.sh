#!/bin/bash
# macOS Bash 3.2-compatible helpers. No automatic cloud authentication.
FS_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FS_FLUTTER="$HOME/develop/flutter/bin/flutter"
# Keep the Mac CLI pin consistent with tooling/versions.json.
FS_FIREBASE_VERSION=15.34.2
export PATH="$HOME/develop/flutter/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
fs_info(){ printf '[INFO] %s\n' "$*"; }
fs_ok(){ printf '[OK] %s\n' "$*"; }
fs_warn(){ printf '[ACTION] %s\n' "$*" >&2; }
fs_fail(){ printf '[ERROR] %s\n' "$*" >&2; return 1; }
fs_has(){ command -v "$1" >/dev/null 2>&1; }
fs_question(){
  printf '%s [y/N]: ' "$1"
  IFS= read -r fs_answer || return 1
  case "$fs_answer" in y|Y|yes|YES|Yes) return 0;; *) return 1;; esac
}
fs_require_clt(){
  if xcode-select -p >/dev/null 2>&1 && fs_has git; then fs_ok 'Apple Command Line Tools and Git already present.'; return 0; fi
  fs_warn 'Apple Command Line Tools are missing. Complete the Apple install dialog and rerun this launcher.'
  if [ -t 0 ]; then xcode-select --install >/dev/null 2>&1 || true; fi
  return 1
}
fs_require_brew(){
  if fs_has brew; then fs_ok 'Homebrew already available.'; return 0; fi
  fs_warn 'Homebrew is needed to install Mac developer apps. Follow the official instructions at https://brew.sh and rerun.'
  fs_warn 'Apple Silicon also supports the official signed .pkg release. We do not execute remote shell scripts silently.'
  if [ -t 0 ]; then open https://brew.sh >/dev/null 2>&1 || true; fi
  return 1
}
fs_brew_formula(){
  fs_formula="$1"; fs_binary="$2"
  if fs_has "$fs_binary" || brew list --formula --versions "$fs_formula" 2>/dev/null | grep -q .; then fs_ok "$fs_formula already installed."; return 0; fi
  fs_info "Installing Homebrew formula $fs_formula."
  brew install "$fs_formula"
}
fs_brew_cask(){
  fs_cask="$1"; fs_app="$2"; fs_binary="$3"
  if { [ -n "$fs_binary" ] && fs_has "$fs_binary"; } || { [ -n "$fs_app" ] && { [ -d "/Applications/$fs_app" ] || [ -d "$HOME/Applications/$fs_app" ]; }; } || brew list --cask --versions "$fs_cask" 2>/dev/null | grep -q .; then
    fs_ok "$fs_cask already installed."; return 0
  fi
  fs_info "Installing $fs_cask (macOS may request approval)."
  brew install --cask "$fs_cask"
}
fs_code(){
  if fs_has code; then command -v code; return 0; fi
  for fs_path in '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"; do
    if [ -x "$fs_path" ]; then printf '%s\n' "$fs_path"; return 0; fi
  done
  return 1
}
fs_flutter_version_ok(){
  [ -x "$FS_FLUTTER" ] || return 1
  "$FS_FLUTTER" --version --machine 2>/dev/null | grep -Eq '"frameworkVersion"[[:space:]]*:[[:space:]]*"3\.47\.8"'
}
# Free space (whole GB) on the volume holding a path; empty if unknown.
fs_free_gb(){ df -Pk "${1:-$HOME}" 2>/dev/null | awk 'NR==2 {print int($4/1048576)}'; }
FS_FLUTTER_MIN_FREE_GB=6
fs_require_space(){
  local fs_need="$1" fs_what="$2" fs_free
  fs_free="$(fs_free_gb "$HOME")"
  [ -n "$fs_free" ] || return 0
  if [ "$fs_free" -lt "$fs_need" ]; then
    fs_fail "Your Mac is almost out of disk space: ${fs_free} GB free, about ${fs_need} GB needed for ${fs_what}. Free up space (Apple menu > System Settings > General > Storage), then double-click 1 - Set up this computer again. Nothing was downloaded."
    return 1
  fi
}
# A pinned clone whose checkout stopped part-way (for example the disk filled up)
# is missing files but has nothing changed or added: restoring only writes the
# missing tracked files back, so no user change can be overwritten.
fs_flutter_checkout_incomplete(){
  local fs_dir="$HOME/develop/flutter" fs_changes
  [ -d "$fs_dir/.git" ] || return 1
  [ "$(git -C "$fs_dir" describe --tags --exact-match 2>/dev/null || true)" = "3.47.8" ] || return 1
  fs_changes="$(git -C "$fs_dir" status --porcelain --untracked-files=no 2>/dev/null)" || return 1
  [ -n "$fs_changes" ] || return 1
  ! printf '%s\n' "$fs_changes" | grep -Ev '^( D|D |DD) ' >/dev/null
}
fs_ensure_flutter(){
  if fs_flutter_checkout_incomplete; then
    fs_warn 'The Flutter download in ~/develop/flutter stopped part-way (often a full disk). Finishing it now.'
    fs_require_space "$FS_FLUTTER_MIN_FREE_GB" 'the rest of the Flutter SDK' || return 1
    git -C "$HOME/develop/flutter" restore --source=HEAD --staged --worktree :/ || {
      fs_fail "Finishing the Flutter download failed ($(fs_free_gb "$HOME") GB free). Free up space or check the internet, then run step 1 again."; return 1; }
    fs_ok 'Flutter SDK files restored.'
  fi
  if [ -x "$FS_FLUTTER" ]; then
    if fs_flutter_version_ok; then fs_ok 'Flutter 3.47.8 already present.'; return 0; fi
    if [ -d "$HOME/develop/flutter/.git" ] &&
       [ "$(git -C "$HOME/develop/flutter" describe --tags --exact-match 2>/dev/null || true)" = "3.47.8" ]; then
      fs_fail 'Pinned Flutter 3.47.8 checkout found, but Dart initialization is incomplete. Check network access and rerun launchers/mac/1 - Set up this computer.command; no SDK files were deleted.'; return 1
    fi
    fs_fail 'Found a different Flutter SDK in ~/develop/flutter. Choose the pinned 3.47.8 version manually; existing SDKs will not be overwritten.'; return 1
  fi
  if [ -e "$HOME/develop/flutter" ]; then
    fs_fail 'An unfinished or unknown Flutter folder exists at ~/develop/flutter. Setup never deletes an existing SDK. To start over, rename it (in Terminal: mv ~/develop/flutter ~/develop/flutter-old), then run step 1 again.'; return 1
  fi
  fs_require_space "$FS_FLUTTER_MIN_FREE_GB" 'the Flutter SDK' || return 1
  mkdir -p "$HOME/develop"
  # Download into a private staging folder and move it into place only when complete,
  # so an interrupted download never leaves a half-written ~/develop/flutter behind.
  rm -rf "$HOME/develop/.flutter-download-"* 2>/dev/null || true
  local fs_staged="$HOME/develop/.flutter-download-$$"
  fs_info 'Downloading Flutter 3.47.8 into your home folder.'
  if ! git -c advice.detachedHead=false clone --depth 1 --branch 3.47.8 https://github.com/flutter/flutter.git "$fs_staged"; then
    rm -rf "$fs_staged"
    fs_fail "The Flutter download did not finish ($(fs_free_gb "$HOME") GB free now). If the lines above say 'No space left on device', free up space (System Settings > General > Storage); otherwise check the internet connection. Then run step 1 again; the partial download was removed."
    return 1
  fi
  mv "$fs_staged" "$HOME/develop/flutter"
  fs_flutter_version_ok || { fs_fail "Pinned Flutter could not initialize ($(fs_free_gb "$HOME") GB free). Check disk space and the internet, then run step 1 again."; return 1; }
}
# "2, 4" -> "claude antigravity". Any combination of optional assistants, or none.
fs_parse_assistants(){
  local fs_digits fs_out='' fs_name fs_i
  fs_digits="$(printf '%s' "${1:-}" | tr -cd '0-9')"
  fs_i=0
  while [ "$fs_i" -lt "${#fs_digits}" ]; do
    case "${fs_digits:$fs_i:1}" in 1) fs_name=codex;; 2) fs_name=claude;; 3) fs_name=copilot;; 4) fs_name=antigravity;; *) fs_name='';; esac
    if [ -n "$fs_name" ]; then case " $fs_out " in *" $fs_name "*) ;; *) fs_out="${fs_out:+$fs_out }$fs_name";; esac; fi
    fs_i=$((fs_i + 1))
  done
  printf '%s\n' "$fs_out"
}
fs_wants_assistant(){ case " ${FS_AI_CHOICE:-} " in *" $1 "*) return 0;; esac; return 1; }
# Google's official Antigravity CLI installer (puts agy in ~/.local/bin). Downloaded
# over HTTPS to a temporary file first so a cut-off download never runs half a script.
fs_ensure_antigravity(){
  local fs_tmp fs_status=0
  if fs_has agy || [ -x "$HOME/.local/bin/agy" ]; then fs_ok 'Antigravity CLI (agy) already installed.'; return 0; fi
  fs_info "Installing Google's Antigravity CLI (agy) with its official installer."
  fs_tmp="$(mktemp)" || return 1
  if curl -fsSL --proto '=https' https://antigravity.google/cli/install.sh -o "$fs_tmp"; then /bin/bash "$fs_tmp" || fs_status=$?; else fs_status=1; fi
  rm -f "$fs_tmp"
  [ "$fs_status" -eq 0 ] || return "$fs_status"
  export PATH="$HOME/.local/bin:$PATH"
  agy --version >/dev/null 2>&1 || { fs_warn 'agy installed but not on PATH yet; open a new Terminal and run agy --version.'; return 0; }
  fs_ok 'Antigravity CLI ready. It reads AGENTS.md and .agents/skills; sign in later by running agy in this folder.'
}
fs_editor_extensions(){
  fs_ai_choice="${1:-}"
  fs_code_bin="$(fs_code || true)"
  if [ -z "$fs_code_bin" ]; then fs_warn 'VS Code shell command missing. Add Flutter extension from VS Code itself.'; return 0; fi
  for fs_ext in Dart-Code.dart-code Dart-Code.flutter GitHub.vscode-pull-request-github redhat.vscode-yaml EditorConfig.EditorConfig; do
    if "$fs_code_bin" --list-extensions 2>/dev/null | grep -Fxiq "$fs_ext"; then fs_ok "$fs_ext already installed."
    elif "$fs_code_bin" --install-extension "$fs_ext"; then fs_ok "$fs_ext installed."
    else
      case "$fs_ext" in Dart-Code.dart-code|Dart-Code.flutter) fs_fail "Required Flutter extension failed: $fs_ext"; return 1;; *) fs_warn "Optional VS Code extension unavailable: $fs_ext";; esac
    fi
  done
  # Antigravity is a terminal CLI (agy) with no VS Code extension to add here.
  for fs_ai in $fs_ai_choice; do
    case "$fs_ai" in
      codex) fs_ai_ext=OpenAI.chatgpt;;
      claude) fs_ai_ext=Anthropic.claude-code;;
      copilot) fs_ai_ext=GitHub.copilot-chat;;
      *) fs_ai_ext='';;
    esac
    [ -n "$fs_ai_ext" ] || continue
    if "$fs_code_bin" --list-extensions 2>/dev/null | grep -Fxiq "$fs_ai_ext"; then
      fs_ok "$fs_ai_ext already installed."
    elif ! "$fs_code_bin" --install-extension "$fs_ai_ext"; then
      fs_warn "Optional AI extension unavailable: $fs_ai_ext"
    fi
  done
}
fs_npm_firebase(){
  fs_has npm || { fs_fail 'npm is missing. Install Node first.'; return 1; }
  if fs_has firebase && [ "$(firebase --version 2>/dev/null)" = "$FS_FIREBASE_VERSION" ]; then fs_ok 'Pinned Firebase CLI already available. No login performed.'; return 0; fi
  fs_info "Installing Firebase CLI $FS_FIREBASE_VERSION for local demo emulators."
  npm install --global "firebase-tools@$FS_FIREBASE_VERSION"
  fs_has firebase && [ "$(firebase --version 2>/dev/null)" = "$FS_FIREBASE_VERSION" ] || { fs_fail 'Firebase CLI did not install as expected.'; return 1; }
}

# Use a dedicated JDK 21 without modifying the user's global Java settings.
fs_java21_home(){
  local home_dir prefix
  home_dir="$(/usr/libexec/java_home -v 21 2>/dev/null || true)"
  if [ -n "$home_dir" ] && [ -x "$home_dir/bin/java" ]; then
    printf '%s\n' "$home_dir"
    return 0
  fi
  if fs_has brew; then
    prefix="$(brew --prefix openjdk@21 2>/dev/null || true)"
    if [ -n "$prefix" ] && [ -x "$prefix/libexec/openjdk.jdk/Contents/Home/bin/java" ]; then
      printf '%s\n' "$prefix/libexec/openjdk.jdk/Contents/Home"
      return 0
    fi
  fi
  return 1
}
fs_ensure_java21(){
  local home_dir
  home_dir="$(fs_java21_home || true)"
  if [ -n "$home_dir" ]; then fs_ok 'JDK 21 available for local Firebase emulators.'; return 0; fi
  fs_require_brew || return 1
  fs_info 'Installing Homebrew openjdk@21 for local Firebase emulators.'
  brew install openjdk@21 || return 1
  home_dir="$(fs_java21_home || true)"
  [ -n "$home_dir" ] || { fs_fail 'JDK 21 is not detectable after install. Rerun Contributor setup.'; return 1; }
  fs_ok 'JDK 21 ready; no system-wide Java settings were changed.'
}

# Settings below are local to this clone, and never include cloud credentials.
fs_ensure_git_identity(){
  fs_has git || { fs_fail 'Git is missing. Complete Apple Command Line Tools installation.'; return 1; }
  git -C "$FS_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    fs_fail 'This is not a Git clone. Follow MACBOOK-QUICKSTART.md before contributing.'; return 1;
  }
  fs_git_name="$(git -C "$FS_ROOT" config --get user.name 2>/dev/null || true)"
  fs_git_email="$(git -C "$FS_ROOT" config --get user.email 2>/dev/null || true)"
  if [ -n "$fs_git_name" ] && [ -n "$fs_git_email" ]; then fs_ok 'Git commit identity already configured.'; return 0; fi
  fs_info 'Git commits need a name and email. Both appear in public history.'
  fs_info 'For privacy, look up your GitHub noreply email in GitHub Settings > Emails.'
  if [ -z "$fs_git_name" ]; then
    printf 'Display name for commits: '
    IFS= read -r fs_git_name || return 1
    [ -n "$fs_git_name" ] || { fs_fail 'Name was not entered; nothing changed.'; return 1; }
  fi
  if [ -z "$fs_git_email" ]; then
    printf 'Email for commits (GitHub noreply recommended): '
    IFS= read -r fs_git_email || return 1
  fi
  case "$fs_git_email" in *@*.*) ;; *) fs_fail 'Valid Git email was not entered; nothing changed.'; return 1;; esac
  case "$fs_git_name$fs_git_email" in *'
'*) fs_fail 'Invalid Git identity input.'; return 1;; esac
  git -C "$FS_ROOT" config --local user.name "$fs_git_name" || return 1
  git -C "$FS_ROOT" config --local user.email "$fs_git_email" || return 1
  fs_ok 'Git identity saved to this repository only.'
}
fs_offer_flutter_path(){
  fs_line='export PATH="$HOME/develop/flutter/bin:$PATH"'
  fs_profile="$HOME/.zprofile"
  if [ -f "$fs_profile" ] && grep -Fqx "$fs_line" "$fs_profile"; then
    fs_ok 'Flutter is already configured in ~/.zprofile.'; return 0
  fi
  fs_info 'Flutter launchers work already; plain terminal flutter commands need PATH.'
  if [ -t 0 ] && fs_question 'Add the project Flutter SDK path to ~/.zprofile for future Terminal sessions?'; then
    printf '\n%s\n' "$fs_line" >> "$fs_profile"
    fs_ok 'Added one idempotent line to ~/.zprofile. Open a new Terminal window to use flutter.'
  else
    fs_warn 'No shell settings changed. Run ~/develop/flutter/bin/flutter directly, or add its bin directory later.'
  fi
}
fs_ensure_python(){
  if fs_has python3.12 && python3.12 -c 'import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)' >/dev/null 2>&1; then
    fs_ok 'Python 3.12 available for Atlas/review.'
    return 0
  fi
  if fs_has python3 && python3 -c 'import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)' >/dev/null 2>&1; then
    fs_ok 'Python 3.11+ available for Atlas/review.'
    return 0
  fi
  fs_require_brew || return 1
  fs_info 'Installing Python 3.12 for Architecture Atlas and review tools.'
  brew install python@3.12 || return 1
  fs_has python3.12 && python3.12 -c 'import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)' || {
    fs_fail 'Python 3.12 not available after install. Reopen Terminal and rerun Contributor setup.'; return 1;
  }
}
fs_enable_git_hooks(){
  git -C "$FS_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    fs_warn 'No Git clone detected. Hooks can be enabled after cloning.'; return 0;
  }
  fs_existing_hooks="$(git -C "$FS_ROOT" config --local --get core.hooksPath 2>/dev/null || true)"
  if [ -n "$fs_existing_hooks" ] && [ "$fs_existing_hooks" != '.githooks' ]; then
    fs_warn 'Custom local Git hooks already configured; leaving them unchanged. Ask before replacing.'
    return 0
  fi
  git -C "$FS_ROOT" config --local core.hooksPath .githooks
  fs_ok 'Project Git hooks enabled in this clone, same as Windows.'
}

# The wizard remembers the last chosen profile inside this clone's private Git
# directory (never committed, never global) so "Check my setup" grades a
# returning Contributor as a Contributor, not as Preview.
fs_profile_file(){
  fs_git_dir="$(git -C "$FS_ROOT" rev-parse --absolute-git-dir 2>/dev/null)" || return 1
  [ -n "$fs_git_dir" ] || return 1
  printf '%s/forged-sent-profile\n' "$fs_git_dir"
}
fs_remember_profile(){
  fs_pf="$(fs_profile_file)" || return 0
  printf '%s\n' "$1" > "$fs_pf" 2>/dev/null || true
}
fs_installed_profile(){
  fs_pf="$(fs_profile_file || true)"
  if [ -n "$fs_pf" ] && [ -f "$fs_pf" ]; then
    fs_saved="$(head -n 1 "$fs_pf" 2>/dev/null || true)"
    case "$fs_saved" in Preview|Contributor) printf '%s\n' "$fs_saved"; return 0;; esac
  fi
  if fs_has firebase; then printf 'Contributor\n'; else printf 'Preview\n'; fi
}
