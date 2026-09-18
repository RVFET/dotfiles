function fip --description "Geolocate and inspect an IP address"
    set -l allowed_services ipinfo c99

    argparse -n fip -i 's/service=' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: fip [-s|--service ("(string join '|' $allowed_services)")] <ip_address> [xh_options...]"
        return 0
    end

    set -l service ipinfo
    set -q _flag_service; and set service $_flag_service

    if not contains -- $service $allowed_services
        echo "fip: Unknown service '$service'. Allowed: "(string join ', ' $allowed_services) >&2
        return 1
    end

    set -l target
    set -l xh_args

    for arg in $argv
        if test -z "$target"; and not string match -q -- "-*" $arg
            set target $arg
        else
            set -a xh_args $arg
        end
    end

    if test -z "$target"
        echo "Usage: fip [-s|--service ("(string join '|' $allowed_services)")] <ip_address> [xh_options...]" >&2
        return 1
    end

    switch $service
        case ipinfo
            xh https://ipinfo.io/widget/demo/$target "Referer:https://ipinfo.io/" $xh_args
        case c99
            xh -f POST ip.c99.nl action=geoip host=$target $xh_args
    end
end
