return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    cmd = { "FlutterRun", "FlutterDevices", "FlutterEmulators", "FlutterReload", "FlutterRestart", "FlutterQuit" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("flutter-tools").setup {
        lsp = {
          on_attach = require("nvchad.configs.lspconfig").on_attach,
          capabilities = require("nvchad.configs.lspconfig").capabilities,
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            analysisExcludedFolders = {
              vim.fn.expand "$HOME/.pub-cache",
            },
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = false,
        },
        widget_guides = {
          enabled = true,
        },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = ">",
          enabled = true,
        },
      }
    end,
  },
}
