# -------- fast PATH (prefer user bins; include Homebrew on Apple Silicon)
# Use array 'path' (zsh feature) with uniqueness to avoid string scans.
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/bin" "/opt/homebrew/bin" "/usr/local/bin" $path)

# Custom scripts
export PATH="$HOME/.local/bin:$PATH"

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
