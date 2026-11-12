#!/bin/bash
# Sourceable optional-shell step; macOS /bin/bash 3.2 compatible.

fs_select_engineering_shell() {
  FS_SHELL_INSTALL=0
  FS_SHELL_TERMINAL=none
  FS_SHELL_TOOLS=0
  # EOF, pipes, CI and --ci never count as consent.
  if [ -n "${CI:-}" ] || [ "${FS_CI:-0}" = 1 ] || [ ! -t 0 ]; then return 0; fi
  printf '\nOptional Forge Shell: menus, bookmarks, tasks, notes and focus timer for any project.\n'
  printf 'Adds a backed-up zsh loader in your home folder. Installs Python if needed.\n'
  if ! fs_question 'Would you like the ADHD-friendly engineering shell?'; then return 0; fi
  FS_SHELL_INSTALL=1
  printf 'Optional colors: 1 = iTerm2 profiles, 2 = Ghostty, Return = keep current colors.\nColors [none]: '
  IFS= read -r fs_shell_reply || fs_shell_reply=''
  case "$fs_shell_reply" in 1) FS_SHELL_TERMINAL=iterm2;; 2) FS_SHELL_TERMINAL=ghostty;; esac
  printf 'Extra tools: ripgrep, fzf, zsh suggestions/highlighting, plus the selected terminal app.\n'
  if fs_question 'Also install these optional tools with Homebrew?'; then FS_SHELL_TOOLS=1; fi
}

fs_install_engineering_shell() {
  [ "${FS_SHELL_INSTALL:-0}" = 1 ] || return 0
  [ "$(uname -s)" = Darwin ] || { fs_fail 'Run the shell installer on macOS.'; return 1; }
  local fs_shell_python='' fs_shell_candidate fs_shell_package
  fs_shell_package="$FS_ROOT/tooling/forge-shell/macos"
  for fs_shell_candidate in "${FORGE_PYTHON:-}" /opt/homebrew/bin/python3 /usr/local/bin/python3 python3.12 python3; do
    [ -n "$fs_shell_candidate" ] || continue
    if "$fs_shell_candidate" -c 'import sys;sys.exit(0 if sys.version_info >= (3,10) else 1)' >/dev/null 2>&1; then
      fs_shell_python="$fs_shell_candidate"; break
    fi
  done
  if [ -z "$fs_shell_python" ]; then
    fs_ensure_python || return 1
    if command -v python3.12 >/dev/null 2>&1; then fs_shell_python=python3.12; else fs_shell_python=python3; fi
  fi
  # Core installation needs no terminal app and leaves the login shell unchanged.
  "$fs_shell_python" "$fs_shell_package/install.py" --apply \
    --terminal "${FS_SHELL_TERMINAL:-none}" --project-root "$FS_ROOT" || return 1
  if [ "${FS_SHELL_TOOLS:-0}" = 1 ]; then
    /bin/zsh "$fs_shell_package/install-tools.zsh" --apply "${FS_SHELL_TERMINAL:-none}" ||
      fs_warn 'Shell installed; optional Homebrew tools need attention. See docs/development/SHELL-SETUP.md.'
  fi
  fs_ok 'Open a new zsh tab and type dash. Guide: docs/development/SHELL-SETUP.md'
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -euo pipefail
  . "$(dirname "$0")/common.sh"
  case "${1:---offer}" in
    --self-test)
      [ -f "$FS_ROOT/tooling/forge-shell/macos/install.py" ]
      [ -f "$FS_ROOT/tooling/forge-shell/macos/forge.zsh" ]
      fs_ok 'Optional Mac shell self-test passed (no changes made).'
      ;;
    --offer)
      fs_select_engineering_shell
      if [ "$FS_SHELL_INSTALL" = 1 ]; then fs_install_engineering_shell
      else fs_info 'Optional shell skipped. Add it later from More options > 6.'; fi
      ;;
    --apply)
      # Explicit unattended opt-in installs core only; extras use the package tools.
      FS_SHELL_INSTALL=1 FS_SHELL_TERMINAL=none FS_SHELL_TOOLS=0
      fs_install_engineering_shell
      ;;
    *) fs_fail 'Usage: bash tooling/macos/forge-shell.sh [--offer|--apply|--self-test]'; exit 2;;
  esac
fi
