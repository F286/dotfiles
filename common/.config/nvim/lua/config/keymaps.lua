local map = vim.keymap.set
local print_keys = require("config.print_keys")

-- Use screen-line motions for arrow keys in Normal, Visual & Operator-Pending modes
for _, mode in ipairs({ "n", "v", "o" }) do
  map(mode, "<Up>", "gk", { noremap = true, desc = "Move up screen-line" })
  map(mode, "<Down>", "gj", { noremap = true, desc = "Move down screen-line" })
end

-- And in Insert mode, use <C-o> to invoke a single Normal-mode command
map("i", "<Up>", "<C-o>gk", { noremap = true, desc = "Move up screen-line (insert)" })
map("i", "<Down>", "<C-o>gj", { noremap = true, desc = "Move down screen-line (insert)" })

vim.keymap.set("n", "<C-u>", "16k", { noremap = true, desc = "Scroll Up 16 lines" })
vim.keymap.set("n", "<C-d>", "16j", { noremap = true, desc = "Scroll Down 16 lines" })

-- Enter block visual mode with <leader>v
vim.keymap.set("n", "<leader>v", "<C-v>", { noremap = true, desc = "Block Visual Mode" })

-- Redo with Shift+U, matching redo keybindings from other editors
map("n", "U", "<C-r>", { desc = "Redo" })

-- disable horizontal scroll with mouse/trackpad
for _, mode in ipairs({ "n", "i", "v", "o", "t" }) do
  map(mode, "<ScrollWheelLeft>", "<Nop>", { silent = true, desc = "Disable ← scroll" })
  map(mode, "<ScrollWheelRight>", "<Nop>", { silent = true, desc = "Disable → scroll" })
end

--------------------------------------------------------------------------
-- Shift+Function key helpers -------------------------------------------
--------------------------------------------------------------------------

---Map a command to both <S-Fn> and <F(n+12)> so the binding works across
---different terminal/OS combinations.
---@param n integer Function key number (1..12)
---@param rhs string|function Command or callback
---@param opts table|nil Additional options for `vim.keymap.set`
local function map_shift_f(n, rhs, opts)
  opts = opts or {}
  local modes = opts.mode or "n"
  opts.mode = nil
  map(modes, "<S-F" .. n .. ">", rhs, opts)
  map(modes, "<F" .. (n + 12) .. ">", rhs, opts)
end

-- TODO: Use the vim.keymap.set style remap for all of these instead of this function call style

-- Scroll up/down 16 lines
map_shift_f(4, "<C-u>", { desc = "Scroll Up 16 lines", noremap = true })
map_shift_f(4, "<C-o><C-u>", { mode = "i", desc = "Scroll Up 16 lines", noremap = true })
map_shift_f(6, "<C-d>", { desc = "Scroll Down 16 lines", noremap = true })
map_shift_f(6, "<C-o><C-d>", { mode = "i", desc = "Scroll Down 16 lines", noremap = true })

-- Stop current build
map_shift_f(7, "<cmd>CMakeStop<CR>", { mode = { "n", "i" }, desc = "Stop Build" })

-- Go to LSP definition
map_shift_f(8, vim.lsp.buf.definition, { mode = { "n", "i" }, desc = "Goto Definition" })

-- Leader-based toggle for key print debugging
vim.keymap.set("n", "<leader>uk", print_keys.toggle, {
  desc = "Toggle Key Print",
})

map_shift_f(11, "gcc", { remap = true, silent = true, desc = "Toggle Comment (line)" })
map_shift_f(11, "<C-o>gcc", { mode = "i", remap = true, silent = true, desc = "Toggle Comment (line)" })

map_shift_f(11, "gc", { mode = "x", remap = true, silent = true, desc = "Toggle Comment (block)" })

-- Reload the current buffer, smart-handling Lua files
vim.keymap.set("n", "zl", function()
  if vim.bo.filetype == "lua" then
    vim.cmd("luafile %") -- executes Lua buffers correctly
  else
    vim.cmd("source %") -- everything else
  end
end, { desc = "Source current file" })

-- Reload the entire Neovim configuration and plugins
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd("source $MYVIMRC")
  vim.cmd("Lazy sync")
end, { desc = "Reload config" })

--------------------------------------------------------------------------
-- Map normal shortcut (used by macros to NVim) -----------------------------------------------------
--------------------------------------------------------------------------

-- Save file with Ctrl+S in normal and insert mode
map({ "n", "i" }, "<D-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Same action via Shift+F5 (sent by kitty Cmd+S)
map_shift_f(5, "<cmd>w<CR>", { mode = { "n", "i" }, desc = "Save file" })

-- Toggle between source and header files (requires clangd)
map("n", "<A-o>", "<cmd>ClangdSwitchSourceHeader<CR>", { desc = "Switch header/source" })

-- Navigate jump list with Alt+Left/Right
map("n", "<D-Left>", "<C-o>", { desc = "Jump backward" })
map("n", "<D-Right>", "<C-i>", { desc = "Jump forward" })

-- macOS clipboard shortcuts
map("v", "<D-c>", '"+y', { desc = "Copy selection" })
map("v", "<D-x>", '"+d', { desc = "Cut selection" })
map("n", "<D-v>", '"+p', { desc = "Paste" })
map("v", "<D-v>", '"+p', { desc = "Paste over selection" })
map("i", "<D-v>", "<C-r>+", { desc = "Paste" })
map("n", "<D-a>", "ggVG", { desc = "Select all" })

pcall(vim.keymap.del, "n", "<S-h>")
pcall(vim.keymap.del, "n", "<S-l>")

-- These are commented out for now as they are not working. Maybe kitty on Mac does not pick up the event?
-- Next buffer: Cmd+Shift+]
map("n", "<D-S-]>", ":bnext<CR>", { desc = "Next buffer" })
-- Previous buffer: Cmd+Shift+[
map("n", "<D-S-[>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Same actions via Shift+F12/F13 (sent by kitty Cmd+Shift+] and [)
map_shift_f(1, "<cmd>bprevious<CR>", { mode = { "n", "i" }, desc = "Previous buffer" })
map_shift_f(12, "<cmd>bnext<CR>", { mode = { "n", "i" }, desc = "Next buffer" })

-- Open new tab
map("n", "<leader>bn", "<cmd>tabnew<CR>", { desc = "New tab" })

-- Move tab left/right
map("n", "<leader>bh", "<cmd>tabmove -1<CR>", { desc = "Move tab left" })
map("n", "<leader>bl", "<cmd>tabmove +1<CR>", { desc = "Move tab right" })

-- Jump to tab by number
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>tabnext " .. i .. "<CR>", {
    desc = "Go to tab " .. i,
  })
end
map("n", "<leader>0", "<cmd>tablast<CR>", { desc = "Go to last tab" })

-- Indent with Tab and unindent with Shift+Tab
map("n", "<Tab>", ">>", { desc = "Indent line" })
map("n", "<S-Tab>", "<<", { desc = "Unindent line" })
map("v", "<Tab>", ">gv", { desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })

vim.keymap.set({ "n", "v" }, "<leader>e", function()
  if vim.fn.exists(":Yazi") == 2 then
    vim.cmd("Yazi")
  elseif vim.fn.exists(":Lf") == 2 then
    vim.cmd("Lf")
  else
    local ok, mini = pcall(require, "mini.files")
    if ok and mini then
      mini.open()
    else
      vim.cmd("NvimTreeToggle")
    end
  end
end, { silent = true, desc = "File manager (Yazi/lf/mini.files/nvim-tree)" })

-- Move selection up / down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

map({ "n", "v" }, "<leader>fl", function()
  local p = vim.fn.expand("%:p")
  if p == "" then
    return vim.notify("No file", vim.log.levels.WARN)
  end
  vim.fn.setreg("+", p)
  vim.notify("Copied path: " .. p)
end, { desc = "Copy path of active file" })