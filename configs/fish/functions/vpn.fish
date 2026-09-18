function vpn --description "Interactive WireGuard connection manager"
    if not contains "$argv[1]" "up" "down"
        echo "Usage: vpn <up|down>" >&2
        return 1
    end

    set -l action $argv[1]
    set -l configs (sudo ls /etc/wireguard/*.conf 2>/dev/null)

    if test (count $configs) -eq 0
        echo "No WireGuard configurations found in /etc/wireguard/" >&2
        return 1
    end

    set -l names
    for c in $configs
        set -a names (string match -r '[^/]+(?=\.conf$)' $c)
    end

    set -l selected
    if type -q fzf
        set selected (printf "%s\n" $names | fzf --prompt="WireGuard $action > ")
    else
        echo "Available configurations:"
        for i in (seq (count $names))
            echo "[$i] $names[$i]"
        end
        read -P "Select configuration number: " choice
        if string match -qr '^[0-9]+$' -- $choice; and test $choice -ge 1 -a $choice -le (count $names)
            set selected $names[$choice]
        end
    end

    if test -n "$selected"
        sudo wg-quick $action $selected
    else
        echo "Invalid selection or aborted." >&2
        return 1
    end
end
