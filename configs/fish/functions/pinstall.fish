function pinstall --description "Cross-distro package installer"
    if test (count $argv) -eq 0
        echo "Usage: pinstall <package_name>" >&2
        return 1
    end

    if test -f /etc/arch-release
        sudo pacman -S $argv
    else if test -f /etc/debian_version
        sudo apt install $argv
    else if test -f /etc/fedora-release
        sudo dnf install $argv
    else
        echo "Unsupported OS release" >&2
        return 1
    end
end
