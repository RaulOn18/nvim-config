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
      patterns = { ".git", "package.json", "tsconfig.json", "Cargo.toml", "go.mod", ">_Makefile",
                   "build.gradle.kts", "build.gradle", "settings.gradle.kts", "settings.gradle",
                   "compile_commands.json", "CMakeLists.txt", "meson.build" },
      ignore_lsp = {},
      exclude_dirs = { "~/", "/tmp", "node_modules", ".git", "build", ".gradle", ".idea" },
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = "global",
      datapath = vim.fn.stdpath "data",
    },
    config = function(_, opts) require("project_nvim").setup(opts) end,
  },

  -- Which-key: NvChad loads it on keys/cmd trigger
  {
    "folke/which-key.nvim",
    opts = {
      plugins = { spelling = true },
      spec = {
        {
          mode = { "n", "v" },
          { "g",                group = "goto" },
          { "gs",               group = "surround" },
          { "]",                group = "next" },
          { "[",                group = "prev" },
          { "<leader><tab>",    group = "tabs" },
          { "<leader>b",        group = "buffer" },
          { "<leader>c",        group = "code" },
          { "<leader>f",        group = "file/find" },
          { "<leader>g",        group = "git" },
          { "<leader>q",        group = "quit/session" },
          { "<leader>s",        group = "search" },
          { "<leader>sr",       group = "replace (grug-far)" },
          { "<leader>a",        group = "AI (Augment)" },
          { "<leader>d",        group = "Debug (DAP)" },
          { "<leader>h",        group = "Git Hunks" },
          { "<leader>K",        group = "Kotlin/Gradle" },
          { "<leader>r",        group = "Run/Build" },
        },
      },
    },
  },
}
