function cl -d 'copy output of last command to clipboard'
    set -l last (history --max=1|sed -e 's/^ +//')
    eval $last | string collect | fish_clipboard_copy
end
