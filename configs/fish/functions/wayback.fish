function wayback --description "Search Wayback Machine CDX index for a URL"
    if test (count $argv) -eq 0
        echo "Usage: wb <url> [extra_xh_flags...]" >&2
        return 1
    end

    set -l url $argv[1]
    set -l extra $argv[2..]
    xh web.archive.org/cdx/search/cdx "collapse==urlkey" "output==text" "fl==original" "url==$url" $extra -b | sort -u
end
