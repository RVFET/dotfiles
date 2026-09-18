function rep --description "Repeat command execution with concurrency and interval control"
    argparse 'n/count=' 'i/interval=' 'p/parallel=' -- $argv
    or return 1

    set -l n 1
    set -l i 0
    set -l p 1

    set -q _flag_n; and set n $_flag_n
    set -q _flag_i; and set i $_flag_i
    set -q _flag_p; and set p $_flag_p

    if test (count $argv) -eq 0
        echo "Usage: rep [-n count] [-i interval] [-p parallel] -- <command>" >&2
        return 1
    end

    for c in (seq 1 $n)
        eval $argv &
        if test (math "$c % $p") -eq 0
            wait
            test $i -gt 0; and sleep $i
        end
    end
    wait
end
