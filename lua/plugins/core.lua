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
        "vtsls", "typescript-language-server", "vscode-eslint-language-server",
        "tailwindcss-language-server",
        -- Go
        "gopls", "gofumpt", "goimports", "delve",
        -- Web
        "vscode-html-language-server", "vscode-css-language-server",
        "sql-language-server", "dart-format", "sql-formatter",
        -- C/C++
        "clangd", "clang-format",
        -- Kotlin / Android
        "kotlin-lsp", "kotlin-debug-adapter", "ktfmt",
        -- Debug
        "js-debug-adapter", "chrome-debug-adapter", "codelldb",
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
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },

  -- CMP performance override (NvChad loads nvim-cmp on InsertEnter)
  {
    "hrsh7th/nvim-cmp",
    opts = {
      performance = {
        debounce = 120,        -- Wait 120ms before triggering (reduce LSP spam)
        throttle = 60,         -- Max once per 60ms (smoother)
        fetching_timeout = 400, -- Give LSP 400ms to respond
        max_view_entries = 15, -- Fewer entries = faster render
      },
      completion = {
        keyword_length = 3,    -- Trigger after 3 chars (less LSP spam)
        autocomplete = { "InsertEnter", "TextChanged" },  -- Not on every keystroke
      },
      sources = {
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        -- async_path disabled for performance; uncomment if you need path completion
        -- { name = "async_path", priority = 500 },
        -- buffer source: only in non-LSP files to reduce noise
        { name = "buffer", keyword_length = 3, priority = 250,
          option = {
            get_bufnrs = function()
              -- Only current buffer, not all loaded buffers
              return { vim.api.nvim_get_current_buf() }
            end,
          },
        },
        -- nvim_lua: only enable in lua files
        { name = "nvim_lua", priority = 100 },
      },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- Ensure treesitter uses local compiler on Linux
      if vim.fn.has("unix") == 1 then
        require("nvim-treesitter.install").compilers = { "gcc", "cc", "clang" }
        vim.env.CC = "gcc"
      end

      require("nvim-treesitter.config").setup {
        install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
        highlight = { enable = true },
        -- indent disabled for performance; use built-in indenting instead
        indent = { enable = false },
        incremental_selection = { enable = false },
      }

      -- Auto-install missing parsers (async, non-blocking)
      local parsers = {
        "vim", "lua", "vimdoc",
        "html", "css", "tsx", "typescript", "javascript", "json",
        "markdown", "markdown_inline",
        "dart", "go", "sql", "kotlin", "c", "cpp",
      }
      vim.schedule(function()
        for _, parser in ipairs(parsers) do
          if not pcall(vim.treesitter.language.inspect, parser) then
            pcall(require("nvim-treesitter.install").install, parser)
          end
        end
      end)
    end,
  },
}
