-- Core Development Tools
-- LSP, formatting, and syntax highlighting

return {
  -- Formatting dengan lazy loading yang lebih baik
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = require "configs.conform",
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = { "BufReadPost", "BufNewFile" },
    priority = 1000,
    config = function()
      -- Suppress deprecation warning from old lspconfig
      local orig = vim.notify
      vim.notify = function(msg, level, opts)
        if type(msg) == "string" and (msg:find("deprecated") or msg:find("lspconfig")) then
          return
        end
        orig(msg, level, opts)
      end
      
      -- Load our custom LSP config
      require "configs.lspconfig"
      
      vim.notify = orig
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
        debounce = 60,
        throttle = 30,
        fetching_timeout = 200,
        max_view_entries = 20,
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 3 },  -- Don't scan 1-2 char words
        { name = "nvim_lua" },
        { name = "async_path" },
      },
    },
  },

  -- Treesitter dengan optimizations
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- Ensure treesitter uses local compiler on Linux
      if vim.fn.has("unix") == 1 then
        require("nvim-treesitter.install").compilers = { "gcc", "cc", "clang" }
        vim.env.CC = "gcc"
      end

      require("nvim-treesitter.config").setup {
        install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site'),
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = false },  -- Disable for performance
      }

      -- Ensure parsers are installed (async, non-blocking)
      vim.schedule(function()
        local parsers = {
          "vim", "lua", "vimdoc",
          "html", "css", "tsx", "typescript",
          "javascript", "json", "markdown", "markdown_inline",
          "dart", "go", "sql",
        }

        for _, parser in ipairs(parsers) do
          if not pcall(vim.treesitter.language.inspect, parser) then
            pcall(function()
               require('nvim-treesitter.install').install(parser)
            end)
          end
        end
      end)
    end,
  },
}
