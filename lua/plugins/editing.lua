-- Editing Enhancement Plugins

return {
  -- Better surround
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add,             desc = "Add Surrounding",             mode = { "n", "v" } },
        { opts.mappings.delete,          desc = "Delete Surrounding" },
        { opts.mappings.find,            desc = "Find Surrounding" },
        { opts.mappings.find_left,       desc = "Find Surrounding (left)" },
        { opts.mappings.highlight,       desc = "Highlight Surrounding" },
        { opts.mappings.replace,         desc = "Replace Surrounding" },
        { opts.mappings.update_n_lines,  desc = "Update `MiniSurround.config.n_lines`" },
      }
      return vim.list_extend(
        vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings),
        keys
      )
    end,
    opts = {
      mappings = {
        add = "gsa", delete = "gsd", find = "gsf", find_left = "gsF",
        highlight = "gsh", replace = "gsr", update_n_lines = "gsn",
      },
    },
  },

  -- Better comments
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
  },

  -- Snippets (NvChad already loads LuaSnip via nvim-cmp)
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
    event = "InsertEnter",
  },

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "markdown.mdx" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      code = { sign = false, width = "block", right_pad = 1 },
      heading = { sign = false, icons = {} },
    },
    config = function(_, opts) require("render-markdown").setup(opts) end,
  },
}
