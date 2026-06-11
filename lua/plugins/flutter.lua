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

      -- Disable LSP untuk build dan cache folders
      autocmd({ "BufRead", "BufNewFile" }, {
        group = flutter_group,
        pattern = {
          "*/build/*",
          "*/.dart_tool/*",
          "*/.flutter-plugins*",
          "*/.pub-cache/*",
          "*/.flutter/*",
        },
        callback = function()
          vim.opt_local.readonly = true
          vim.opt_local.modifiable = false
          vim.opt_local.buflisted = false
          vim.opt_local.syntax = "off"
        end,
      })

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
        widget_guides = { enabled = true },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = ">",
          enabled = true,
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
            map("n", "<leader>Ft", "<cmd>Telescope flutter commands<cr>", { desc = "Flutter Commands", buffer = bufnr })

            -- Document Colors (Neovim 0.12+)
            local ok_color, _ = pcall(vim.lsp.document_color.enable, true, { bufnr = bufnr })
            if not ok_color then
              vim.notify("document_color API not available", vim.log.levels.DEBUG)
            end

            -- Force Enable Code Action Provider (ensure dart refactor actions show)
            if type(client.server_capabilities.codeActionProvider) ~= "table" then
              client.server_capabilities.codeActionProvider = {}
            end
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
}
