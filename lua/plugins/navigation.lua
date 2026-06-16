-- Navigation and Search Plugins

return {
  -- File explorer: NvChad loads nvim-tree on cmd trigger
  -- Custom opts + keymaps
  {
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
      { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Find File in Tree" },
    },
    opts = {
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      filters = {
        dotfiles = false,
        custom = {},
      },
      filesystem_watchers = {
        enable = true,
        ignore_dirs = {
          ".next",
          "node_modules",
          ".wrangler",
          ".git",
          "dist",
          "build",
          "target",
        },
      },
      git = {
        enable = false,
        ignore = false,
      },
      view = {
        width = 30,
        side = "left",
        preserve_window_proportions = false,
      },
      renderer = {
        indent_width = 1,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      actions = {
        open_file = {
          window_picker = {
            enable = true,
          },
          resize_window = true,
        },
      },
    },
  },

  -- Fuzzy finder: fzf-lua (faster than telescope, uses native fzf binary)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find Files" },
      { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live Grep" },
      { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Find Buffers" },
      { "<leader>fh", function() require("fzf-lua").helptags() end, desc = "Find Help" },
      { "<leader>fo", function() require("fzf-lua").oldfiles() end, desc = "Recent Files" },
      { "<leader>fc", function() require("fzf-lua").grep_cword() end, desc = "Find String Under Cursor" },
      { "<leader>fr", function() require("fzf-lua").resume() end, desc = "Resume Last Search" },
      { "<leader>fk", function() require("fzf-lua").keymaps() end, desc = "Find Keymaps" },
      { "<leader>fC", function() require("fzf-lua").commands() end, desc = "Find Commands" },
      { "<leader>fz", function() require("fzf-lua").builtin() end, desc = "FzfLua Builtin" },
      { "<leader>fd", function() require("fzf-lua").diagnostics_workspace() end, desc = "Diagnostics" },
      { "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "Grep Word Under Cursor" },
      { "<leader>fW", function() require("fzf-lua").grep_cWORD() end, desc = "Grep WORD Under Cursor" },
    },
    ---@module "fzf-lua"
    ---@type fzf-lua.Config|{}
    ---@diagnostic disable: missing-fields
    opts = {
      "default-title",
      winopts = {
        height = 0.85,
        width = 0.87,
        preview = {
          layout = "vertical",
          vertical = "right:50%",
          scrollbar = "float",
        },
      },
      fzf_colors = true,
      fzf_opts = {
        ["--no-bold"] = true,
        ["--no-separator"] = true,
        ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
      },
      files = {
        cwd_prompt = false,
        file_ignore_patterns = { "node_modules", "%.git", "%.next", "dist", "build", "target", "%.lock" },
        fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude node_modules --exclude .next --exclude dist --exclude build --exclude target --max-depth 8",
        rg_opts = "--color=never --files --hidden --follow --glob '!.git' --glob '!node_modules' --glob '!.next' --glob '!dist' --glob '!build' --glob '!target'",
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns 200 --max-depth 6 -e",
        rg_glob = false,
      },
      previewers = {
        bat = { enabled = false },
        builtin = {
          syntax = true,
          syntax_limit_l = 500,
          syntax_limit_b = 1024 * 100,
        },
      },
      ui_select = true,
      lsp = {
        code_actions = { previewer = false },
      },
    },
    config = function(_, opts)
      require("fzf-lua").setup(opts)
    end,
  },

  -- Flash - navigasi cepat
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {},
    keys = {
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },

  -- Live grep and replace with ripgrep (async, non-blocking)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", function() require("grug-far").open({ transient = true }) end, mode = { "n", "v" }, desc = "Search and Replace" },
      { "<leader>sw", function() require("grug-far").open({ transient = true, prefills = { search = vim.fn.expand("<cword>") } }) end, mode = "n", desc = "Replace Word Under Cursor" },
    },
    opts = {
      engine = "ripgrep",
      transient = true,
      startInInsertMode = true,
      keymaps = {
        replace = { n = "<localleader>r" },
        qflist = { n = "<localleader>q" },
        syncLocations = { n = "<localleader>s" },
        close = { n = "<localleader>c" },
      },
    },
  },

  -- Diagnostics: use fzf-lua (faster, already loaded)
  -- <leader>xx and <leader>xb mapped in mappings.lua
}
