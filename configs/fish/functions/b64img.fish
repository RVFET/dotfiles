function b64img
    set -l b64 (wl-paste)
    if string match -qr '^(?:/9j/|iVBORw0KGgo|R0lGOD|UklGR|Qk)' -- $b64
        printf '%s' $b64 | base64 -d | oculante -s
    else
        notify-send -a Oculante -u low -i /usr/share/icons/breeze-dark/actions/16/image-red-eye-symbolic.svg "Buffer is not a base64 image"
    end
end
