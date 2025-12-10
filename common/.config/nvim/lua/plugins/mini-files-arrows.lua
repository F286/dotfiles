-- mini-files-arrows.lua
-- Add left/right arrow key support to mini.files navigation

return {
  "mini/mini.files",
  config = function()
    local MiniFiles = require("mini.files")
    -- Add left/right arrow keymaps for navigation
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id
        -- Left arrow: go to parent directory (same as 'h')
        vim.keymap.set("n", "<Left>", function()
          MiniFiles.go_out()
        end, { buffer = buf_id, desc = "MiniFiles: Go left (parent dir)" })
        -- Right arrow: open directory or file (same as 'l' or 'j')
        vim.keymap.set("n", "<Right>", function()
          MiniFiles.go_in()
        end, { buffer = buf_id, desc = "MiniFiles: Go right (open)" })
      end,
    })
  end,
}
