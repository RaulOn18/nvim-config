-- Flutter (flutter-tools.nvim): commands picker, is_flutter_project guard,
-- codeActionProvider dance. flutter_tools_log_level / flutter_show_log_on_run
-- moved here from options.lua.

vim.g.flutter_tools_log_level = "WARN"
vim.g.flutter_show_log_on_run = "error"

local function is_flutter_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 1
end

return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = true,
    ft = "dart",
    dependencies = { "nvim-lua/plenary.nvim" },
    commands = {
      "FlutterRun", "FlutterRunDebug", "FlutterRestart", "FlutterReload", "FlutterQuit",
      "FlutterDevices", "FlutterEmulators", "FlutterVisualDebug", "FlutterOpenDevLog",
      "FlutterOpenTimeline", "FlutterOutlineOpen", "FlutterOutlineClose",
      "FlutterOutlineToggle", "FlutterGetPackages",
    },
    init = function()
      local autocmd = vim.api.nvim_create_autocmd
      local augroup = vim.api.nvim_create_augroup("FlutterKeymaps", { clear = true })

      -- Dart extract widget/method + quick fix (guarded by is_flutter_project)
      autocmd("FileType", {
        group = augroup,
        pattern = "dart",
        callback = function(args)
          if not is_flutter_project() then return end
          vim.keymap.set("n", "<leader>fe", function()
            vim.lsp.buf.code_action {
              filter = function(a) return a.title:match "Extract" end,
              apply = true,
            }
          end, { buffer = args.buf, desc = "Flutter: Extract" })

          vim.keymap.set("n", "<leader>fx", function()
            vim.lsp.buf.code_action {
              filter = function(a) return a.isPreferred or a.kind == "quickfix" end,
              apply = true,
            }
          end, { buffer = args.buf, desc = "Flutter: Quick fix" })
        end,
      })
    end,
    config = function()
      local project_root = vim.fn.getcwd()

      require("flutter-tools").setup {
        ui = { border = "rounded", notification_style = "native" },
        decorations = {
          statusline = { app_version = true, device = true, project_config = true },
        },
        debugger = {
          enabled = true,
          run_via_dap = false,
          register_configurations = function(_)
            require("dap").configurations.dart = {}
            require("dap.ext.vscode").load_launchjs()
          end,
        },
        widget_guides = { enabled = false },
        closing_tags = { enabled = false },
        lsp = {
          on_attach = function(client, bufnr)
            require("configs.on_attach").on_attach(client, bufnr)
            -- Disable unwanted code action kinds (Flutter LSP advertises them but
            -- they don't work well without a Flutter context)
            if client.name == "dartls" then
              client.server_capabilities.codeActionProvider = { codeActionKinds = {} }
            end
            local map = vim.keymap.set
            map("n", "<leader>Fr", "<cmd>FlutterRun<cr>",     { desc = "Flutter Run",     buffer = bufnr })
            map("n", "<leader>FR", "<cmd>FlutterRestart<cr>",  { desc = "Flutter Restart", buffer = bufnr })
            map("n", "<leader>Fq", "<cmd>FlutterQuit<cr>",     { desc = "Flutter Quit",    buffer = bufnr })
            map("n", "<leader>Fc", "<cmd>FlutterReload<cr>",   { desc = "Hot Reload",      buffer = bufnr })
          end,
          settings = {
            showTodos = false,
            completeFunctionCalls = false,
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
    end,
  },
}
