function forgot
    set -l cmd (history | sk --regex --case=ignore)
    and commandline -r -- $cmd
end
