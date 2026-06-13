-- Core Development Tools
-- LSP, formatting, and syntax highlighting

return {
  -- Formatting dengan lazy loading yang lebih baik
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup(require "configs.conform")
    end,
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
        debounce = 120,        -- Wait 120ms before triggering (reduce LSP spam)
        throttle = 60,         -- Max once per 60ms (smoother)
        fetching_timeout = 400, -- Give LSP 400ms to respond
        max_view_entries = 15, -- Fewer entries = faster render
      },
      completion = {
        keyword_length = 2,    -- Trigger after 2 chars (less noise)
        autocomplete = { "InsertEnter", "TextChanged" },  -- Not on every keystroke
      },
      sources = {
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "async_path", priority = 500 },
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
          "kotlin",
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
