require "nvchad.autocmds"

-- Node.js/Next.js Performance Autocmds
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Group untuk Node.js optimizations
local nodejs_group = augroup("NodeJSOptimizations", { clear = true })

-- Disable formatting for node_modules
autocmd({ "BufRead", "BufNewFile" }, {
  group = nodejs_group,
  pattern = "*/node_modules/*",
  callback = function()
    vim.opt_local.readonly = true
    vim.opt_local.modifiable = false
    vim.opt_local.buflisted = false
  end,
})

-- Large file optimizations (>1MB)
autocmd("BufReadPre", {
  group = nodejs_group,
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1024 * 1024 then
      vim.opt_local.syntax = "off"
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = -1
      vim.opt_local.swapfile = false
      vim.notify("Large file detected - optimizations applied", vim.log.levels.INFO)
    end
  end,
})

-- Optimize LSP untuk file yang sering diedit
autocmd("LspAttach", {
  group = nodejs_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "vtsls" then
      -- Disable semantic highlighting untuk performa lebih baik
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

-- Reduce flicker on CursorHold
autocmd({ "CursorHold", "CursorHoldI" }, {
  group = nodejs_group,
  pattern = "*",
  callback = function()
    vim.diagnostic.show()
  end,
})
