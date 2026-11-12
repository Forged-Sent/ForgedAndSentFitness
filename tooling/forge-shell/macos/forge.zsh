# Forge Mac 1.0.0 — source from an interactive zsh, never from .zshenv.
[[ -o interactive ]] || return 0
[[ ${FORGE_DISABLE:-0} == 1 ]] && return 0
typeset -g FORGE_HOME="${${(%):-%N}:A:h}"
typeset -g FORGE_STATE_HOME="${FORGE_STATE_HOME:-$HOME/.local/state/forge-mac}"
typeset -g FORGE_CONFIG_HOME="${FORGE_CONFIG_HOME:-$HOME/.config/forge-mac}"
export FORGE_STATE_HOME FORGE_CONFIG_HOME
typeset -g FORGE_PYTHON="${FORGE_PYTHON:-}"
if [[ -z $FORGE_PYTHON ]]; then
  for _forge_python_path in /opt/homebrew/bin/python3 /usr/local/bin/python3 "${commands[python3]:-}"; do
    [[ -x $_forge_python_path ]] && FORGE_PYTHON=$_forge_python_path && break
  done
fi
if [[ ! -x $FORGE_PYTHON ]]; then
  print -u2 -- 'Forge: Python 3.10+ is missing. See the package README; your shell is still available.'
  return 0
fi
if [[ -z ${FORGE_INITIALIZED:-} ]]; then
  typeset -g FORGE_ORIGINAL_PROMPT=$PROMPT
  typeset -g FORGE_ORIGINAL_RPROMPT=$RPROMPT
  typeset -g FORGE_ORIGINAL_SUBST=$options[promptsubst]
  typeset -ga FORGE_OWNED_SHORTCUTS=()
  typeset -g FORGE_FOCUS_UNTIL=0 FORGE_LAST_PROBE=0 FORGE_LAST_DIR=$PWD
  typeset -g FORGE_INITIALIZED=1
fi
typeset -gA FORGE_OPTIONS
_forge_backend() {
  "$FORGE_PYTHON" "$FORGE_HOME/lib/forge.py" "$@"
}
_forge_load_settings() {
  emulate -L zsh
  local settings_text key value
  settings_text=$(_forge_backend _settings) || return 1
  while IFS=$'\t' read -r key value; do
    FORGE_OPTIONS[$key]=$value
  done <<< "$settings_text"
}
_forge_load_settings || {
  print -u2 -- 'Forge: settings could not load. Run forgeshell doctor after repairing settings.json.'
  FORGE_OPTIONS=(theme auto prompt off editing false shortcuts true git_status false directory_history false git_cache_seconds 5)
}
forgeshell() {
  emulate -L zsh
  local action=${1:-helpme} dest selected minutes
  (( $# )) && shift
  case $action in
    jump|z|qa|mkcd|tempwork)
      dest=$(_forge_backend _resolve "$action" "$@") || return $?
      builtin cd -- "$dest"
      ;;
    projects)
      if [[ $1 == --list ]]; then _forge_backend projects
      else
        dest=$(_forge_backend _resolve projects "$@") || return $?
        builtin cd -- "$dest"
      fi
      ;;
    back) builtin cd -- "${OLDPWD:-$PWD}" ;;
    up)
      local count=${1:-1}
      [[ $count == <1-20> ]] || { print -u2 -- 'up [1–20]'; return 1; }
      dest=$PWD
      repeat $count; do dest=${dest:h}; done
      builtin cd -- "$dest"
      ;;
    session)
      if [[ $1 == resume ]]; then
        dest=$(_forge_backend _resolve session "$@") || return $?
        builtin cd -- "$dest"
      else _forge_backend session "$@"; fi
      ;;
    fs)
      if [[ $1 == go || $1 == mobile ]]; then
        dest=$(_forge_backend _resolve fs "$@") || return $?
        builtin cd -- "$dest"
      else _forge_backend fs "$@"; fi
      ;;
    dash)
      selected=$(_forge_backend _menu) || return $?
      forgeshell ${(z)selected}
      ;;
    focus)
      if [[ $1 == --stop ]]; then
        FORGE_FOCUS_UNTIL=0
        print -- 'Focus timer cleared.'
      else
        minutes=${1:-25}
        [[ $minutes == <1-180> ]] || { print -u2 -- 'focus [1–180] / focus --stop'; return 1; }
        FORGE_FOCUS_UNTIL=$(( EPOCHSECONDS + minutes * 60 ))
        print -- "Focus for $minutes minutes. The prompt updates when you return to it."
      fi
      ;;
    config|theme|prompt|project)
      _forge_backend "$action" "$@" || return $?
      _forge_load_settings
      ;;
    reload|reloadforge)
      source "$FORGE_HOME/forge.zsh"
      print -- 'Forge reloaded. Open a fresh tab to fully remove disabled keybindings/shortcuts.'
      ;;
    recent-command)
      local query="$*" line
      for line in "${(@f)$(fc -ln -100 2>/dev/null)}"; do
        [[ ${(L)line} == *password* || ${(L)line} == *token* || ${(L)line} == *secret* || ${(L)line} == *api_key* ]] && continue
        [[ $line == *'todo '* || $line == *'note '* || $line == *'session save '* ]] && continue
        [[ -z $query || ${(L)line} == *${(L)query}* ]] && print -r -- "$line"
      done
      ;;
    venv)
      dest=${1:-.venv}
      [[ -e $dest && ! -f $dest/pyvenv.cfg ]] && { print -u2 -- 'Existing path is not a Python virtual environment.'; return 1; }
      [[ -d $dest ]] || "$FORGE_PYTHON" -m venv "$dest" || return $?
      source "$dest/bin/activate"
      ;;
    help) _forge_backend helpme "$@" ;;
    *) _forge_backend "$action" "$@" ;;
  esac
}
_forge_safe_label() {
  emulate -L zsh
  REPLY=${1//[[:cntrl:]]/ }
  REPLY=${REPLY//\%/%%}
}
_forge_precmd() {
  local command_code=$?
  local use_subst=$options[promptsubst]
  emulate -L zsh
  if [[ ${FORGE_OPTIONS[prompt]} == off ]]; then
    PROMPT=$FORGE_ORIGINAL_PROMPT
    RPROMPT=$FORGE_ORIGINAL_RPROMPT
    return
  fi
  local accent='#79B8C8' label='' br='' detail='' cache_dir='' focus_text='' folder REPLY
  local cache="$FORGE_STATE_HOME/cache/prompt-$$"
  if [[ ${FORGE_OPTIONS[prompt]} == rich && ${FORGE_OPTIONS[git_status]} == true ]]; then
    if [[ -r $cache ]]; then
      { IFS= read -r cache_dir; IFS= read -r label; IFS= read -r br; IFS= read -r detail; } < "$cache"
      [[ $cache_dir == $PWD ]] || { label=''; br=''; detail='checking'; }
    else detail='checking'; fi
    if (( EPOCHSECONDS - FORGE_LAST_PROBE >= ${FORGE_OPTIONS[git_cache_seconds]:-5} )) || [[ $FORGE_LAST_DIR != $PWD ]]; then
      FORGE_LAST_PROBE=$EPOCHSECONDS
      FORGE_LAST_DIR=$PWD
      (_forge_backend _prompt "$PWD" "$cache" >/dev/null 2>&1) &!
    fi
  fi
  [[ ${FORGE_OPTIONS[theme]} == forged || ( ${FORGE_OPTIONS[theme]} == auto && $label == 'FORGED & SENT' ) ]] && accent='#F17B32'
  _forge_safe_label "${PWD/#$HOME/~}"; folder=$REPLY
  _forge_safe_label "$label"; label=$REPLY
  _forge_safe_label "$br"; br=$REPLY
  _forge_safe_label "$detail"; detail=$REPLY
  if (( FORGE_FOCUS_UNTIL > 0 )); then
    if (( EPOCHSECONDS < FORGE_FOCUS_UNTIL )); then
      focus_text=" | focus $(( (FORGE_FOCUS_UNTIL - EPOCHSECONDS + 59) / 60 ))m"
    else focus_text=' | focus complete'; fi
  fi
  local context="%F{$accent}${label:+$label | }$folder%f"
  [[ -n $br ]] && context+=" %F{#929CA5}| $br%f"
  [[ -n $detail ]] && context+=" %F{#929CA5}$detail%f"
  [[ -n $VIRTUAL_ENV ]] && context+=' %F{#E0C46C}[venv]%f'
  (( EUID == 0 )) && context+=' %F{#F08076}[ADMIN]%f'
  (( command_code != 0 )) && context+=" %F{#F08076}[exit $command_code]%f"
  context+="%F{#E0C46C}$focus_text%f"
  PROMPT="$context"$'\n''%F{#F2F0EB}>%f '
  [[ ${FORGE_OPTIONS[prompt]} == minimal ]] && PROMPT="$context > "
  typeset -g FORGE_RENDERED_PROMPT=$PROMPT
  [[ $use_subst == on ]] && PROMPT='${FORGE_RENDERED_PROMPT}'
  RPROMPT=''
}
_forge_chpwd() {
  [[ ${FORGE_OPTIONS[directory_history]} == true ]] || return 0
  (_forge_backend _visit "$PWD" >/dev/null 2>&1) &!
}
_forge_history() {
  local lower=${(L)1}
  [[ $1 == ' '* || $lower == *password* || $lower == *api_key* || $lower == *token=* || $lower == *secret=* ||
     $lower == todo\ * || $lower == note\ * || $lower == session\ save\ * ||
     $lower == forge\ todo\ * || $lower == forge\ note\ * || $lower == forge\ session\ save\ * ||
     $lower == forgeshell\ todo\ * || $lower == forgeshell\ note\ * || $lower == forgeshell\ session\ save\ * ]] && return 2
  return 0
}
zmodload zsh/datetime
autoload -Uz add-zsh-hook
add-zsh-hook -d precmd _forge_precmd
add-zsh-hook -d chpwd _forge_chpwd
add-zsh-hook -d zshaddhistory _forge_history
add-zsh-hook precmd _forge_precmd
add-zsh-hook chpwd _forge_chpwd
add-zsh-hook zshaddhistory _forge_history
if [[ ${FORGE_OPTIONS[editing]} == true ]]; then
  HISTFILE=${HISTFILE:-$HOME/.zsh_history}
  (( HISTSIZE < 5000 )) && HISTSIZE=5000
  (( SAVEHIST < 5000 )) && SAVEHIST=5000
  setopt hist_ignore_space hist_save_no_dups
  if (( ! $+functions[compdef] )); then
    autoload -Uz compinit
    compinit
  fi
  _forge_complete() {
    local -a candidates
    if [[ $words[1] == fs || ( $words[1] == (forge|forgeshell) && $words[2] == fs ) ]]; then
      candidates=(go mobile status doctor run ios test analyze format firebase preview docs architecture open diff branch pr ci help menu)
    elif [[ $words[1] == (forge|forgeshell) ]]; then
      candidates=(helpme dash config theme prompt project context doctor test reload docs jump projects todo todos note notes session focus fs)
    else
      _files -/
      return
    fi
    compadd -- $candidates
  }
  _forge_insert_help() { LBUFFER='helpme '; }
  _forge_insert_dash() { LBUFFER='dash'; }
  zle -N _forge_insert_help
  zle -N _forge_insert_dash
  bindkey '^Xh' _forge_insert_help
  bindkey '^Xd' _forge_insert_dash
  bindkey '^R' history-incremental-search-backward
  bindkey '^[[A' history-beginning-search-backward
  bindkey '^[[B' history-beginning-search-forward
  bindkey '^I' expand-or-complete
  zstyle ':completion:*' menu select
fi
if [[ ${FORGE_OPTIONS[shortcuts]} == true ]]; then
  for _forge_name in forge dash helpme keys ph ptest reloadforge jump z qa mark marks unmark projects back up mkcd ll ff ftext hashfile comparefile tempwork trash bigfiles dirsize zipto unzipto todo todos tdone note notes recent-notes session focus recent-command port netcheck pathcheck envshow sshgo sysinfo serialports usbinfo procfind jview cliptools b64 unb64 urlencode urldecode uuidgenx serve venv gst gad gmsg gpsh fs; do
    if (( ${FORGE_OWNED_SHORTCUTS[(Ie)$_forge_name]} )) || {
      (( ! $+functions[$_forge_name] && ! $+aliases[$_forge_name] && ! $+commands[$_forge_name] && ! $+builtins[$_forge_name] ))
    }; then
      if [[ $_forge_name == forge ]]; then functions[$_forge_name]='forgeshell "$@"'
      else functions[$_forge_name]="forgeshell $_forge_name \"\$@\""; fi
      (( ${FORGE_OWNED_SHORTCUTS[(Ie)$_forge_name]} )) || FORGE_OWNED_SHORTCUTS+=($_forge_name)
    fi
  done
fi
(( $+functions[compdef] )) && compdef _forge_complete forgeshell ${FORGE_OWNED_SHORTCUTS:#forge}
(( $+functions[compdef] && ${FORGE_OWNED_SHORTCUTS[(Ie)forge]} )) && compdef _forge_complete forge
if [[ ${FORGE_OPTIONS[editing]} == true && ${FORGE_OPTIONS[plugins]} == true ]]; then
  for _forge_brew_root in "${HOMEBREW_PREFIX:-/opt/homebrew}" /usr/local; do
    if (( ! $+functions[_zsh_autosuggest_start] )) && [[ -r $_forge_brew_root/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
      source "$_forge_brew_root/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi
    if (( ! $+functions[_zsh_highlight] )) && [[ -r $_forge_brew_root/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
      source "$_forge_brew_root/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
  done
fi
unset _forge_name _forge_python_path _forge_brew_root
return 0
