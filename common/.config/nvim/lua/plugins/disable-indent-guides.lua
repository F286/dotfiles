return {
  -- disable default indent guides
  {
    "folke/snacks.nvim",
    opts = { indent = { enabled = false } },
  },
  
  -- disable legacy indent plugins
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  { "nvim-mini/mini.indentscope", enabled = false },
}
