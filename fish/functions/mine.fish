function mine -d "Chown file or directory to current user"
    set -l group (id -g -n)
    command sudo chown $USER:$group $argv
end
