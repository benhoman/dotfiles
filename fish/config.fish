if status is-interactive
    set -gx EDITOR nvim

    fish_vi_key_bindings

    # Path
    set -x fish_user_paths
    fish_add_path ~/.local/bin

    # Disable the fish greeting message
    set fish_greeting ""

    # Plugin Config
    # Tide Prompt
    # tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=Yes
    set --global tide_character_icon '🍆'
    set --global tide_cmd_duration_decimals 2
    set --global tide_cmd_duration_threshold 0

    # fzf.fish
    set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
end
