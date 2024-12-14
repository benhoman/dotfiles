function cat --wraps=bat -d "Use bat instead of cat"
    if type -q bat
        command bat $argv
    else if type -q batcat
        command batcat $argv
    else
        command cat $argv
    end
end
