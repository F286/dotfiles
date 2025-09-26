-- Custom keymaps
-- Save file with <C-s> or, on macOS, <D-s>
local modes = { "n", "i", "x", "s" }

vim.keymap.set(modes, "<C-s>", function()
  vim.cmd("silent! write")
end, { desc = "Save file" })

if vim.fn.has("mac") == 1 then
  vim.keymap.set(modes, "<D-s>", function()
    vim.cmd("silent! write")
  end, { desc = "Save file" })
end

-- Toggle comment on current line with gc in normal mode
vim.keymap.set("n", "gc", "gcc", { remap = true, silent = true, desc = "Comment current line (gc)" })
