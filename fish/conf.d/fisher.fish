if ! type -q fisher
    echo "Missing Fisher!"
    echo "run: curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
end
