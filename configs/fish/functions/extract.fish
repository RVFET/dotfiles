function extract --description "Extract any archive automatically"
    if test (count $argv) -eq 0
        echo "Usage: extract <archive_files...>" >&2
        return 1
    end

    # Find 7z binary if available
    set -l _7z_bin ""
    for bin in 7z 7zz 7za
        if command -q $bin
            set _7z_bin $bin
            break
        end
    end

    for file in $argv
        if not test -f "$file"
            echo "Error: '$file' is not a valid file." >&2
            continue
        end

        echo "Extracting: $file"
        switch (string lower -- "$file")
            case '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tbz' '*.tar.xz' '*.txz' '*.tar.zst' '*.tzst' '*.tar.lz4' '*.tar'
                tar -xf "$file"
            case '*.gz'
                gunzip -k "$file"
            case '*.bz2'
                bunzip2 -k "$file"
            case '*.xz'
                unxz -k "$file"
            case '*.zst'
                unzstd -k "$file"
            case '*.zip'
                if test -n "$_7z_bin"
                    $_7z_bin x "$file"
                else if command -q unzip
                    unzip -q "$file"
                else
                    echo "Error: Neither 7z nor unzip is installed." >&2
                end
            case '*.rar' '*.7z' '*.iso' '*.cab' '*.deb' '*.rpm'
                if test -n "$_7z_bin"
                    $_7z_bin x "$file"
                else if test (string match -r '\.rar$' "$file") -a (command -q unrar)
                    unrar x "$file"
                else
                    echo "Error: 7z (or unrar) is required to extract '$file'." >&2
                end
            case '*'
                echo "Error: '$file' cannot be extracted via extract (unrecognized format)." >&2
        end
    end
end
