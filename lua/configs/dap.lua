local dap = require("dap")
local dap_utils = require("dap.utils")

-- ╭─────────────────────────────────────────────────────────────╮
-- │ DAP Configuration - Lazy Loaded by Filetype                 │
-- ╰─────────────────────────────────────────────────────────────╯

-- Helper function to setup adapters lazily
local function setup_adapter(name, config)
  if not dap.adapters[name] then
    dap.adapters[name] = config
  end
end

-- ╭─────────────────────────────────────────────────────────────╮
-- │ JavaScript / TypeScript (Node.js)                          │
-- ╰─────────────────────────────────────────────────────────────╯
local js_ts_setup = function()
  setup_adapter("node2", {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js" },
  })

  setup_adapter("pwa-node", {
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
  })

  setup_adapter("chrome", {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath("data") .. "/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js" },
  })

  dap.configurations.javascript = {
    {
      type = "node2",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
    {
      type = "node2",
      request = "attach",
      name = "Attach",
      processId = dap_utils.pick_process,
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
  }

  dap.configurations.typescript = dap.configurations.javascript
  dap.configurations.javascriptreact = dap.configurations.javascript
  dap.configurations.typescriptreact = dap.configurations.javascript
end

-- ╭─────────────────────────────────────────────────────────────╮
-- │ Go (Delve)                                                  │
-- ╰─────────────────────────────────────────────────────────────╯
local go_setup = function()
  setup_adapter("delve", {
    type = "server",
    port = "${port}",
    executable = {
      command = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv.exe",
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
  })

  dap.configurations.go = {
    {
      type = "delve",
      name = "Debug",
      request = "launch",
      program = "${file}",
    },
    {
      type = "delve",
      name = "Debug test",
      request = "launch",
      mode = "test",
      program = "${file}",
    },
    {
      type = "delve",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
    },
  }
end

-- ╭─────────────────────────────────────────────────────────────╮
-- │ Lazy Load Setup on FileType                                 │
-- ╰─────────────────────────────────────────────────────────────╯

-- Setup JS/TS when entering JS/TS files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = js_ts_setup,
  once = true,
})

-- Setup Go when entering Go files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = go_setup,
  once = true,
})

-- ╭─────────────────────────────────────────────────────────────╮
-- │ Signs and Highlights                                        │
-- ╰─────────────────────────────────────────────────────────────╯

vim.fn.sign_define("DapBreakpoint", {
  text = "●",
  texthl = "DapBreakpoint",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
  text = "◆",
  texthl = "DapBreakpointCondition",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapLogPoint", {
  text = "◆",
  texthl = "DapLogPoint",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "▶",
  texthl = "DapStopped",
  linehl = "DapStopped",
  numhl = "DapStopped",
})

vim.fn.sign_define("DapBreakpointRejected", {
  text = "✖",
  texthl = "DapBreakpointRejected",
  linehl = "",
  numhl = "",
})

-- Highlight groups
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff5555" })
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#ffaa55" })
vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#55aaff" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#55ff55", bg = "#225522" })
vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#888888" })

-- ╭─────────────────────────────────────────────────────────────╮
-- │ Helper Functions                                            │
-- ╰─────────────────────────────────────────────────────────────╯

function _G.dap_session_info()
  local session = dap.session()
  if session then
    print(vim.inspect(session.config))
  else
    print("No active debug session")
  end
end

vim.api.nvim_create_user_command("DapSessionInfo", function()
  dap_session_info()
end, { desc = "Show current DAP session info" })
