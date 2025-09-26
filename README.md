# Dotfiles

Personal dotfiles managed with [Stow](https://www.gnu.org/software/stow/) for easy configuration management across machines.

## Install

### Clone

```sh
# Clone and navigate
git clone https://github.com/F286/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Preview

Shows which files will be symlinked and any conflicts. **Only proceed after reviewing!**

```sh
stow -n -v common        # Preview - add mac/windows on those platforms
./apply.sh -n            # Similar to previous command, but with additional checks
```

### Mutate

```sh
./init.sh                # Install if preview looks good
```

## Stow Commands

```sh
# Install packages
stow common              # Shared configs
stow mac                 # macOS-specific (on Mac)  
stow windows             # Windows-specific (on Windows)

# Remove packages
stow -D common           # Uninstall

# Update after changes (restow)
stow -R common           # Refresh symlinks after editing dotfiles
                         # Use when: files added/removed, broken links, or conflicts
```

**When to restow:**

- Added/removed files in your dotfiles
- Symlinks appear broken or missing
- After resolving stow conflicts
- When switching between git branches

## Linux .bashrc Note

Linux systems have a default `.bashrc`. These dotfiles include `.bashrc-custom` to avoid conflicts:

```sh
~/.bashrc-custom  # Add to existing .bashrc to source the custom one
```

## CLI Tools

- `ripgrep` for searching directories quickly
- `fd` as a faster `find`
- `bat` as a colorful `cat`
- `eza` as an improved `ls`
- `lf` as a modern terminal file manager
- `delta` for modern git diffs (also used in Lazygit)
  - diffs are side-by-side by default, while LazyGit shows inline changes
- `lazygit` for a simple git TUI
- `starship` for a customizable cross-shell prompt

## Nvim Version

If Nvim is using a version that is too old it can be made to use the newest version by running this

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
mkdir -p ~/.local/bin
mv nvim-linux-x86_64.appimage ~/.local/bin/nvim

## Mac

### Custom Alt Tab

I use the 'Alt Tab' program for easy window switching.

Activate with footpedal + r. Navigate with arrow keys and space to select.

Settings are stored in `mac/Library/Preferences/com.lwouis.alt-tab-macos.plist` and include:

- Custom appearance size and alignment
- Arrow keys enabled for navigation
- UI elements hidden (badges, colored circles, status icons, menubar icon)
- Control key as hold shortcut

### Hammerspoon

Spotlight opens when the Cmd key is quickly tapped by itself. A short delay prevents accidental triggers.

### Fluor

Automatically switches mode of fn keys per program. Important as keyboard macros use F... keys.

Settings are stored in `mac/Library/Preferences/com.pyrolyse.Fluor.plist` and include:

- App-specific rules for VS Code and kitty (behavior mode 2)
- Notification preferences

### Better Display

Allows increased brightness when viewing SDR content on an HDR monitor.

## Windows

### Config

```text
- To get the Alt Tab switcher to work better
    - Go to Accessibility -> Visual Effects -> Animation effects & turn them off
    - Without this, moving to another tab requires waiting a split second.
- Set cursor blink rate to 0
- Set cursor thickness to 6
```

lf expects its configuration under `%AppData%\lf` on Windows. These dotfiles create a symlink to `~/.config/lf` so settings apply across OSes.

### PowerShell 7

Use this since it's nicer than the default PowerShell 5.

### Visual Studio

```text
- For Visual Studio use VSVim with the provided vsvimrc
- Using the plugin 'Peasy Motion' with the following settings:
- Allowed jump label characters: tsraneiodhgmplfuc,bjvk
    - (note this is optimized for Colemak Mod DH)
- Use a plugin called MinimalVS for nice fullscreen mode
    - https://marketplace.visualstudio.com/items?itemName=pavonism.minimalVS
- There is a plugin called 'Smooth Caret' which messes with the VSVim caret - make sure it's disabled
```

### Perforce

Ensure you set the correct environment variable to allow the diff to work:

```cmd
P4DIFF="C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe" /Diff %1 %2
```

### Visual Studio Code

I'm using a few plugins:

- Vim
- Yazi
- clangd for C++ language features

Extensions listed in `vscode_extensions.txt` will be installed automatically
when these dotfiles are applied. Custom keybindings are documented in
[`docs/vscode-keybindings.md`](docs/vscode-keybindings.md).
On macOS, the init script falls back to
`/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code` if the
`code` command isn't in your `PATH`.

For remote development, install the **Remote - SSH** extension. Add your server
details to `~/.ssh/config`, e.g.

```ssh
Host devbox
  HostName server.example.com
  User you
```

Use the “Remote-SSH: Connect to Host…” command in VS Code to start a session.

### Keyboard

Run `kinesis-advantage2/sync-kinesis-layouts.ps1` with the Kinesis Advantage2 V-Drive connected & key bindings will auto sync.

I've had issues where the keyboard drive gets totally corrupted when syncing from Mac - so just stick to Windows.

For more detail see the 'Interaction' repo.

## Macro Bindings

```text

build and run - Shift F2
find class - Shift F3
scroll up - Shift F4
scroll down - Shift F6
stop build - Shift F7
goto definition - Shift F8
open spotlight - tap Cmd
tmux prefix / toggle eye mouse - Shift F10
toggle comment - Shift F11

```

## Kinesis

Press Pgrm 1 to activate Mac layout
Press Pgrm qwerty to activate the Windows layout

Note you should always leave the keyboard in 'Windows' mode as the bindings have been manually translated for Mac.

## Footpedal

The config for the footpedal is located under the windows/savant-elite2 folder.

- Left is Escape
- Middle is Left Click
- Right is Right Click

The method to open V-Drive is either:

- Flip the switch on the bottom of the pedal
- Hold the pedal down briefly while connecting to the computer (waterproof version)
