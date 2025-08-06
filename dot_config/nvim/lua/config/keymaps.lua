-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { silent = true, desc = "Save file" }

-- Ctrl-S to save silently
vim.keymap.set({ "n", "v", "x", "s" }, "<C-s>", "<cmd>silent! w<CR>", opts)
vim.keymap.set("i", "<C-s>", "<Esc><cmd>silent! w<CR>gi", opts)

-- Command-S on macOS to save silently
vim.keymap.set({ "n", "v", "x", "s" }, "<D-s>", "<cmd>silent! w<CR>", opts)
vim.keymap.set("i", "<D-s>", "<Esc><cmd>silent! w<CR>gi", opts)
