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

-- ============================================
-- FLUTTER/DART SPECIFIC AUTOCMDS
-- ============================================
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

-- Auto-format Dart files BEFORE save (prevents 'file changed' error)
autocmd("BufWritePre", {
  group = flutter_group,
  pattern = "*.dart",
  callback = function(args)
    -- Only format if file is modifiable and not readonly
    if vim.bo[args.buf].modifiable and not vim.bo[args.buf].readonly then
      local ok, conform = pcall(require, "conform")
      if ok then
        conform.format({ bufnr = args.buf, lsp_fallback = true, quiet = true })
      end
    end
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
    if ok and stats and stats.size > 500 * 1024 then -- File > 500KB
      vim.opt_local.syntax = "off"
      vim.opt_local.foldmethod = "manual"
      vim.notify("Large Dart file - syntax disabled for performance", vim.log.levels.WARN)
    end
  end,
})

-- Flutter-specific keymaps yang hanya aktif di Dart files
autocmd("FileType", {
  group = flutter_group,
  pattern = "dart",
  callback = function(args)
    -- Extract widget
    vim.keymap.set("n", "<leader>fe", function()
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.title:match("Extract widget") or
                 action.title:match("Extract method")
        end,
        apply = true,
      })
    end, { buffer = args.buf, desc = "Flutter: Extract widget/method" })
    
    -- Quick fix all
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

-- ============================================
-- SQL SPECIFIC AUTOCMDS
-- ============================================
local sql_group = augroup("SQLOptimizations", { clear = true })

-- Set SQL filetype variations
autocmd({ "BufRead", "BufNewFile" }, {
  group = sql_group,
  pattern = { "*.sql", "*.mysql", "*.plsql", "*.pgsql" },
  callback = function()
    vim.opt_local.filetype = "sql"
    vim.opt_local.commentstring = "-- %s"
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Auto-format SQL on save
autocmd("BufWritePre", {
  group = sql_group,
  pattern = "*.sql",
  callback = function()
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ lsp_fallback = true })
    end
  end,
})
