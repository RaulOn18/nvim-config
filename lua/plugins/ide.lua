-- IDE Features: Project Management, UI, and Workflow

return {
  -- Project management
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
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
      
      local ok, project = pcall(require, "project_nvim.project")
      if ok then
        vim.api.nvim_clear_autocmds({ group = "project_nvim" })
        
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "*",
          group = vim.api.nvim_create_augroup("ProjectNvimSafe", { clear = true }),
          callback = function(args)
            local buf = args.buf
            local bufname = vim.api.nvim_buf_get_name(buf)
            
            if bufname == "" then
              return
            end
            
            if bufname:match("^%w+://") then
              return
            end
            
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
            if buftype ~= "" then
              return
            end
            
            pcall(project.on_buf_enter)
          end,
        })
      end
    end,
  },

  -- Which-key untuk discoverability
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
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
    config = function(_, opts)
      require("which-key").setup(opts)
    end,
  },

  -- Indent blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
    main = "ibl",
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
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
