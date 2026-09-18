function archive --description "Create optimized archives with compression level support"
    # Parse CLI flags
    argparse 'l/level=' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: archive [-l|--level fast|normal|maximum] <output_file> <target_files_or_directories...>"
        echo ""
        echo "Options:"
        echo "  -l, --level LEVEL    Compression level: 'fast', 'normal' (default), 'maximum'"
        echo "  -h, --help           Show this help message"
        echo ""
        echo "Supported formats:"
        echo "  .tar.gz, .tgz, .tar.xz, .txz, .tar.zst, .tzst, .tar.bz2, .tbz2, .tar, .zip, .7z"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Error: Missing arguments." >&2
        echo "Usage: archive [-l|--level fast|normal|maximum] <output_file> <targets...>" >&2
        return 1
    end

    # Normalize compression level
    set -l level "normal"
    if set -q _flag_level
        switch (string lower -- "$_flag_level")
            case fast 1 quick min
                set level "fast"
            case normal 5 6 default
                set level "normal"
            case max maximum 9 best
                set level "maximum"
            case '*'
                echo "Error: Invalid compression level '$_flag_level'. Use 'fast', 'normal', or 'maximum'." >&2
                return 1
        end
    end

    set -l output $argv[1]
    set -l targets $argv[2..-1]

    # Validate target paths exist
    for target in $targets
        if not test -e "$target"
            echo "Error: Target '$target' does not exist." >&2
            return 1
        end
    end

    # Locate available 7z binary (7z, 7zz, or 7za)
    set -l _7z_bin ""
    for bin in 7z 7zz 7za
        if command -q $bin
            set _7z_bin $bin
            break
        end
    end

    # Create archive based on extension and level
    switch $output
        case '*.tar.gz' '*.tgz'
            set -l gz_lvl 6
            test "$level" = "fast"; and set gz_lvl 1
            test "$level" = "maximum"; and set gz_lvl 9

            if command -q pigz
                tar --use-compress-program="pigz -$gz_lvl" -cf "$output" $targets
            else
                tar --use-compress-program="gzip -$gz_lvl" -cf "$output" $targets
            end

        case '*.tar.xz' '*.txz'
            set -l xz_opt "-6"
            test "$level" = "fast"; and set xz_opt "-1"
            test "$level" = "maximum"; and set xz_opt "-9e"

            if command -q pixz
                tar --use-compress-program="pixz" -cf "$output" $targets
            else if command -q xz
                tar --use-compress-program="xz $xz_opt -T0" -cf "$output" $targets
            else
                tar -cJf "$output" $targets
            end

        case '*.tar.zst' '*.tzst'
            set -l zstd_lvl 3
            test "$level" = "fast"; and set zstd_lvl 1
            test "$level" = "maximum"; and set zstd_lvl 19

            if command -q zstd
                tar --use-compress-program="zstd -$zstd_lvl -T0" -cf "$output" $targets
            else
                echo "Error: 'zstd' is not installed." >&2
                return 1
            end

        case '*.tar.bz2' '*.tbz2'
            set -l bz_lvl 6
            test "$level" = "fast"; and set bz_lvl 1
            test "$level" = "maximum"; and set bz_lvl 9

            if command -q pbzip2
                tar --use-compress-program="pbzip2 -$bz_lvl" -cf "$output" $targets
            else
                env BZIP2="-$bz_lvl" tar -cjf "$output" $targets
            end

        case '*.tar'
            tar -cf "$output" $targets

        case '*.zip'
            set -l mx 5
            test "$level" = "fast"; and set mx 1
            test "$level" = "maximum"; and set mx 9

            if test -n "$_7z_bin"
                $_7z_bin a -tzip -mx=$mx -mmt=on "$output" $targets
            else if command -q zip
                set -l zlvl "-6"
                test "$level" = "fast"; and set zlvl "-1"
                test "$level" = "maximum"; and set zlvl "-9"
                zip $zlvl -r "$output" $targets
            else
                echo "Error: Neither '7z' nor 'zip' is installed." >&2
                return 1
            end

        case '*.7z'
            if test -z "$_7z_bin"
                echo "Error: '7z' / '7zz' is not installed." >&2
                return 1
            end

            switch $level
                case fast
                    $_7z_bin a -t7z -m0=lzma2 -mx=1 -mmt=on "$output" $targets
                case normal
                    $_7z_bin a -t7z -m0=lzma2 -mx=5 -mmt=on "$output" $targets
                case maximum
                    $_7z_bin a -t7z -m0=lzma2 -mx=9 -md=64m -mfb=64 -mmt=on "$output" $targets
            end

        case '*'
            echo "Error: Unsupported output archive format '$output'." >&2
            echo "Supported: .tar.gz, .tgz, .tar.xz, .txz, .tar.zst, .tzst, .tar.bz2, .tbz2, .tar, .zip, .7z" >&2
            return 1
    end
end
