#!/bin/zsh

# === === === SAFETY FLAG === === ===
# Set to true to disable all script loading (recovery mode)
DISABLE_ZSH_SCRIPTS=false


# === === === BASE === === ===
export ZSH="$HOME/.oh-my-zsh"
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# OMZ SPECIFIC PLUGINS (NOT ZSH)
plugins=(
    dirhistory
)

source $ZSH/oh-my-zsh.sh


# === === === PLUGINS === === ===
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"


# === === === COLORS === === ===
style_reset=$'\e[0m'
style_bold=$'\e[1m'
style_faint=$'\e[2m'
style_italic=$'\e[3m'
style_underline=$'\e[4m'
style_invert=$'\e[7m'

fg_black=$'\e[30m'
fg_red=$'\e[31m'
fg_green=$'\e[32m'
fg_yellow=$'\e[33m'
fg_blue=$'\e[34m'
fg_magenta=$'\e[35m'
fg_cyan=$'\e[36m'
fg_white=$'\e[37m'

bg_black=$'\e[40m'
bg_red=$'\e[41m'
bg_green=$'\e[42m'
bg_yellow=$'\e[43m'
bg_blue=$'\e[44m'
bg_magenta=$'\e[45m'
bg_cyan=$'\e[46m'
bg_white=$'\e[47m'


# === === === ALIASES === === ===
alias py=python3
# alias docker=podman
# alias docker-compose=podman-compose
alias files='xdg-open "$(pwd)"'
alias websocat=~/Documents/websocat.sh
alias dnsleaktest=~/Documents/dnsleaktest.sh
alias eza="eza --tree --level=1 --color=always --icons=always --no-user --sort=modified --reverse --time-style=relative --hyperlink=always"
alias lsd="eza --tree --level=1 --color=always --icons=always --no-user --sort=modified --reverse --time-style=relative --hyperlink=always"


# === === === KEY BINDINGS === === ===
# CTRL + BACKSPACE & DELETE KEYS
bindkey '^H' backward-kill-word
bindkey '5~' kill-word

# HOME & END KEYS
bindkey '^D' end-of-line
bindkey '^A' beginning-of-line

# Ctrl + E to open file manager in pwd
bindkey '^E' files

# Ctrl + Z UNDO
bindkey '^Z' undo
# Ctrl + Y REDO
bindkey '^Y' redo

# === === === LOAD SCRIPTS === === ===
# Check both the local flag and environment variable
if [[ "$DISABLE_ZSH_SCRIPTS" != "true" && "$DISABLE_ZSH_SCRIPTS" != "1" ]] && \
  [[ "${DISABLE_ZSH_SCRIPTS:-}" != "true" && "${DISABLE_ZSH_SCRIPTS:-}" != "1" ]]; then

    # Load all .zsh files from scripts directory
    if [[ -d ~/.zsh/scripts ]]; then
        for script in ~/.zsh/scripts/**/*.zsh; do
            if [[ -r "$script" ]]; then
                source "$script"
            fi
        done
    fi
else
    echo "ZSH scripts loading disabled (recovery mode)"
fi


# === === === INITIALIZATION === === ===
eval "$(zoxide init zsh)"
# eval "$(starship init zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/theme.omp.toml)"

# bun completions
[ -s "/home/rvfet/.bun/_bun" ] && source "/home/rvfet/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# === === === OPTIONS === === ===
setopt AUTO_CD                 # change to a directory by typing its name
setopt CORRECT                 # autocorrect typos in path names
setopt EXTENDED_GLOB           # use extended globbing syntax
setopt HIST_IGNORE_DUPS        # don't record an entry that was just recorded again
setopt auto_param_keys         # remove trailing spaces
setopt auto_param_slash        # add slash for directories
setopt no_bsd_echo             # dont want BSD echo compat
setopt glob                    # sure i want globbing
setopt hist_reduce_blanks      # remove superfluous blanks

# ZLE_RPROMPT_INDENT=1
HISTSIZE=1000000               # size of history
LISTMAX=10000                  # never ask
REPORTTIME=180                 # report time if execution exceeds amount of seconds
SAVEHIST=100000                # maximum of history events to be save

fastfetch

export PATH=$PATH:/home/rvfet/.spicetify
