# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091
# ~/.config/zsh/personal.zsh  — your personal Zsh config
# Double‑source guard (environment-proof)
typeset -gA _PERSONAL_ZSH_GUARD
[[ -n ${_PERSONAL_ZSH_GUARD[loaded]-} ]] && return
_PERSONAL_ZSH_GUARD[loaded]=1

# Helpers
source_if_exists() { [ -r "$1" ] && . "$1"; }
source_dir() {
  local dir="$1"; [ -d "$dir" ] || return 0
  setopt local_options null_glob
  local f; for f in "$dir"/*.zsh; do . "$f"; done
}

# Prompt: oh-my-zsh (default)
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  : "${ZSH_THEME:=robbyrussell}"
  typeset -ga plugins
  if (( ${#plugins[@]:-0} == 0 )); then plugins=(git); fi
  source "$ZSH/oh-my-zsh.sh"
fi

# Options & keybindings
setopt autocd extended_glob no_beep
bindkey -v  # vi mode; change to emacs if you prefer

# PATH (dedupe)
typeset -U path PATH
path+=("$HOME/bin" "$HOME/.local/bin" "$HOME/go/bin")

# Aliases (add more)
alias ll='ls -lah'

# Completion (skip if oh-my-zsh already handled it)
if ! typeset -f omz >/dev/null 2>&1; then
  autoload -Uz compinit && compinit -i
fi

# Optional alternative prompts (disabled)
# [[ -r "$HOME/.p10k.zsh" ]] && . "$HOME/.p10k.zsh"

# Plugins (optional; keep lightweight)
# Example: zsh-autosuggestions / zsh-syntax-highlighting
# source_if_exists "$HOME/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# source_if_exists "$HOME/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Work overlay (optional)
source_if_exists "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/work.zsh"

# Local, untracked tweaks (ignored by chezmoi)
source_if_exists "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh"
