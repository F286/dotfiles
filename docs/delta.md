# Delta & Bat Theme Setup

These dotfiles ship a custom VS Code Tokyonight port for [`delta`](https://github.com/dandavison/delta) and [`bat`](https://github.com/sharkdp/bat) so your diffs match the tuned editor palette defined in `settings.json`.

## Theme installation

1. Install `bat` if you have not already (the `packages.txt` list includes `bat`).
2. Stow the `common` package from this repo so the theme is linked into `~/.config/bat/themes/` as `vscode-custom-tokyonight.tmTheme`.
3. Rebuild the bat theme cache so the new TextMate theme is recognized:
   ```bash
   bat cache --build
   ```

`delta` will automatically use the theme once the cache has been rebuilt because `~/.config/git/config` sets:

```ini
[delta]
    syntax-theme = "VS Code Tokyonight Custom"
```

You can preview the end result with:

```bash
delta --show-syntax-themes | less -R
```

If you need to fall back temporarily, comment out the custom value and re-enable the built-in theme noted in the config file.
