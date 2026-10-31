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
      fs_fail 'Pinned Flutter 3.47.8 checkout found, but Dart initialization is incomplete. Check network access and rerun SETUP-MAC.command; no SDK files were deleted.'; return 1
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
  fs_code_bin="$(fs_code || true)"
  if [ -z "$fs_code_bin" ]; then fs_warn 'VS Code shell command missing. Add Flutter extension from VS Code itself.'; return 0; fi
  for fs_ext in Dart-Code.dart-code Dart-Code.flutter GitHub.copilot-chat GitHub.vscode-pull-request-github OpenAI.chatgpt Anthropic.claude-code redhat.vscode-yaml EditorConfig.EditorConfig; do
    if "$fs_code_bin" --list-extensions 2>/dev/null | grep -Fxiq "$fs_ext"; then fs_ok "$fs_ext already installed."
    elif "$fs_code_bin" --install-extension "$fs_ext"; then fs_ok "$fs_ext installed."
    else
      case "$fs_ext" in Dart-Code.dart-code|Dart-Code.flutter) fs_fail "Required Flutter extension failed: $fs_ext"; return 1;; *) fs_warn "Optional VS Code extension unavailable: $fs_ext";; esac
    fi
  done
}
fs_npm_firebase(){
  fs_has npm || { fs_fail 'npm is missing. Install Node first.'; return 1; }
  if fs_has firebase && [ "$(firebase --version 2>/dev/null)" = "$FS_FIREBASE_VERSION" ]; then fs_ok 'Pinned Firebase CLI already available. No login performed.'; return 0; fi
  fs_info "Installing Firebase CLI $FS_FIREBASE_VERSION for future local emulators."
  npm install --global "firebase-tools@$FS_FIREBASE_VERSION"
  fs_has firebase && [ "$(firebase --version 2>/dev/null)" = "$FS_FIREBASE_VERSION" ] || { fs_fail 'Firebase CLI did not install as expected.'; return 1; }
}
