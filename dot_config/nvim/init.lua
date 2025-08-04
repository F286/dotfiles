-- Minimal Neovim config with Kanagawa theme
-- Relative line numbers, a non‑blinking orange cursor and a vertical bar in insert mode

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
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

-- Map <leader>1..9 to switch tabs
if vim.g.vscode then
  for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, function()
      vim.fn.VSCodeNotify("workbench.action.openEditorAtIndex" .. i)
    end, { desc = "Go to tab " .. i, silent = true })
  end
else
  for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, i .. "gt", {
      desc = "Go to tab " .. i,
      silent = true,
    })
  end
end
