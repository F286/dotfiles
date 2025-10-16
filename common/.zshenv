# -------- fast PATH (prefer user bins; include Homebrew on Apple Silicon)
# Use array 'path' (zsh feature) with uniqueness to avoid string scans.
if [ -n "$ZSH_VERSION" ]; then
  typeset -U path PATH
fi
path=("$HOME/.local/bin" "$HOME/bin" "/opt/homebrew/bin" "/usr/local/bin" $path)

# Custom scripts
export PATH="$HOME/.local/bin:$PATH"

# Additional ustom scripts
export PATH="$HOME/bin:$PATH"

# Go programs
export PATH="$HOME/go/bin:$PATH"

# Custom
export PATH="$HOME/depot_tools:$PATH"
export SKIP_GCE_AUTH_FOR_GIT=1

# Set DISPLAY to the correct value
if [[ -z "${DISPLAY}" ]]; then
  export DISPLAY=:$(
    find /tmp/.X11-unix -maxdepth 1 -mindepth 1 -name 'X*' |
      grep -o '[0-9]\+$' | head -n 1
  )
fi

if (( $+commands[fzf] )); then
  export FZF_DEFAULT_COMMAND='rg --files --follow'
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --reverse \
    --ansi \
    --info=inline \
    --style=minimal \
    --no-cycle \
    --style=minimal \
    --color=prompt:#80a0ff,pointer:#ff5000,marker:#afff5f,hl:215,hl+:215"
fi

# ripgrep: hidden files, smart case, ignore common junk
export RIPGREP_CONFIG_PATH=~/.ripgreprc
export BAT_THEME="Visual Studio Dark+"
