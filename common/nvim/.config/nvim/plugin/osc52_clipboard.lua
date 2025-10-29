-- Configure Neovim to use the built-in OSC 52 clipboard integration when available.
local ok, osc52 = pcall(require, 'vim.ui.clipboard.osc52')
if not ok then
  return
end

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = osc52.copy('+'),
    ['*'] = osc52.copy('*'),
  },
}

vim.opt.clipboard:prepend('unnamedplus')
