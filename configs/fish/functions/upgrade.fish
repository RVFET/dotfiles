function upgrade
    sudo pacman -Syyu && flatpak upgrade && flatpak uninstall --unused -y && paru -Syyu && ir upgrade
end
