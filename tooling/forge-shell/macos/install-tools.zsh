#!/bin/zsh
# Preview by default. Homebrew itself is never installed by this script.
set -eu
apply=false
terminal=iterm2
for arg in "$@"; do
  case $arg in
    --apply) apply=true ;;
    iterm2|ghostty|none) terminal=$arg ;;
    *) print -u2 -- 'Usage: zsh install-tools.zsh [--apply] [iterm2|ghostty|none]'; exit 1 ;;
  esac
done
brew_path=${commands[brew]:-}
for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -n $brew_path ]] && break
  [[ -x $candidate ]] && brew_path=$candidate
done
print -- 'Install tools: python, ripgrep, fzf, zsh-autosuggestions, zsh-syntax-highlighting'
print -- "Terminal: $terminal"
if [[ $apply != true ]]; then
  print -- 'Preview only. Add --apply to run Homebrew; choose ghostty or none if preferred.'
  exit 0
fi
[[ $OSTYPE == darwin* ]] || { print -u2 -- 'Run this installer on macOS.'; exit 1; }
[[ -n $brew_path ]] || { print -u2 -- 'Install Homebrew from https://brew.sh, then rerun.'; exit 1; }
"$brew_path" install python ripgrep fzf zsh-autosuggestions zsh-syntax-highlighting
[[ $terminal == none ]] || "$brew_path" install --cask "$terminal"
