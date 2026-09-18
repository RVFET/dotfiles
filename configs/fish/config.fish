set -g fish_greeting

# === ENVIRONMENT VARIABLES ===
set -g fish_history_limit 1000000000
set -gx BUN_INSTALL "$HOME/.bun"
set -gx GOPATH "$HOME/go"
set -gx CARGO_HOME "$HOME/.cargo"

if set -q SSH_CONNECTION
    set -gx EDITOR nano
else
    set -gx EDITOR micro
end
set -gx VISUAL codium

# === PATH CONSTRUCT ===
fish_add_path -g -p \
    ~/scripts \
    ~/.local/bin \
    /usr/local/go/bin \
    $GOPATH/bin \
    ~/.cargo/bin \
    $BUN_INSTALL/bin

if test -d /opt/homebrew/bin; /opt/homebrew/bin/brew shellenv | source; end

# === STANDARD ALIASES (No inline expansion) ===
alias py='python3'
alias code='codium'
alias websocat="$HOME/Documents/websocat.sh"

set -l eza_flags -lh --tree --level=1 --color=always --icons=always --no-user --sort=modified --reverse --time-style=relative --hyperlink=always
alias eza="eza $eza_flags"
alias lsd="eza $eza_flags"

# === HELPER FUNCTIONS FOR DUAL-STATE BINDINGS ===
function __fish_ctrl_d_end_or_exit
    set -l cmd (commandline)
    if test -n "$cmd"
        commandline -f end-of-line
    else
        exit 0
    end
end

function __most_recent_file
    set -l tok (commandline -ct)
    test -z "$tok"; and set tok "*"

    string match -q "*[*?]*" -- "$tok"; or set tok "$tok*"

    set -l exp_tok (string replace -r '^~' "$HOME" -- "$tok")
    set -l eval_tok (string replace -a -r '([^a-zA-Z0-9/._*?-])' '\\\\$1' -- "$exp_tok")

    set -l file (eval "command ls -1tdN -- $eval_tok 2>/dev/null" | head -n 1)

    if test -n "$file"
        commandline -rt -- (string escape -- $file)
    end
end

# UNFUCK THE HISTORY
function force_immediate_history_write --on-event fish_postexec
    history save
end

# === KEY BINDINGS ===
function fish_user_key_bindings
    # NAVIGATION & EXECUTION
    bind ctrl-d __fish_ctrl_d_end_or_exit
    bind ctrl-a beginning-of-line

    bind ctrl-backspace backward-kill-path-component
    bind alt-backspace backward-kill-word

    bind ctrl-delete kill-path-component
    bind alt-delete kill-word

    # EDITING STACK
    bind ctrl-z undo
    bind ctrl-y redo

    bind alt-m __most_recent_file

    bind ctrl-r forgot

    bind \r repaint execute
end

# === INTERACTIVE INITIALIZATION ===
if status is-interactive
    type -q zoxide; and zoxide init fish | source
    type -q starship; and starship init fish | source
    type -q fastfetch; and fastfetch
#     type -q fetch; and fetch --infinite
end
