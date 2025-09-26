return {
  -- Install & configure tokyonight and pin style to "moon"
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
  -- Tell LazyVim to load tokyonight
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },
}

