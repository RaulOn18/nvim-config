require "nvchad.autocmds"

-- Node.js/Next.js Performance Autocmds
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Preserve window proportions when NvimTree opens/closes
-- DISABLED: causes performance issues
-- local nvimtree_group = augroup("NvimTreeResize", { clear = true })

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

-- Large file optimizations (>1MB) - all filetypes
autocmd("BufReadPre", {
  group = nodejs_group,
  pattern = "*",
  callback = function(args)
    local fname = vim.api.nvim_buf_get_name(args.buf)
    if fname == "" or fname:match("^%w+://") then return end
    local ok, stats = pcall(vim.uv.fs_stat, fname)
    if ok and stats and stats.size > 1024 * 1024 then
      vim.opt_local.syntax = "off"
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = -1
      vim.opt_local.swapfile = false
      vim.notify("Large file detected - optimizations applied", vim.log.levels.INFO)
    end
  end,
})

-- Auto-generated/build folders - readonly, no LSP
autocmd({ "BufRead", "BufNewFile" }, {
  group = nodejs_group,
  pattern = {
    "*/build/*",
    "*/.gradle/*",
    "*/.idea/*",
    "*/.kotlin/*",
    "*/.navigation/*",
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


