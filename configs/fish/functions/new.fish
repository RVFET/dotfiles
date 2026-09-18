function new --description "Create temporary script in ~/Brainstorming and run optional runner"
    if test (count $argv) -eq 0
        echo "Usage: new <filename> [runner...]" >&2
        return 1
    end

    set -l dir "$HOME/Brainstorming"
    mkdir -p $dir
    set -l file_path "$dir/$argv[1]"
    set -l runner $argv[2..]

    micro $file_path

    if test (count $runner) -gt 0
        $runner $file_path
    else
        echo "Script saved at $file_path. No runner specified."
    end
end
