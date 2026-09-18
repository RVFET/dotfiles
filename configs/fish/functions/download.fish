function download --description "Accelerated download using aria2c (16 connections)"
    switch (count $argv)
        case 1
            aria2c -x16 --dir="$HOME/Downloads" $argv[1]
        case 2
            set -l url $argv[1]
            set -l full_path $argv[2]
            set -l dir (path dirname $full_path)
            set -l filename (path basename $full_path)
            mkdir -p $dir
            aria2c -x16 --dir=$dir --out=$filename $url
        case '*'
            echo "Usage: download <url> [full_path]" >&2
            return 1
    end
end
