# shellcheck source=/dev/null
source ~/.local/share/omarchy/default/bash/rc

export SSH_AUTH_SOCK=~/.1password/agent.sock

# Source relevant files
for file in ~/.config/{aliases,functions}; do
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
done
unset file

eval "$(starship init bash)"
