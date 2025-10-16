#!/usr/bin/env bash
# Install the latest Neovim AppImage into ~/.local/bin
set -euo pipefail

if [[ "$(uname)" != "Linux" ]]; then
  echo "install-nvim.sh currently supports Linux hosts only."
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to download Neovim." >&2
  exit 1
fi

readonly url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
readonly tmp_file="nvim-linux-x86_64.appimage"
readonly install_dir="${HOME}/.local/bin"
readonly install_target="${install_dir}/nvim"

printf '⬇️  Downloading Neovim AppImage...\n'
curl -fLSo "${tmp_file}" "${url}"
chmod u+x "${tmp_file}"
mkdir -p "${install_dir}"
mv -f "${tmp_file}" "${install_target}"

printf '✅ Neovim installed to %s\n' "${install_target}"
