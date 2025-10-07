-- lua/plugins/diffview.lua
return {
  "sindrets/diffview.nvim",
  opts = {
    -- Use a two-panel side-by-side view for most diffs
    view = {
      default = {
        layout = "diff2_horizontal",
      },
      merge_tool = {
        layout = "diff3_horizontal",
      },
      file_history = {
        layout = "diff2_horizontal",
      },
    },
  },
}
