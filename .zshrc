# ====================================================================
# 1. ZINIT BOOTSTRAP & ANNEXES
# ====================================================================
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager...%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load Zinit annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ====================================================================
# 2. PROMPT & UI SETTINGS
# ====================================================================
autoload -Uz promptinit && promptinit

# Load async (required for Pure's Git features)
zinit light mafredri/zsh-async

# Load Pure theme
zinit ice pick"pure.zsh" src"async.zsh"
zinit light sindresorhus/pure

# Initialize theme
[[ "$PROMPT" != *"pure"* ]] && prompt pure

# ====================================================================
# 3. PLUGINS (TURBO MODE)
# ====================================================================
# Tell zsh-autosuggestions to look at history AND completion engine (Fish-style)
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zinit wait'0' lucid for \
    atinit"zicompinit; zicdreplay" \
        zsh-users/zsh-completions \
    blockf \
        atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    atload"!_zsh_highlight" \
        zdharma-continuum/fast-syntax-highlighting \
    skywind3000/z.lua

# ====================================================================
# 4. KEYBINDINGS & INPUT FIXES
# ====================================================================
# Home / End / Delete
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Ctrl + Left / Right to skip words
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ====================================================================
# 5. ALIASES & SHELL OPTIONS
# ====================================================================
alias hx="helix"
alias ..="cd .."
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push origin HEAD:main"

alias rebootnow='sudo systemctl reboot'
alias shutdownnow='sudo systemctl poweroff'


# ====================================================================
# 6. ENVIRONMENT VARIABLES
# ====================================================================
export EDITOR="helix"
export VISUAL="helix"

export PATH=$PATH:/usr/sbin
export PATH="$HOME/.local/bin:$PATH"

# ====================================================================
# 7. YAZI
# ====================================================================
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ====================================================================
# 8. DETECT WINDOW MANAGER & SET HELIX THEME
# ====================================================================
# Enable True Color support for Helix and other terminals
export COLORTERM=truecolor

#if [[ "$XDG_CURRENT_DESKTOP" == "sway" ]] || [[ "$SWAYSOCK" ]]; then
#    export HELIX_THEME="matcha-green"
#elif [[ "$XDG_CURRENT_DESKTOP" == "awesome" ]] || [[ "$DISPLAY" ]]; then
#    # We check for $DISPLAY as a fallback for X11/Awesome
#    export HELIX_THEME="gruvbox"
#fi


# ====================================================================
# 9. AUTO-START TMUX
# ====================================================================

#if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#  tmux attach -t default || tmux new -s default
#fi

# ====================================================================
# 10. AUTO-START X (TTY1 ONLY)
# ====================================================================
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx >/dev/null 2>&1
fi

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

