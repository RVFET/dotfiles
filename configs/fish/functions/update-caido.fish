function update-caido --description "Fetch latest Caido CLI for Linux/macOS"
    # 1. Normalize OS
    set -l target_os
    switch (uname -s)
        case Linux
            set target_os "linux"
        case Darwin
            set target_os "macos"
        case '*'
            echo "Error: Unsupported OS: $(uname -s)" >&2
            return 1
    end

    # 2. Normalize Architecture
    set -l target_arch
    switch (uname -m)
        case x86_64 amd64
            set target_arch "x86_64"
        case arm64 aarch64
            set target_arch "aarch64"
        case '*'
            echo "Error: Unsupported architecture: $(uname -m)" >&2
            return 1
    end

    # 3. Query release metadata strictly via curl
    set -l manifest (curl -sSL https://caido.download/releases/latest)
    if test -z "$manifest"
        echo "Error: Failed to fetch Caido release manifest." >&2
        return 1
    end

    set -l latest_ver (echo $manifest | jq -r '.version')

    # 4. Check installed version
    set -l current_ver "none"
    if command -q caido-cli
        set -l ver_output (caido-cli --version 2>/dev/null | string match -r '[0-9]+\.[0-9]+\.[0-9]+')
        test -n "$ver_output[1]"; and set current_ver $ver_output[1]
    end

    if test "$latest_ver" = "$current_ver"
        echo "Caido CLI is already up to date ($current_ver)."
        return 0
    end

    echo "Updating Caido CLI [$target_os/$target_arch]: $current_ver -> $latest_ver"

    # 5. Extract link and extension format
    set -l download_url (echo $manifest | jq -r --arg os "$target_os" --arg arch "$target_arch" \
        '.links[] | select(.os == $os and .kind == "cli" and .arch == $arch) | .link')
    set -l format (echo $manifest | jq -r --arg os "$target_os" --arg arch "$target_arch" \
        '.links[] | select(.os == $os and .kind == "cli" and .arch == $arch) | .format')

    if test -z "$download_url" -o "$download_url" = "null"
        echo "Error: No matching release found for $target_os/$target_arch." >&2
        return 1
    end

    # 6. Download and extract using your extract function
    set -l tmpdir (mktemp -d)
    set -l archive_name "caido.$format"

    curl -sSL "$download_url" -o "$tmpdir/$archive_name"

    # extract runs in $PWD; scope to $tmpdir
    pushd $tmpdir >/dev/null
    extract "$archive_name" >/dev/null
    popd >/dev/null

    mkdir -p ~/.local/bin

    # Upstream binary is named 'caido' inside archives
    if test -f "$tmpdir/caido"
        mv -f "$tmpdir/caido" ~/.local/bin/caido-cli
    else if test -f "$tmpdir/caido-cli"
        mv -f "$tmpdir/caido-cli" ~/.local/bin/caido-cli
    else
        echo "Error: Failed to find binary in unpacked files." >&2
        rm -rf "$tmpdir"
        return 1
    end

    chmod +x ~/.local/bin/caido-cli

    # 7. Clear macOS quarantine flag if on Darwin
    if test "$target_os" = "macos"
        xattr -d com.apple.quarantine ~/.local/bin/caido-cli 2>/dev/null; or true
    end

    rm -rf "$tmpdir"
    echo "Installed caido-cli $latest_ver to ~/.local/bin/caido-cli"
end
