# Dotfiles

Personal dotfiles for my development environment, managed with [chezmoi](https://www.chezmoi.io/). Chezmoi bootstraps a vanilla [LazyVim](https://lazyvim.github.io) configuration for Neovim and also sets up tools like Ripgrep, Helix, Kitty, VS Code, and more so they can be reproduced on any machine. JetBrainsMono Nerd Font is installed and configured as the default font for VS Code, Windows Terminal, macOS Terminal, and Kitty. It also configures Google Chrome to install the [Vimium](https://chromewebstore.google.com/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb) extension automatically.

## Installation with chezmoi

Install these dotfiles using [chezmoi](https://www.chezmoi.io/). Below are example commands for different platforms.

### macOS

```bash
# Install Homebrew from https://brew.sh if it's not already present
brew install chezmoi
chezmoi init F286
# Review changes if desired
chezmoi diff
chezmoi apply
```

### Linux

do this to install chezmoi on linux correclty

```bash
sudo curl -fsSL https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi-linux-amd64 -o /usr/bin/chezmoi

sudo chmod +x /usr/bin/chezmoi
```

```bash
chezmoi init F286
# Review changes if desired
chezmoi diff
chezmoi apply
```

### Windows

Run PowerShell as Administrator. Before running the scripts, set the execution policy for the current process:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winget install twpayne.chezmoi
chezmoi init F286
# Review changes if desired
chezmoi diff
chezmoi apply
```

If `chezmoi` is already installed, you can also apply these dotfiles directly:

```bash
chezmoi init --apply https://github.com/F286/dotfiles.git
```

Or install `chezmoi` and apply in one step:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/F286/dotfiles.git
```

Replace `USERNAME` with the GitHub owner of this repository if using a fork.
