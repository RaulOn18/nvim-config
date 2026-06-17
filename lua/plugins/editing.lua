-- Editing Enhancement Plugins

return {
  -- Better surround
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "gsa", delete = "gsd", find = "gsf", find_left = "gsF",
        highlight = "gsh", replace = "gsr", update_n_lines = "gsn",
      },
    },
    keys = {
      { "gsa", desc = "Add Surrounding", mode = { "n", "v" } },
      { "gsd", desc = "Delete Surrounding" },
      { "gsf", desc = "Find Surrounding" },
      { "gsF", desc = "Find Surrounding (left)" },
      { "gsh", desc = "Highlight Surrounding" },
      { "gsr", desc = "Replace Surrounding" },
      { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
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
