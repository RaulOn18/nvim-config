return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = true,
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    init = function()
      local autocmd = vim.api.nvim_create_autocmd
      local augroup = vim.api.nvim_create_augroup
      local flutter_group = augroup("FlutterOptimizations", { clear = true })

      -- Flutter-specific keymaps
      autocmd("FileType", {
        group = flutter_group,
        pattern = "dart",
        callback = function(args)
          vim.keymap.set("n", "<leader>fe", function()
            vim.lsp.buf.code_action({
              filter = function(action)
                return action.title:match("Extract widget") or
                       action.title:match("Extract method")
              end,
              apply = true,
            })
          end, { buffer = args.buf, desc = "Flutter: Extract widget/method" })
          vim.keymap.set("n", "<leader>fx", function()
            vim.lsp.buf.code_action({
              filter = function(action)
                return action.isPreferred or action.kind == "quickfix"
              end,
              apply = true,
            })
          end, { buffer = args.buf, desc = "Flutter: Quick fix" })
        end,
      })
    end,
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
        -- widget_guides OFF: big perf win on large widget trees (was ON)
        widget_guides = { enabled = false },
        -- closing_tags OFF: visual cost, can re-enable if needed
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = ">",
          enabled = false,
        },
        lsp = {
          on_attach = function(client, bufnr)
            local lsp_on_attach = require "configs.on_attach"
            lsp_on_attach.on_attach(client, bufnr)

            local map = vim.keymap.set
            map("n", "<leader>Fr", "<cmd>FlutterRun<cr>", { desc = "Flutter Run", buffer = bufnr })
            map("n", "<leader>FR", "<cmd>FlutterRestart<cr>", { desc = "Flutter Restart", buffer = bufnr })
            map("n", "<leader>Fq", "<cmd>FlutterQuit<cr>", { desc = "Flutter Quit", buffer = bufnr })
            map("n", "<leader>Fc", "<cmd>FlutterReload<cr>", { desc = "Hot Reload", buffer = bufnr })
            map("n", "<leader>Ft", function()
              local commands = {
                "FlutterRun", "FlutterRestart", "FlutterReload", "FlutterQuit",
                "FlutterDetach", "FlutterEmulators", "FlutterDevices",
                "FlutterOutline", "FlutterDevTools", "FlutterCopyProfilerUrl",
                "FlutterPubGet", "FlutterPubUpgrade", "FlutterLspRestart",
                "FlutterSuperUpdateImports",
              }
              vim.ui.select(commands, { prompt = "Flutter Commands" }, function(choice)
                if choice then
                  vim.cmd(choice)
                end
              end)
            end, { desc = "Flutter Commands", buffer = bufnr })

            -- Force Enable Code Action Provider (ensure dart refactor actions show)
            if type(client.server_capabilities.codeActionProvider) ~= "table" then
              client.server_capabilities.codeActionProvider = {}
            end
          end,
          settings = {
            showTodos = false,
            completeFunctionCalls = false,  -- was true; saves time per completion
            renameFilesWithClasses = "prompt",
            updateImportsOnRename = true,
            analysisExcludedFolders = {
              vim.fn.expand "$HOME/.pub-cache",
              vim.fn.expand "$HOME/.flutter",
              project_root .. "/build",
              project_root .. "/.dart_tool",
              project_root .. "/ios/Pods",
              project_root .. "/android/.gradle",
              project_root .. "/.idea",
            },
          },
        },
      }

      -- NOTE: Flutter commands use vim.ui.select (backed by Telescope)
    end,
  },
}
