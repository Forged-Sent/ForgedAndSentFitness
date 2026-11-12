#!/bin/zsh
set -eu
package_dir=${0:A:h}
export FORGE_ZDOTDIR=${ZDOTDIR:-$HOME}
python_path=${FORGE_PYTHON:-}
for candidate in /opt/homebrew/bin/python3 /usr/local/bin/python3 "${commands[python3]:-}"; do
  [[ -n $python_path ]] && break
  [[ -x $candidate ]] && python_path=$candidate
done
if [[ -z $python_path ]]; then
  print -u2 -- 'Python 3.10+ is required. With Homebrew installed: brew install python'
  exit 1
fi
"$python_path" "$package_dir/install.py" "$@"
