-- IDE Features: Project Management, UI, and Workflow

return {
  -- Project management
  {
    "ahmedkhalf/project.nvim",
    lazy = true,
    event = "VeryLazy",
    priority = 900,
    opts = {
      manual_mode = true,
      detection_methods = { "pattern" },
      patterns = { ".git", "package.json", "tsconfig.json", "Cargo.toml", "go.mod", ">_Makefile" },
      ignore_lsp = {},
      exclude_dirs = { "~/", "/tmp", "node_modules", ".git" },
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = "global",
      datapath = vim.fn.stdpath("data"),
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      
      local telescope_ok, telescope = pcall(require, "telescope")
      if telescope_ok then
        telescope.load_extension("projects")
      end
    end,
  },

  -- Which-key: NvChad loads it on keys/cmd trigger
  -- Custom group specs go in which-key opts override
  {
    "folke/which-key.nvim",
    opts = {
      plugins = { spelling = true },
      spec = {
        {
          mode = { "n", "v" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "]", group = "next" },
          { "[", group = "prev" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>b", group = "buffer" },
          { "<leader>c", group = "code" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>sr", group = "replace (grug-far)" },
          { "<leader>a", group = "AI (Augment)" },
          { "<leader>d", group = "Debug (DAP)" },
          { "<leader>h", group = "Git Hunks" },
        },
      },
    },
  },

  -- Indent blankline: NvChad loads it on User FilePost
  -- No need to duplicate here

  -- Better folding (lazy load - only when fold commands used)
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
      close_fold_kinds_for_ft = {
        default = { "imports", "comment" },
      },
      preview = {
        win_config = {
          border = "rounded",
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
      },
    },
    config = function(_, opts)
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      require("ufo").setup(opts)
    end,
  },
}
