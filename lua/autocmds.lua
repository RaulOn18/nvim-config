require "nvchad.autocmds"

-- NOTE: deleted: node_modules readonly, large-file BufReadPre, 9-pattern
-- build-dir readonly, C/C++ makeprg auto-detect, GRADLE_HOME (wrong), Android
-- SDK detection (belongs in shell). Re-add as one autocmd if you miss them.

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local bigfile_group = augroup("BigFileGuard", { clear = true })

-- ponytail: guard against accidental huge-buffer spikes.
-- Turns off heavy features early so one giant file can not eat 10+ GB RAM.
autocmd({ "BufReadPre", "FileReadPre" }, {
  group = bigfile_group,
  callback = function(args)
    local file = args.match or ""
    local size = vim.fn.getfsize(file)
    if size > 1048576 then -- ~1MB
       vim.b.bigfile = true
       vim.bo.swapfile = false
       vim.bo.undolevels = -1
       vim.bo.syntax = "off"
       vim.opt_local.spell = false
       vim.opt_local.wrap = false
       vim.opt_local.foldmethod = "manual"
    end
  end,
})

-- Kotlin/Android: Android convention (4 spaces, // comments, no wrap)
autocmd("FileType", {
  group = augroup("KotlinFiletypeSettings", { clear = true }),
  pattern = "kotlin",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.wrap = false
    vim.bo.commentstring = "// %s"
  end,
})

-- ponytail: diagnostics on non-code filetypes is wasted work, skip it
autocmd("FileType", {
  group = augroup("DiagOffNonCode", { clear = true }),
  pattern = { "help", "man", "text", "gitcommit", "fugitive", "qf", "lazy", "TelescopePrompt" },
  callback = function(args)
    local diag = vim.diagnostic
    if diag and type(diag.disable) == "function" then
      pcall(diag.disable, args.buf)
    end
  end,
})

autocmd("BufWritePost", {
  group = bigfile_group,
  callback = function(args)
    if vim.b[args.buf].bigfile then
       vim.bo[args.buf].syntax = "off"
    end
  end,
})

-- ponytail: web ft use 2-space indent to match prettier default.
-- Global is 4-space; without this every save re-indents and the buffer jumps.
autocmd("FileType", {
  group = augroup("WebIndent", { clear = true }),
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "jsonc", "css", "scss", "html", "markdown" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- ponytail: force LF on save. go is required (gofmt rejects CRLF). Skips .bat/.cmd/.ps1 (Windows-native, CRLF-safe).
autocmd("BufWritePre", {
  group = augroup("ForceLfOnWrite", { clear = true }),
  pattern = { "*.ts", "*.tsx", "*.js", "jsx", "*.mjs", "*.cjs", "*.json", "*.jsonc", "*.dart", "*.go", "*.kt", "*.kts", "*.py" },
  command = "setlocal fileformat=unix",
})
