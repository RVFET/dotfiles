function qr --description "Generate terminal QR code"
    if test (count $argv) -eq 0
        echo "Usage: qr <text_or_url>" >&2
        return 1
    end
    curl -s https://qrenco.de/$argv[1]
end
