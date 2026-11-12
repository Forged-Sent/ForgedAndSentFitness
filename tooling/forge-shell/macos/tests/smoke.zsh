#!/bin/zsh
# Run with zsh -dfi tests/smoke.zsh. An extracted QA zsh can supply FORGE_QA_ZSH_ROOT.
if [[ -n $FORGE_QA_ZSH_ROOT ]]; then
  fpath=($FORGE_QA_ZSH_ROOT/usr/share/zsh/functions/*(/N))
  module_path=($FORGE_QA_ZSH_ROOT/usr/lib/*/zsh/*(/N) $FORGE_QA_ZSH_ROOT/usr/lib/zsh/*(/N) $module_path)
fi
typeset package_dir=${0:A:h:h}
typeset fixture=$(mktemp -d "${TMPDIR:-/tmp}/forge-zsh-qa.XXXXXX")
export HOME=$fixture
export FORGE_STATE_HOME=$fixture/state FORGE_CONFIG_HOME=$fixture/config
mkdir -p "$FORGE_CONFIG_HOME"
print -r -- '{"editing":false,"prompt":"minimal","git_status":false,"directory_history":false}' > "$FORGE_CONFIG_HOME/settings.json"
typeset -g failures=0 passed=0
check() {
  if "$@"; then
    (( passed++ ))
  else
    print -u2 -- "FAIL: $*"
    (( failures++ ))
  fi
}
PROMPT='original> '
setopt promptsubst
source "$package_dir/forge.zsh"
check test "$FORGE_HOME" = "$package_dir"
check test "${options[promptsubst]}" = on
check test "$(_forge_backend _settings | head -1)" = $'theme\tauto'
check test "${#FORGE_OWNED_SHORTCUTS}" -gt 45
source "$package_dir/forge.zsh"
typeset -a matching_hooks=(${(M)precmd_functions:#_forge_precmd})
check test "${#matching_hooks}" = 1
matching_hooks=(${(M)chpwd_functions:#_forge_chpwd})
check test "${#matching_hooks}" = 1
mkcd "$fixture/space and [brackets]"
check test "$PWD" = "$fixture/space and [brackets]"
mark fixture >/dev/null
up
check test "$PWD" = "$fixture"
jump fixture
check test "$PWD" = "$fixture/space and [brackets]"
todo 'Unicode café checkpoint' >/dev/null
check test "$(todos | head -1)" = '#1 [OPEN] Unicode café checkpoint'
tdone 1 >/dev/null
check test -z "$(todos)"
session save 'next tiny action' >/dev/null
check test -n "$(session list)"
focus 1 >/dev/null
check test "$FORGE_FOCUS_UNTIL" -gt "$EPOCHSECONDS"
focus --stop >/dev/null
check test "$FORGE_FOCUS_UNTIL" = 0
forge theme forged >/dev/null
check test "${FORGE_OPTIONS[theme]}" = forged
forge prompt rich >/dev/null
_forge_precmd
check test -n "$PROMPT"
forge prompt off >/dev/null
_forge_precmd
check test "$PROMPT" = 'original> '
check test "${options[promptsubst]}" = on
# Hostile-looking directory text must remain data when PROMPT_SUBST is already enabled.
forge prompt minimal >/dev/null
typeset hostile='$(touch FORGE_SHOULD_NOT_EXIST)'
mkdir -p "$fixture/$hostile"
cd -- "$fixture/$hostile"
_forge_precmd
print -P -- "$PROMPT" >/dev/null
check test ! -e FORGE_SHOULD_NOT_EXIST
check test "$PROMPT" = '${FORGE_RENDERED_PROMPT}'
# A preexisting shortcut remains owned by the user.
unalias ll 2>/dev/null
unfunction ll 2>/dev/null
FORGE_OWNED_SHORTCUTS=(${FORGE_OWNED_SHORTCUTS:#ll})
alias ll='print existing-ll'
source "$package_dir/forge.zsh"
check test "${aliases[ll]}" = 'print existing-ll'
# Enable real completion/ZLE bindings in this isolated shell.
forge config editing true >/dev/null
source "$package_dir/forge.zsh"
check test -n "${functions[compdef]}"
check test "${_comps[forgeshell]}" = _forge_complete
# Query ZLE in this initialized shell, not in command-substitution children.
bindkey '^Xh' > "$fixture/help-key" || exit 1
bindkey '^Xd' > "$fixture/dash-key" || exit 1
check test "$(< "$fixture/help-key")" = '"^Xh" _forge_insert_help'
check test "$(< "$fixture/dash-key")" = '"^Xd" _forge_insert_dash'
print -- "ZSH_SMOKE passed=$passed failed=$failures fixture=$fixture"
(( failures == 0 ))
