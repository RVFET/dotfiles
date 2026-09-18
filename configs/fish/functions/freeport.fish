function freeport --description "Kill process listening on a specified port"
    if test (count $argv) -eq 0
        echo "Usage: freeport <port_number>" >&2
        return 1
    end

    set -l port $argv[1]
    set -l pids (sudo lsof -t -i :$port 2>/dev/null)

    if test (count $pids) -eq 0
        echo "No active processes found listening on port $port"
        return 0
    end

    for pid in $pids
        set -l exe_path (readlink /proc/$pid/exe 2>/dev/null)
        set -l proc_name (path basename "$exe_path"; or echo "unknown")
        echo "Killing "(set_color yellow)"$proc_name"(set_color normal)" (PID "(set_color yellow)"$pid"(set_color normal)")"
        sudo kill -9 $pid
    end
end
