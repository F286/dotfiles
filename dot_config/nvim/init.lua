-- Minimal Neovim config with Kanagawa theme
-- Relative line numbers and a non‑blinking orange cursor

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.guicursor:append("a:blinkon0")
vim.api.nvim_set_hl(0, "Cursor", { fg = "#FF5000", bg = "#000000" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"rebelot/kanagawa.nvim",
		config = function()
			vim.cmd("colorscheme kanagawa")
		end,
	},
	{ "tpope/vim-surround" },
})
