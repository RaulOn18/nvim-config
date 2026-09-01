-- Core Development Tools
-- LSP, formatting, syntax highlighting, LSP server install

return {
  -- Mason: single entry covers every server ensure_installed in this config
  {
    "williamboman/mason.nvim",
    lazy = true,
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- JS/TS
        "vtsls",
        "typescript-language-server",
        "vscode-eslint-language-server",
        "tailwindcss-language-server",
        "prettierd",
        -- Go
        "gopls",
        "gofumpt",
        "goimports",
        "delve",
        -- Web
        "vscode-html-language-server",
        "vscode-css-language-server",
        "sql-language-server",
        "dart-format",
        "sql-formatter",
        -- C/C++
        "clangd",
        "clang-format",
        -- Kotlin / Android
        "ktfmt",
        -- Debug
        "js-debug-adapter",
        "codelldb",
      },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup(require "configs.conform")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    priority = 1000,
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- LSP Progress Indicator
  { "j-hui/fidget.nvim", event = "LspAttach" },

  -- Treesitter. Run :TSInstall <lang> for missing parsers; `:TSUpdate` runs on plugin update.
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    opts = { ensure_installed = { "kotlin", "java", "query", "vim", "vimdoc", "lua", "bash", "json", "yaml" } },
  },

  -- Show the current function/class header while scrolling.
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSContext", "TSContextEnable", "TSContextDisable", "TSContextToggle" },
    keys = {
      { "<leader>ut", "<cmd>TSContextToggle<cr>", desc = "Toggle Treesitter Context" },
    },
    opts = {
      -- Keep the overlay small: enough context without stealing editor space.
      max_lines = 3,
      min_window_height = 20,
      multiline_threshold = 3,
      mode = "cursor",
      trim_scope = "outer",
      line_numbers = false,
      multiwindow = false,
      separator = nil,
    },
  },
}
