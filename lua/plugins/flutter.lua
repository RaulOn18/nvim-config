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

      -- build/cache folders handled globally by autocmds.lua

      -- Set filetype untuk pubspec.yaml biar ada highlighting
      autocmd({ "BufRead", "BufNewFile" }, {
        group = flutter_group,
        pattern = "pubspec.yaml",
        callback = function()
          vim.opt_local.filetype = "yaml"
        end,
      })

      -- Performance: Disable some features di file Dart yang besar
      autocmd("BufReadPre", {
        group = flutter_group,
        pattern = "*.dart",
        callback = function(args)
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
          if ok and stats and stats.size > 500 * 1024 then
            vim.opt_local.syntax = "off"
            vim.opt_local.foldmethod = "manual"
            vim.notify("Large Dart file - syntax disabled for performance", vim.log.levels.WARN)
          end
        end,
      })

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
          handlers = {
            -- Disable old documentColor handler to prevent filter type error
            ["textDocument/documentColor"] = false,
          },
          on_attach = function(client, bufnr)
            local on_attach = require "configs.on_attach"
            on_attach.on_attach(client, bufnr)

            local map = vim.keymap.set
            map("n", "<leader>Fr", "<cmd>FlutterRun<cr>", { desc = "Flutter Run", buffer = bufnr })
            map("n", "<leader>FR", "<cmd>FlutterRestart<cr>", { desc = "Flutter Restart", buffer = bufnr })
            map("n", "<leader>Fq", "<cmd>FlutterQuit<cr>", { desc = "Flutter Quit", buffer = bufnr })
            map("n", "<leader>Fc", "<cmd>FlutterReload<cr>", { desc = "Hot Reload", buffer = bufnr })
            map("n", "<leader>Ft", function()
  local fzf = require("fzf-lua")
  local commands = {
    "FlutterRun", "FlutterRestart", "FlutterReload", "FlutterQuit",
    "FlutterDetach", "FlutterEmulators", "FlutterDevices",
    "FlutterOutline", "FlutterDevTools", "FlutterCopyProfilerUrl",
    "FlutterPubGet", "FlutterPubUpgrade", "FlutterLspRestart",
    "FlutterSuperUpdateImports",
  }
  fzf.fzf_exec(commands, {
    prompt = "Flutter Commands> ",
    actions = {
      ["default"] = function(selected)
        if selected and #selected > 0 then
          vim.cmd(selected[1])
        end
      end,
    },
  })
end, { desc = "Flutter Commands (fzf)", buffer = bufnr })

            -- Document Colors: disabled globally via on_attach (sets
            -- server_capabilities.documentColorProvider = nil)

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

      -- NOTE: all flutter commands now use fzf-lua (no telescope dependency)
    end,
  },
}
