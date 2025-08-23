-- dot_config/nvim/lua/plugins/snacks-picker.lua
return {
  {
    "folke/snacks.nvim",
    -- If you're not enabling via :LazyExtras, keep picker enabled
    opts = function(_, opts)
      opts = opts or {}
      opts.picker = opts.picker or {}

      -- Default behavior: DO NOT include hidden or ignored files.
      -- (You can still toggle them on per session with the keymaps below.)
      opts.picker.sources = vim.tbl_deep_extend("force", {
        files = { hidden = false, ignored = false, follow = false },
        grep  = { hidden = false, ignored = false, follow = false },
      }, opts.picker.sources or {})

      -- Custom actions to flip flags and refetch results.
      opts.picker.actions = vim.tbl_deep_extend("force", {
        ---@param p snacks.Picker
        toggle_hidden = function(p)
          p.opts.hidden = not p.opts.hidden
          p:find()
        end,
        ---@param p snacks.Picker
        toggle_ignored = function(p)
          p.opts.ignored = not p.opts.ignored
          p:find()
        end,
      }, opts.picker.actions or {})

      -- Map ⌘/Alt-H and ⌘/Alt-I inside the picker (insert & normal in the input).
      -- Also try ⌘/Command-H and ⌘/Command-I (works only if your terminal/GUI passes these through).
      opts.picker.win = opts.picker.win or {}
      opts.picker.win.input = opts.picker.win.input or {}
      opts.picker.win.input.keys = vim.tbl_deep_extend("force", {
        ["<a-h>"] = { "toggle_hidden",  mode = { "i", "n" } },
        ["<a-i>"] = { "toggle_ignored", mode = { "i", "n" } },

        -- macOS / GUIs: Command is OS-reserved in many terminals (Cmd-H hides the app).
        -- If your terminal / GUI allows, these will call the same actions:
        ["<d-h>"] = { "toggle_hidden",  mode = { "i", "n" } },
        ["<d-i>"] = { "toggle_ignored", mode = { "i", "n" } },
      }, (opts.picker.win.input.keys or {}))

      return opts
    end,

    -- Optional: if you want the leader mappings pointing to Snacks "smart" files/grep
    -- identical to LazyVim's Snacks extra:
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>ff",      function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>/",       function() Snacks.picker.grep() end,  desc = "Grep" },
      { "<leader>sg",      function() Snacks.picker.grep() end,  desc = "Grep" },
    },
  },
}
