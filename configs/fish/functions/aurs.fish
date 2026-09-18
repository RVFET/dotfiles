function aurs
    paru -Slq | fzf --ansi --preview 'paru -Si {} --color=always' | xargs -r -o paru -S
end
