# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091
# ~/.config/zsh/personal.zsh  — your personal Zsh config
# Double‑source guard
[[ -n ${PERSONAL_ZSH_LOADED-} ]] && return
export PERSONAL_ZSH_LOADED=1

# Helpers
source_if_exists() { [ -r "$1" ] && . "$1"; }
source_dir() {
  local dir="$1"; [ -d "$dir" ] || return 0
  setopt local_options null_glob
  local f; for f in "$dir"/*.zsh; do . "$f"; done
}

# Options & keybindings
setopt autocd extended_glob no_beep
bindkey -v  # vi mode; change to emacs if you prefer

# PATH (dedupe)
typeset -U path PATH
path+=("$HOME/bin" "$HOME/.local/bin" "$HOME/go/bin")

# Aliases (add more)
alias ll='ls -lah'

# Completion
autoload -Uz compinit && compinit -i

# Prompt (pick one)
# eval "$(starship init zsh)"
# [[ -r "$HOME/.p10k.zsh" ]] && . "$HOME/.p10k.zsh"

# Plugins (optional; keep lightweight)
# Example: zsh-autosuggestions / zsh-syntax-highlighting
# source_if_exists "$HOME/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# source_if_exists "$HOME/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Work overlay (optional)
source_if_exists "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/work.zsh"

# Local, untracked tweaks (ignored by chezmoi)
source_if_exists "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh"
