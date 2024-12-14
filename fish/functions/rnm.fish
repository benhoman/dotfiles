function rnm -d "Rename file"
    # get directory of file from argument
    set -l file $argv[1]
    set -l dir (dirname $file)
    set -l new_file $argv[2]
    command mv $file $dir/$new_file
end
