function serve --description 'Start a local server for the current directory, open in browser'
    set -l port 8080
    if test (count $argv) -eq 1
        set port $argv[1]
    end
    python -m SimpleHTTPServer $port &
    xdg-open http://localhost:$port
    fg
end
