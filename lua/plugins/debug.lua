-- Debug Adapter Protocol (DAP) Configuration

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- DAP UI
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      keys = {
        { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
        { "<leader>de", function() require("dapui").eval() end, desc = "DAP Eval", mode = { "n", "v" } },
      },
      opts = {},
      config = function(_, opts)
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup(opts)

        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end,
    },
    -- Virtual text for DAP
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
  },
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Continue/Start" },
    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (no execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  },
  config = function()
    local signs_setup = false
    local adapters_setup = false

    local function ensure_signs()
      if signs_setup then return end
      signs_setup = true
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "✖", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff5555" })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#ffaa55" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#55aaff" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#55ff55", bg = "#225522" })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#888888" })
    end

    local function ensure_adapters()
      if adapters_setup then return end
      adapters_setup = true
      local dap = require("dap")
      local dap_utils = require("dap.utils")

      -- JS/TS
      dap.adapters["node2"] = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js" },
      }
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
      dap.adapters["chrome"] = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js" },
      }

      dap.configurations.javascript = {
        {
          type = "node2", request = "launch", name = "Launch file",
          program = "${file}", cwd = "${workspaceFolder}",
          sourceMaps = true, protocol = "inspector",
          console = "integratedTerminal", internalConsoleOptions = "neverOpen",
        },
        {
          type = "node2", request = "attach", name = "Attach",
          processId = dap_utils.pick_process, cwd = "${workspaceFolder}",
          sourceMaps = true, protocol = "inspector", console = "integratedTerminal",
        },
      }
      dap.configurations.typescript = dap.configurations.javascript
      dap.configurations.javascriptreact = dap.configurations.javascript
      dap.configurations.typescriptreact = dap.configurations.javascript

      -- Go (Delve)
      dap.adapters["delve"] = {
        type = "server", port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv.exe",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      }
      dap.configurations.go = {
        { type = "delve", name = "Debug", request = "launch", program = "${file}" },
        { type = "delve", name = "Debug test", request = "launch", mode = "test", program = "${file}" },
        { type = "delve", name = "Debug test (go.mod)", request = "launch", mode = "test", program = "./${relativeFileDirname}" },
      }

      -- Signs on first session
      dap.listeners.after.event_initialized["lazy_signs"] = ensure_signs
    end

    -- Defer all DAP work to first <leader>d keypress
    local orig_keys = vim.deepcopy(self.keys or {})
    for _, key in ipairs(orig_keys) do
      local lhs = key[1]
      local orig_rhs = key[2]
      local desc = key.desc or ""
      local mode = key.mode or "n"
      vim.keymap.set(mode, lhs, function()
        ensure_adapters()
        orig_rhs()
      end, { desc = desc })
    end

    -- Helper command
    vim.api.nvim_create_user_command("DapSessionInfo", function()
      ensure_adapters()
      local dap = require("dap")
      local session = dap.session()
      if session then
        print(vim.inspect(session.config))
      else
        print("No active debug session")
      end
    end, { desc = "Show current DAP session info" })
  end,
}
