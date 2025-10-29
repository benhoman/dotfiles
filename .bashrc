# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# shellcheck source=/dev/null
source ~/.local/share/omarchy/default/bash/rc

# This seems annoying?
# export SSH_AUTH_SOCK=~/.1password/agent.sock

# Source relevant files
for file in ~/.config/{aliases,functions}; do
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
done
unset file

pathmunge "$HOME/.cargo/bin"

eval "$(starship init bash)"

. "$HOME/.local/share/../bin/env"
