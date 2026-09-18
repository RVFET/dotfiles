function st --description "Case-insensitive global ripgrep search without line headings"
    if test (count $argv) -eq 0
        echo "Usage: st <regex> [paths/extra_flags...]" >&2
        return 1
    end

    set -l regex $argv[1]
    set -l rest $argv[2..]
    rg -ai "$regex" $rest --no-heading --no-line-number
end
