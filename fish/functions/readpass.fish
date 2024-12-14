function readpass -d "Prompt for a password. Does not echo entered characters." --argument var
    read --silent localvar
    export $var=$localvar
end
