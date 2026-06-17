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
      update_focused_file = { enable = true, update_root = false },
      filters = { dotfiles = false, custom = {} },
      filesystem_watchers = {
        enable = true,
        ignore_dirs = {
          ".next", "node_modules", ".wrangler", ".git", "dist", "build", "target",
        },
      },
      view = { width = 30, side = "left", preserve_window_proportions = false },
      renderer = {
        indent_width = 1,
        icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
      },
      actions = { open_file = { window_picker = { enable = true }, resize_window = true } },
    },
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      require("telescope").setup {
        defaults = {
          path_display = { "truncate" },
          file_ignore_patterns = {
            "node_modules", "%.git", "%.next", "dist", "build", "target", "%.lock",
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
