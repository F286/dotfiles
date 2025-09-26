#!/usr/bin/env bash
set -euo pipefail

# Skip on Windows environments.
case "$(uname -s)" in
  MSYS*|MINGW*|CYGWIN*|*Windows*) exit 0 ;;
  *) : ;;
esac

echo "Running run_once_20-install-dev-tools for $(uname -mo)" >&2

have() { command -v "$1" >/dev/null 2>&1; }

SUDO_CMD=""
if have sudo && [ "$(id -u)" -ne 0 ]; then
  SUDO_CMD="sudo"
fi

maybe_sudo() {
  if [ -n "$SUDO_CMD" ]; then
    "$SUDO_CMD" "$@"
  else
    "$@"
  fi
}

ensure_local_bin() {
  mkdir -p "$HOME/.local/bin"
  PATH="$HOME/.local/bin:$PATH"
}

version_lt() {
  [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

github_latest_asset_url() {
  local repo="$1" pattern="$2" python_bin
  if have python3; then
    python_bin=python3
  elif have python; then
    python_bin=python
  else
    return 1
  fi
  "$python_bin" - "$repo" "$pattern" <<'PY'
import json
import re
import sys
import urllib.request

if len(sys.argv) != 3:
    sys.exit(1)
repo = sys.argv[1]
pattern = re.compile(sys.argv[2])

url = f"https://api.github.com/repos/{repo}/releases/latest"
headers = {
    "Accept": "application/vnd.github+json",
    "User-Agent": "chezmoi-dotfiles"
}
req = urllib.request.Request(url, headers=headers)
with urllib.request.urlopen(req) as resp:
    data = json.load(resp)
for asset in data.get("assets", []):
    name = asset.get("name", "")
    if pattern.search(name):
        print(asset["browser_download_url"])
        sys.exit(0)
sys.exit(1)
PY
}

install_lazygit_release() {
  ensure_local_bin
  local arch url tmp
  case "$(uname -m)" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Unsupported architecture for lazygit." >&2; return 1 ;;
  esac
  url=$(github_latest_asset_url "jesseduffield/lazygit" "lazygit_.*_Linux_${arch}\\.tar\\.gz") || return 1
  echo "Downloading lazygit ${arch} release..." >&2
  tmp=$(mktemp -d)
  if ! curl -fsSLo "$tmp/lazygit.tar.gz" "$url"; then
    rm -rf "$tmp"
    return 1
  fi
  if ! tar -C "$tmp" -xf "$tmp/lazygit.tar.gz" lazygit; then
    rm -rf "$tmp"
    return 1
  fi
  install -m 0755 "$tmp/lazygit" "$HOME/.local/bin/lazygit"
  rm -rf "$tmp"
  echo "Installed lazygit to $HOME/.local/bin/lazygit" >&2
}

APT_UPDATED=0
apt_install() {
  have apt-get || return 1
  if [ "$APT_UPDATED" -eq 0 ]; then
    maybe_sudo apt-get update -y
    APT_UPDATED=1
  fi
  maybe_sudo apt-get install -y "$@" || return 1
}

ZYPPER_REFRESHED=0
zypper_install() {
  have zypper || return 1
  if [ "$ZYPPER_REFRESHED" -eq 0 ]; then
    maybe_sudo zypper refresh >/dev/null 2>&1 || true
    ZYPPER_REFRESHED=1
  fi
  maybe_sudo zypper install -y "$@" || return 1
}

install_pkg() {
  local _label="$1"
  shift
  local spec manager pkg
  for spec in "$@"; do
    manager="${spec%%=*}"
    pkg="${spec#*=}"
    case "$manager" in
      brew)
        if have brew; then
          if ! brew list "$pkg" >/dev/null 2>&1; then
            brew install "$pkg" >/dev/null 2>&1 || brew install "$pkg"
          fi
          return 0
        fi
        ;;
      apt-get)
        if apt_install "$pkg"; then
          return 0
        fi
        ;;
      dnf)
        if have dnf; then
          if maybe_sudo dnf install -y "$pkg"; then
            return 0
          fi
        fi
        ;;
      pacman)
        if have pacman; then
          if maybe_sudo pacman -S --needed --noconfirm "$pkg"; then
            return 0
          fi
        fi
        ;;
      zypper)
        if zypper_install "$pkg"; then
          return 0
        fi
        ;;
      apk)
        if have apk; then
          if maybe_sudo apk add --no-cache "$pkg"; then
            return 0
          fi
        fi
        ;;
    esac
  done
  return 1
}

ensure_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    return
  fi

  local url tmp
  url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
  tmp="$(mktemp)"

  if have curl; then
    if curl -fsSL "$url" -o "$tmp"; then
      if RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp" --unattended; then
        :
      else
        echo "oh-my-zsh installer failed; please install manually." >&2
      fi
    else
      echo "Failed to download oh-my-zsh installer via curl." >&2
    fi
  elif have wget; then
    if wget -qO "$tmp" "$url"; then
      if RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp" --unattended; then
        :
      else
        echo "oh-my-zsh installer failed; please install manually." >&2
      fi
    else
      echo "Failed to download oh-my-zsh installer via wget." >&2
    fi
  else
    echo "Install oh-my-zsh manually (need curl or wget)." >&2
  fi

  rm -f "$tmp"
}

ensure_neovim() {
  if ! have git; then
    install_pkg "git" \
      brew=git \
      apt-get=git \
      dnf=git \
      pacman=git \
      zypper=git \
      apk=git || true
  fi

  if ! have git; then
    echo "git not found; skipping LazyVim bootstrap." >&2
    return
  fi

  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  local tmp
  tmp="$(mktemp -d)"

  if git clone --depth=1 https://github.com/LazyVim/starter "$tmp/starter"; then
    rm -rf "$config_dir"
    mkdir -p "$(dirname "$config_dir")"
    mv "$tmp/starter" "$config_dir"
    rm -rf "$config_dir/.git"
  else
    echo "Failed to clone LazyVim starter; leaving existing config untouched." >&2
  fi

  rm -rf "$tmp"
}

ensure_lazygit() {
  have lazygit && return
  if install_pkg "lazygit" \
    brew=lazygit \
    apt-get=lazygit \
    pacman=lazygit \
    zypper=lazygit \
    dnf=lazygit \
    apk=lazygit; then
    return
  fi
  if have dnf; then
    if maybe_sudo dnf copr enable -y atim/lazygit && maybe_sudo dnf install -y lazygit; then
      return
    fi
  fi
  if install_lazygit_release; then
    return
  fi
  echo "Install lazygit manually (no supported package manager)." >&2
}

ensure_fzf() {
  have fzf && return
  install_pkg "fzf" \
    brew=fzf \
    apt-get=fzf \
    dnf=fzf \
    pacman=fzf \
    zypper=fzf \
    apk=fzf || echo "Install fzf manually." >&2
}

rebuild_bat_cache() {
  local bat_bin=""
  if have bat; then
    bat_bin="bat"
  elif have batcat; then
    bat_bin="batcat"
  fi

  if [ -n "$bat_bin" ]; then
    "$bat_bin" cache --build >/dev/null 2>&1 || true
  fi
}

ensure_ripgrep() {
  have rg && return
  install_pkg "ripgrep" \
    brew=ripgrep \
    apt-get=ripgrep \
    dnf=ripgrep \
    pacman=ripgrep \
    zypper=ripgrep \
    apk=ripgrep || echo "Install ripgrep manually." >&2
}

ensure_bat() {
  if have bat; then
    rebuild_bat_cache
    return
  fi

  if have batcat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    rebuild_bat_cache
    return
  fi

  if install_pkg "bat" \
    brew=bat \
    apt-get=bat \
    dnf=bat \
    pacman=bat \
    zypper=bat \
    apk=bat; then
    :
  else
    echo "Install bat manually." >&2
  fi

  if ! have bat && have batcat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  rebuild_bat_cache
}

ensure_oh_my_zsh
ensure_neovim
ensure_lazygit
ensure_fzf
ensure_ripgrep
ensure_bat
