# shellcheck source=/dev/null
source ~/.local/share/omarchy/default/bash/rc

# Source relevant files
for file in ~/.config/{aliases,functions}; do
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
done
unset file

eval "$(starship init bash)"
