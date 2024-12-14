function ta
    set -l session
    set session (
    tmux list-sessions -F "#{session_name}" | \
      fzf --exit-0 \
        --reverse
    )
    tmux attach -t "$session"
end
