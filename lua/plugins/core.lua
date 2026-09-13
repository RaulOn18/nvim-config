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

  -- Inline diagnostics. Load before LSP attach so the first buffer is rendered too.
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = { "BufReadPre", "BufNewFile" },
    priority = 1000,
    opts = {
      preset = "modern",
      transparent_cursorline = true,
      options = {
        throttle = 100,
        enable_on_insert = false,
        enable_on_select = false,
        multilines = {
          enabled = true,
          always_show = false,
        },
        show_source = { enabled = false },
        show_related = { enabled = false },
      },
    },
    config = function(_, opts)
      require("tiny-inline-diagnostic").setup(opts)
      vim.diagnostic.config { virtual_text = false }
    end,
  },

  -- Workspace diagnostics are explicit-only to avoid an LSP attach burst.
  {
    "artemave/workspace-diagnostics.nvim",
    opts = {
      workspace_files = function()
        local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
        local files = vim.fn.systemlist { "git", "-C", root, "ls-files" }
        return vim.tbl_filter(
          function(path)
            return vim.fn.getfsize(path) <= 1048576
          end,
          vim.tbl_map(function(path)
            return vim.fs.joinpath(root, path)
          end, files)
        )
      end,
    },
    config = function(_, opts)
      require("workspace-diagnostics").setup(opts)
    end,
    keys = {
      {
        "<leader>wD",
        function()
          require("utils.workspace_diagnostics").open_list()
        end,
        desc = "Open workspace diagnostics",
      },
      {
        "<leader>wd",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_clients { bufnr = bufnr }
          if #clients == 0 then
            vim.notify("No active LSP client in this buffer", vim.log.levels.WARN)
            return
          end

          local root = vim.fs.root(bufnr, { ".git" }) or vim.fn.getcwd()
          if vim.g.workspace_diagnostics_root ~= root then
            package.loaded["workspace-diagnostics"] = nil
            vim.g.workspace_diagnostics_root = root
            require("workspace-diagnostics").setup {
              workspace_files = function()
                local files = vim.fn.systemlist { "git", "-C", root, "ls-files" }
                return vim.tbl_filter(
                  function(path)
                    return vim.fn.getfsize(path) <= 1048576
                  end,
                  vim.tbl_map(function(path)
                    return vim.fs.joinpath(root, path)
                  end, files)
                )
              end,
            }
          end

          local workspace = require "workspace-diagnostics"
          local diagnostic_clients = {
            clangd = true,
            eslint = true,
            gopls = true,
            sqlls = true,
            vtsls = true,
          }
          for _, client in ipairs(clients) do
            if diagnostic_clients[client.name] then
              if client:supports_method("workspace/diagnostic", bufnr) then
                vim.lsp.buf.workspace_diagnostics { client_id = client.id }
              else
                workspace.populate_workspace_diagnostics(client, bufnr)
              end
            end
          end

          vim.notify("Workspace diagnostics refreshed", vim.log.levels.INFO)
        end,
        desc = "Populate workspace diagnostics",
      },
    },
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
