-- Debug Adapter Protocol (DAP) Configuration

local dap_keys = {
  { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end, desc = "Breakpoint Condition" },
  { "<leader>db", function() require("dap").toggle_breakpoint() end,  desc = "Toggle Breakpoint" },
  { "<leader>dc", function() require("dap").continue() end,           desc = "Continue/Start" },
  { "<leader>dC", function() require("dap").run_to_cursor() end,      desc = "Run to Cursor" },
  { "<leader>dg", function() require("dap").goto_() end,              desc = "Go to Line (no execute)" },
  { "<leader>di", function() require("dap").step_into() end,          desc = "Step Into" },
  { "<leader>dj", function() require("dap").down() end,               desc = "Down" },
  { "<leader>dk", function() require("dap").up() end,                 desc = "Up" },
  { "<leader>dl", function() require("dap").run_last() end,           desc = "Run Last" },
  { "<leader>do", function() require("dap").step_out() end,           desc = "Step Out" },
  { "<leader>dO", function() require("dap").step_over() end,          desc = "Step Over" },
  { "<leader>dp", function() require("dap").pause() end,              desc = "Pause" },
  { "<leader>dr", function() require("dap").repl.toggle() end,        desc = "Toggle REPL" },
  { "<leader>dS", function() require("dap").session() end,            desc = "Session" },
  { "<leader>dt", function() require("dap").terminate() end,          desc = "Terminate" },
  { "<leader>dw", function() require("dap.ui.widgets").hover() end,   desc = "Widgets" },
}

local function setup_signs()
  vim.fn.sign_define("DapBreakpoint",           { text = "●", texthl = "DapBreakpoint",           linehl = "", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition",  { text = "◆", texthl = "DapBreakpointCondition",  linehl = "", numhl = "" })
  vim.fn.sign_define("DapLogPoint",             { text = "◆", texthl = "DapLogPoint",             linehl = "", numhl = "" })
  vim.fn.sign_define("DapStopped",              { text = "▶", texthl = "DapStopped",              linehl = "DapStopped", numhl = "DapStopped" })
  vim.fn.sign_define("DapBreakpointRejected",   { text = "✖", texthl = "DapBreakpointRejected",   linehl = "", numhl = "" })
  vim.api.nvim_set_hl(0, "DapBreakpoint",          { fg = "#ff5555" })
  vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#ffaa55" })
  vim.api.nvim_set_hl(0, "DapLogPoint",            { fg = "#55aaff" })
  vim.api.nvim_set_hl(0, "DapStopped",             { fg = "#55ff55", bg = "#225522" })
  vim.api.nvim_set_hl(0, "DapBreakpointRejected",  { fg = "#888888" })
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      keys = {
        { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
        { "<leader>de", function() require("dapui").eval() end,    desc = "DAP Eval", mode = { "n", "v" } },
      },
      config = function()
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup {}
        dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
      end,
    },
    { "theHamsta/nvim-dap-virtual-text" },
  },
  keys = dap_keys,
  config = function()
    setup_signs()
    local dap = require("dap")
    local dap_utils = require("dap.utils")

    -- JS/TS
    dap.adapters.node2 = {
      type = "executable",
      command = "node",
      args = { vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js" },
    }
    dap.adapters["pwa-node"] = {
      type = "server", host = "localhost", port = "${port}",
      executable = {
        command = "node",
        args = {
          vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }
    dap.configurations.javascript = {
      { type = "node2", request = "launch", name = "Launch file", program = "${file}", cwd = "${workspaceFolder}",
        sourceMaps = true, protocol = "inspector", console = "integratedTerminal", internalConsoleOptions = "neverOpen" },
      { type = "node2", request = "attach", name = "Attach", processId = dap_utils.pick_process, cwd = "${workspaceFolder}",
        sourceMaps = true, protocol = "inspector", console = "integratedTerminal" },
    }
    for _, ft in ipairs { "typescript", "javascriptreact", "typescriptreact" } do
      dap.configurations[ft] = dap.configurations.javascript
    end

    -- Go (Delve)
    dap.adapters.delve = {
      type = "server", port = "${port}",
      executable = {
        command = vim.fn.stdpath "data" .. "/mason/packages/delve/dlv.exe",
        args = { "dap", "-l", "127.0.0.1:${port}" },
      },
    }
    dap.configurations.go = {
      { type = "delve", name = "Debug",            request = "launch", program = "${file}" },
      { type = "delve", name = "Debug test",       request = "launch", mode = "test", program = "${file}" },
      { type = "delve", name = "Debug test (mod)", request = "launch", mode = "test", program = "./${relativeFileDirname}" },
    }

    -- Kotlin
    local kotlin_adapter = vim.fn.stdpath "data" .. "/mason/packages/kotlin-debug-adapter/bin/kotlin-debug-adapter"
    if vim.fn.has "win32" == 1 then kotlin_adapter = kotlin_adapter .. ".bat" end
    if vim.fn.filereadable(kotlin_adapter) == 1 then
      dap.adapters.kotlin = { type = "executable", command = kotlin_adapter, args = { "--stdio" } }
      dap.configurations.kotlin = {
        { type = "kotlin", request = "launch", name = "Launch Kotlin",
          projectRoot = "${workspaceFolder}",
          mainClass = function() return vim.fn.input "Main class (e.g. com.example.MainKt): " end },
        { type = "kotlin", request = "launch", name = "Launch Android",
          projectRoot = "${workspaceFolder}", mainClass = "android.app.Activity" },
      }
    end

    -- C/C++: codelldb (PATH or mason)
    local codelldb = vim.fn.exepath "codelldb"
    if codelldb == "" then
      local ext = vim.fn.has "win32" == 1 and ".exe" or ""
      local p = vim.fn.stdpath "data" .. "/mason/packages/codelldb/adapter/codelldb" .. ext
      if vim.fn.filereadable(p) == 1 then codelldb = p end
    end
    if codelldb ~= "" then
      dap.adapters.codelldb = { type = "server", port = "${port}",
        executable = { command = codelldb, args = { "--port", "${port}" } } }
      local cfgs = {
        { type = "codelldb", name = "Launch", request = "launch",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file") end,
          cwd = "${workspaceFolder}", stopOnEntry = false },
        { type = "codelldb", name = "Attach", request = "attach",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file") end,
          pid = dap_utils.pick_process, cwd = "${workspaceFolder}" },
      }
      dap.configurations.c, dap.configurations.cpp = cfgs, cfgs
    end

    vim.api.nvim_create_user_command("DapSessionInfo", function()
      local s = dap.session()
      print(s and vim.inspect(s.config) or "No active debug session")
    end, { desc = "Show current DAP session info" })
  end,
}
