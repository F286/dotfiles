# TokyoNight-ish fzf with LazyVim/Telescope-like dropdown UX
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
  --layout=reverse
  --height=60%
  --border=rounded
  --margin=1,3
  --info=inline
  --no-separator
  --ansi
  --pointer='❯'
  --marker='✓'
  --tiebreak=index
  --bind=ctrl-j:down,ctrl-k:up,alt-j:down,alt-k:up,ctrl-u:half-page-up,ctrl-d:half-page-down,alt-p:toggle-preview
  # left-list highlight colors (query match)
  --color=fg:#c0caf5,bg:#1a1b26,fg+:#c0caf5,bg+:#24283b
  --color=hl:#ff9e64,hl+:#ff9e64
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#ff9e64,marker:#9ece6a,spinner:#bb9af7,header:#565f89,border:#3b4261
"

