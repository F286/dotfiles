
# shellcheck shell=zsh

# -------- editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# -------- interactive TTY tweaks (skip in non‑tty to avoid extra 'stty' call)
if [[ -o interactive && -t 0 ]]; then
  stty -ixon -ixoff
fi

# -------- shell options
setopt autocd nocaseglob extended_glob globdots
setopt hist_ignore_all_dups hist_ignore_space
setopt share_history inc_append_history append_history

# -------- history
# NOTE: very large values slow startup because zsh loads history on launch.
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"

# -------- key bindings
bindkey -e                              # Emacs keybindings
bindkey '^[[1;5C' forward-word          # Ctrl+Right
bindkey '^[[1;5D' backward-word         # Ctrl+Left

# -------- completion (cached)
# Cache to XDG location and compile the dump for speed.
zmodload -i zsh/complist
autoload -Uz compinit
: "${XDG_CACHE_HOME:=$HOME/.cache}"
ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
mkdir -p -- "$ZSH_CACHE_DIR"
_compdump="$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION"

# Fast path: if dump exists, use curtailed checks (-C). Otherwise, build it.
if [[ -s $_compdump ]]; then
  compinit -C -d "$_compdump"
else
  compinit -d "$_compdump"
fi

# Byte-compile the dump (only when updated)
if [[ -s $_compdump && ( ! -s $_compdump.zwc || $_compdump -nt $_compdump.zwc ) ]]; then
  zcompile "$_compdump"
fi
unset _compdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# # -------- prompt (Starship)
eval "$(starship init zsh)"

# -------- zoxide (smart cd)
if (( $+commands[zoxide] )); then
  # Initialize immediately so `z` works on the very first command
  eval "$(zoxide init zsh)"
fi

# -------- fzf-powered history search (Ctrl-R), deduped & reverse-chronological
if (( $+commands[fzf] )); then
  _fzf_history_widget() {
    local selected
    selected=$(
      fc -nrl 1 | awk '!seen[$0]++' | \
      fzf --height=80% --reverse --tiebreak=index --no-sort \
          --prompt='History> ' --style=minimal --query="$LBUFFER"
    ) || return
    LBUFFER=$selected
    zle redisplay
  }
  zle -N _fzf_history_widget
  bindkey '^R' _fzf_history_widget
fi

# -------- safer Git defaults where tools may be missing
if ((! $+commands[delta] )) || ((! $+commands[code] )); then
  git() {
    local -a cfg=()
    ((! $+commands[delta] )) && cfg+=(-c core.pager=less -c interactive.diffFilter=cat)
    if ((! $+commands[code] )); then
      if (( $+commands[nvim] )); then
        cfg+=(-c merge.tool=nvimdiff3 -c difftool.tool=nvimdiff)
      else
        cfg+=(-c merge.tool=vimdiff -c difftool.tool=vimdiff)
      fi
    fi
    command git "${cfg[@]}" "$@"
  }
fi

# -------- aliases
alias grep='grep --color=auto'
alias stow_apply='$HOME/dotfiles/apply.sh'
alias stow_init='$HOME/dotfiles/init.sh'
alias stow_update='$HOME/dotfiles/update.sh && $HOME/dotfiles/apply.sh'
alias stow_update_init_auto='$HOME/dotfiles/update.sh && AUTO_INSTALL=1 $HOME/dotfiles/init.sh'

# bat / batcat
if (( $+commands[bat] )); then
  alias cat='bat'
elif (( $+commands[batcat] )); then
  alias bat='batcat'
  alias cat='batcat'
fi

# eza ls replacements
if (( $+commands[eza] )); then
  alias ls='eza --color=auto --group-directories-first'
  alias ll='eza -al --color=auto --group-directories-first'
  alias la='eza -a --color=auto --group-directories-first'
  alias tree='eza --tree --icons --group-directories-first'
fi

# fd on Debian/Ubuntu where it's named fdfind
if ((! $+commands[fd] )) && (( $+commands[fdfind] )); then
  alias fd='fdfind'
fi

# -------- file managers that cd to the last visited dir
e() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  command yazi "$@" --cwd-file="$tmp"
  cwd="$(<"$tmp")"
  rm -f -- "$tmp"
  [[ -n $cwd && $cwd != "$PWD" ]] && builtin cd -- "$cwd"
}

lfcd() {
  local tmp dir
  tmp="$(mktemp -t lfcd.XXXXXX)"
  command lf -last-dir-path "$tmp" -- "$@"
  dir="$(<"$tmp")"
  rm -f -- "$tmp"
  [[ -n $dir && $dir != "$PWD" ]] && builtin cd -- "$dir"
}
alias lf='lfcd'

# TODO: This needs to be set for some reason to get everything
# to work in the terminal - find the root cause & remove this
unset GIT_PAGER

gg() { command lazygit; }

# -------- plugins (load AFTER everything else; keep syntax-highlighting last)
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  for dir in "/opt/homebrew/share/$plugin" "/usr/local/share/$plugin" "/usr/share/$plugin"; do
    if [[ -r "$dir/$plugin.zsh" ]]; then
      source "$dir/$plugin.zsh"
      break
    fi
  done
done

# -------- machine-specific overrides
# shellcheck disable=SC1090
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
