return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      local function is_flutter_project()
        return vim.fn.findfile("pubspec.yaml", vim.fn.getcwd() .. ";") ~= ""
      end

      if not is_flutter_project() then
        return
      end

      local project_root = vim.fn.getcwd()

      require("flutter-tools").setup {
        ui = {
          border = "rounded",
          notification_style = "native",
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
            project_config = true,
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = false,
          register_configurations = function(_)
            require("dap").configurations.dart = {}
            require("dap.ext.vscode").load_launchjs()
          end,
        },
        widget_guides = { enabled = true },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = ">",
          enabled = true,
        },
        lsp = {
          color = {
            enabled = true,
            virtual_text = true,
            virtual_text_str = "■",
          },
          on_attach = function(client, bufnr)
            -- NvChad on_attach integration
            local ok_nvchad, nvconfig = pcall(require, "nvchad.configs.lspconfig")
            if ok_nvchad then
              nvconfig.on_attach(client, bufnr)
            end

            local opts = { buffer = bufnr, silent = true }
            
            -- Flutter Specific Keymaps
            local map = vim.keymap.set
            map("n", "<leader>Fr", "<cmd>FlutterRun<cr>", { desc = "Flutter Run", buffer = bufnr })
            map("n", "<leader>FR", "<cmd>FlutterRestart<cr>", { desc = "Flutter Restart", buffer = bufnr })
            map("n", "<leader>Fq", "<cmd>FlutterQuit<cr>", { desc = "Flutter Quit", buffer = bufnr })
            map("n", "<leader>Fc", "<cmd>FlutterReload<cr>", { desc = "Hot Reload", buffer = bufnr })
            map("n", "<leader>Ft", "<cmd>Telescope flutter commands<cr>", { desc = "Flutter Commands", buffer = bufnr })

            -- Force Enable Code Action Provider
            client.server_capabilities.codeActionProvider = true
          end,
          settings = {
            showTodos = false,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            updateImportsOnRename = true,
            analysisExcludedFolders = {
              vim.fn.expand "$HOME/.pub-cache",
              vim.fn.expand "$HOME/.flutter",
              project_root .. "/build",
              project_root .. "/.dart_tool",
            },
          },
        },
      }

      -- Load Telescope Extension
      local ok, telescope = pcall(require, "telescope")
      if ok then telescope.load_extension "flutter" end
    end,
  },

  -- Lightbulb for Code Actions
  {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = true },
    },
  },

  -- Action Preview UI
  {
    "aznhe21/actions-preview.nvim",
    keys = {
      { "<leader>ca", function() require("actions-preview").code_actions() end, desc = "Code Action (Preview)", mode = { "n", "v" } },
    },
  },
}
