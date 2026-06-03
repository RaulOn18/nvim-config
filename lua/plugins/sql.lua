-- SQL Editor Plugins
return {
  -- Database client
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },

  -- UI for vim-dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    dependencies = {
      "tpope/vim-dadbod",
    },
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB Buffer" },
      { "<leader>Dr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename DB Buffer" },
      { "<leader>Dq", "<cmd>DBUILastQueryInfo<cr>", desc = "Last Query Info" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 35
      vim.g.db_ui_auto_execute_table_helpers = 1
    end,
  },

  -- SQL completion
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = {
      "tpope/vim-dadbod",
      "hrsh7th/nvim-cmp",
    },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      -- Setup cmp untuk SQL dengan sumber yang lebih lengkap
      local cmp = require("cmp")
      
      -- Setup buffer-specific completion untuk SQL
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          cmp.setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" }, -- Schema-aware (butuh koneksi DB)
              { name = "buffer" },                -- Keyword dari buffer
              { name = "path" },                  -- Path completion
            },
          })
        end,
      })
    end,
  },



  -- SQL Treesitter untuk syntax highlighting yang lebih baik (handled by core.lua)
  -- No need to duplicate treesitter config here

  -- SQL formatter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sql = { "sql_formatter" },
      },
      formatters = {
        sql_formatter = {
          args = { "--language", "sql" },
        },
      },
    },
  },
}
