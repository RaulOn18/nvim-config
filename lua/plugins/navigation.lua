-- Navigation and Search Plugins

return {
  -- File explorer: NvChad loads nvim-tree on cmd trigger
  {
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<C-n>",     "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
      { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Find File in Tree" },
    },
    opts = {
      on_attach = function(bufnr)
        local api = require "nvim-tree.api"
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts "Copy Absolute Path")
      end,
      update_focused_file = { enable = true, update_root = false },
      filters = { dotfiles = false, custom = {} },
      -- ponytail: external tools (pi agents, bun, tsc) hammer FS events in this stack.
      -- Auto-disable-on-threshold spams errors + lags the tree; press 'r' to refresh manually.
      filesystem_watchers = { enable = false },
      view = { width = 30, side = "left", preserve_window_proportions = false },
      renderer = {
        indent_width = 1,
        icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
      },
      actions = { open_file = { window_picker = { enable = true }, resize_window = true } },
    },
  },

  -- Telescope: lazy-load on first `:Telescope` command (NvChad default).
  -- Eager `VimEnter` was paying the cost on every startup, even on days you never opened Telescope.
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"

      -- ponytail: Windows [id] / (main) routes: normalize separators before :edit.
      local function open_selected(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry then return end
        actions.close(prompt_bufnr)
        local path = entry.path or entry.value
        vim.cmd("edit " .. vim.fn.fnameescape((path:gsub("\\", "/"))))
        local row, col = entry.row or entry.lnum, entry.col
        if row then vim.api.nvim_win_set_cursor(0, { row, col or 1 }) end
      end

      require("telescope").setup {
        defaults = {
          path_display = { "truncate" },
          file_ignore_patterns = {
            "node_modules", "%.git", "%.next", "dist", "build", "target", "%.lock", "graphify%-out[\\/]cache",
          },
          mappings = {
            i = { ["<CR>"] = open_selected },
          },
        },
      }
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- Flash: fast navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    keys = {
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end,     desc = "Flash" },
      { "S",  mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r",  mode = "o",              function() require("flash").remote() end,    desc = "Remote Flash" },
    },
  },

  -- Search and replace (ripgrep, async)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", function() require("grug-far").open { transient = true } end, mode = { "n", "v" }, desc = "Search and Replace" },
      { "<leader>sw", function() require("grug-far").open { transient = true, prefills = { search = vim.fn.expand "<cword>" } } end, mode = "n", desc = "Replace Word Under Cursor" },
    },
    opts = {
      engine = "ripgrep",
      transient = true,
      startInInsertMode = true,
      keymaps = {
        replace        = { n = "<localleader>r" },
        qflist         = { n = "<localleader>q" },
        syncLocations  = { n = "<localleader>s" },
        close          = { n = "<localleader>c" },
      },
    },
  },
}
