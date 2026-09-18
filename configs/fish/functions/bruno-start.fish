function bruno-start --description 'Launch Bruno with strict SCRAPER check, auto-clone/restore, and config sync'
    set -l collection_dir "$HOME/bruno"
    # Set your remote repository URL here (SSH or HTTPS)
    set -l repo_url "https://github.com/rvfet/bruno-backups.git"

    # --- Notification Helper ---
    function __bruno_notify -a urgency title body
        switch (uname)
            case Linux
                if command -q notify-send
                    notify-send -a "Bruno" -u "$urgency" "$title" "$body"
                end
            case Darwin
                set -l clean_title (string replace -a '"' '\\"' "$title")
                set -l clean_body (string replace -a '"' '\\"' "$body")
                osascript -e "display notification \"$clean_body\" with title \"Bruno: $clean_title\"" >/dev/null 2>&1
        end
    end

    # --- Helper: Validation rules ---
    function __bruno_is_valid -S -a dir
        # Rule 1: Must be a git repo
        if not git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
            return 1
        end

        # Rule 2: Must have a collection explicitly called "SCRAPER"
        if not test -d "$dir/SCRAPER"
            return 1
        end

        # Rule 3: Must have more than one collection
        set -l count 0
        for f in (find "$dir" -maxdepth 2 \( -name "bruno.json" -o -name "opencollection.yml" \) ! -path "*/.git/*" 2>/dev/null)
            set count (math $count + 1)
        end

        if test $count -le 1
            return 1
        end

        return 0
    end

    # --- Helper: Snapshot creation ---
    function __bruno_backup_state -S -a src_dir
        if test -d "$src_dir"; and test (count (ls -A "$src_dir" 2>/dev/null)) -gt 0
            set -l date_str (date +'%d-%m-%Y')
            set -l bak_path "$HOME/.bruno-bak-$date_str"

            if test -e "$bak_path"
                set bak_path "$HOME/.bruno-bak-$date_str"_(date +'%H%M%S')
            end

            cp -a "$src_dir" "$bak_path"
            echo "Emergency snapshot created at: $bak_path" >&2
        end
    end

    # --- 1. Runtime & Binary Detection ---
    set -l bruno_cmd
    set -l pref_file

    switch (uname)
        case Darwin
            for path in "/Applications/Bruno.app/Contents/MacOS/Bruno" "$HOME/Applications/Bruno.app/Contents/MacOS/Bruno"
                if test -x "$path"
                    set bruno_cmd "$path"
                    break
                end
            end
            set pref_file "$HOME/Library/Application Support/bruno/preferences.json"
        case Linux
            if command -q flatpak; and flatpak info com.usebruno.Bruno >/dev/null 2>&1
                set bruno_cmd flatpak run com.usebruno.Bruno
                set pref_file "$HOME/.var/app/com.usebruno.Bruno/config/bruno/preferences.json"
            else if command -q bruno
                set bruno_cmd (command -s bruno)[1]
                set pref_file "$HOME/.config/bruno/preferences.json"
            end
    end

    if test (count $bruno_cmd) -eq 0
        __bruno_notify critical "Error" "Bruno executable or Flatpak not found."
        return 1
    end

    # Deduplication
    switch (uname)
        case Linux
            if test "$bruno_cmd[1]" = "flatpak"
                if flatpak ps --columns=application 2>/dev/null | string match -q "com.usebruno.Bruno"
                    __bruno_notify normal "Running" "Bruno (Flatpak) is already open."
                    return 0
                end
            else if pgrep -x bruno >/dev/null 2>&1
                __bruno_notify normal "Running" "Bruno is already open."
                return 0
            end
        case Darwin
            if pgrep -f "Bruno.app/Contents/MacOS/Bruno" >/dev/null 2>&1
                __bruno_notify normal "Running" "Bruno is already open."
                return 0
            end
    end

    # --- 2. Pre-flight Validation & Auto-Restore ---
    if not __bruno_is_valid "$collection_dir"
        __bruno_backup_state "$collection_dir"
        __bruno_notify normal "Restoring" "Invalid state or missing SCRAPER. Restoring from remote..."

        # Case A: Not a git repo at all -> Clone from scratch
        if not git -C "$collection_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
            rm -rf "$collection_dir"
            git clone "$repo_url" "$collection_dir" >/dev/null 2>&1
        else
            # Case B: Is a git repo, but missing SCRAPER or corrupted -> Force reset
            set -l branch (git -C "$collection_dir" branch --show-current 2>/dev/null)
            test -z "$branch"; and set branch "master"

            git -C "$collection_dir" fetch origin "$branch" >/dev/null 2>&1
            git -C "$collection_dir" reset --hard "origin/$branch" >/dev/null 2>&1
            git -C "$collection_dir" clean -fd >/dev/null 2>&1
        end

        if not __bruno_is_valid "$collection_dir"
            __bruno_notify critical "Error" "Restore failed. Verify repository URL and remote branches."
            return 1
        end
    else
        set -l branch (git -C "$collection_dir" branch --show-current 2>/dev/null; or echo "master")
        git -C "$collection_dir" pull --rebase origin "$branch" >/dev/null 2>&1
    end

    # --- 3. Synchronize Preferences ---
    set -l collection_paths
    for meta in (find "$collection_dir" -maxdepth 2 \( -name "bruno.json" -o -name "opencollection.yml" \) ! -path "*/.git/*" 2>/dev/null)
        set -a collection_paths (dirname "$meta")
    end
    set collection_paths (printf '%s\n' $collection_paths | sort -u)

    if test -n "$pref_file"; and command -q jq
        mkdir -p (dirname "$pref_file")
        if not test -f "$pref_file"
            echo '{"lastOpenedCollections":[]}' > "$pref_file"
        end

        set -l json_array (printf '%s\n' $collection_paths | jq -R . | jq -s .)
        set -l tmp_pref (mktemp)
        jq --argjson cols "$json_array" '.lastOpenedCollections = $cols' "$pref_file" > "$tmp_pref"
        and mv "$tmp_pref" "$pref_file"
    end

    # --- 4. Launch & Supervise ---
    $bruno_cmd >/dev/null 2>&1 &
    set -l bruno_pid $last_pid
    wait $bruno_pid

    # --- 5. Post-Flight Check & Outbound Sync ---
    if not __bruno_is_valid "$collection_dir"
        __bruno_backup_state "$collection_dir"
        __bruno_notify critical "Push Aborted" "SCRAPER missing or wiped during session. State backed up; push aborted."
        return 1
    end

    set -l dirty (git -C "$collection_dir" status --porcelain 2>/dev/null | string collect)
    if test -n "$dirty"
        set -l branch (git -C "$collection_dir" branch --show-current 2>/dev/null; or echo "master")
        set -l host (command hostname -s 2>/dev/null; or prompt_hostname)
        set -l datetime (date +'%Y-%m-%d %H:%M:%S')

        git -C "$collection_dir" add -A
        if git -C "$collection_dir" commit -m "auto: updates from $host ($datetime)" >/dev/null 2>&1
            if git -C "$collection_dir" push origin "$branch" >/dev/null 2>&1
                __bruno_notify normal "Sync Complete" "Pushed updates to origin/$branch."
            else
                __bruno_notify critical "Push Failed" "Committed locally, remote push failed."
            end
        end
    end

    functions -e __bruno_notify
    functions -e __bruno_is_valid
    functions -e __bruno_backup_state
end
