function launch-hyprland --description "Start Hyprland keeping only the 3 latest logs"
    set -l log_dir $HOME/.cache/hyprland-logs
    mkdir -p $log_dir

    if test -d $log_dir
        set -l old_logs (command ls -1t $log_dir 2>/dev/null | string match -r '^[0-9a-zA-Z_\.\-]+\.log$')

        if test (count $old_logs) -ge 3
            for file in $old_logs[3..-1]
                if test -n "$file" -a -f "$log_dir/./$file"
                    rm -f "$log_dir/./$file"
                end
            end
        end
    end

    set -l timestamp (date +%d-%m-%Y_%H-%M-%S)
    start-hyprland &> $log_dir/$timestamp.log
end
