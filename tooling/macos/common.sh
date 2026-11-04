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
fs_ensure_flutter(){
  if [ -x "$FS_FLUTTER" ]; then
    if fs_flutter_version_ok; then fs_ok 'Flutter 3.47.8 already present.'; return 0; fi
    if [ -d "$HOME/develop/flutter/.git" ] &&
       [ "$(git -C "$HOME/develop/flutter" describe --tags --exact-match 2>/dev/null || true)" = "3.47.8" ]; then
      fs_fail 'Pinned Flutter 3.47.8 checkout found, but Dart initialization is incomplete. Check network access and rerun launchers/mac/1 - Set up this computer.command; no SDK files were deleted.'; return 1
    fi
    fs_fail 'Found a different Flutter SDK in ~/develop/flutter. Choose the pinned 3.47.8 version manually; existing SDKs will not be overwritten.'; return 1
  fi
  if [ -e "$HOME/develop/flutter" ]; then
    fs_fail 'An incomplete Flutter clone exists. Inspect or move that folder aside before rerunning. Setup never deletes an existing SDK.'; return 1
  fi
  mkdir -p "$HOME/develop"
  fs_info 'Downloading Flutter 3.47.8 into your home folder.'
  git clone --depth 1 --branch 3.47.8 https://github.com/flutter/flutter.git "$HOME/develop/flutter"
  fs_flutter_version_ok || { fs_fail 'Pinned Flutter could not initialize.'; return 1; }
}
fs_editor_extensions(){
  fs_ai_choice="${1:-none}"
  fs_code_bin="$(fs_code || true)"
  if [ -z "$fs_code_bin" ]; then fs_warn 'VS Code shell command missing. Add Flutter extension from VS Code itself.'; return 0; fi
  for fs_ext in Dart-Code.dart-code Dart-Code.flutter GitHub.vscode-pull-request-github redhat.vscode-yaml EditorConfig.EditorConfig; do
    if "$fs_code_bin" --list-extensions 2>/dev/null | grep -Fxiq "$fs_ext"; then fs_ok "$fs_ext already installed."
    elif "$fs_code_bin" --install-extension "$fs_ext"; then fs_ok "$fs_ext installed."
    else
      case "$fs_ext" in Dart-Code.dart-code|Dart-Code.flutter) fs_fail "Required Flutter extension failed: $fs_ext"; return 1;; *) fs_warn "Optional VS Code extension unavailable: $fs_ext";; esac
    fi
  done
  case "$fs_ai_choice" in
    codex) fs_ai_ext=OpenAI.chatgpt;;
    claude) fs_ai_ext=Anthropic.claude-code;;
    copilot) fs_ai_ext=GitHub.copilot-chat;;
    none) fs_ai_ext='';;
    *) fs_warn 'Unknown AI choice; no AI extension installed.'; fs_ai_ext='';;
  esac
  if [ -n "$fs_ai_ext" ]; then
    if "$fs_code_bin" --list-extensions 2>/dev/null | grep -Fxiq "$fs_ai_ext"; then
      fs_ok "$fs_ai_ext already installed."
    elif ! "$fs_code_bin" --install-extension "$fs_ai_ext"; then
      fs_warn "Optional AI extension unavailable: $fs_ai_ext"
    fi
  fi
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
