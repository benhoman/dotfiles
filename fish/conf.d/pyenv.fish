# Pyenv setup
# Requires `brew install pyenv`
if type -q pyenv
    if status is-interactive
        pyenv init - | source
        pyenv virtualenv-init - | source
    end
end
