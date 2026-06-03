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

  -- Treesitter dengan optimizations
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
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
