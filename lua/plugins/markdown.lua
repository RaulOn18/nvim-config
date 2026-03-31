return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "markdown.mdx" },
  dependencies = { 
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.nvim", -- atau "nvim-tree/nvim-web-devicons" jika prefer yang itu
  },
  opts = {
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
    heading = {
      sign = false,
      icons = {},
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
  end,
}
