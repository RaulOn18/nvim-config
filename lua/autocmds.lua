require "nvchad.autocmds"

-- NOTE: deleted: node_modules readonly, large-file BufReadPre, 9-pattern
-- build-dir readonly, C/C++ makeprg auto-detect, GRADLE_HOME (wrong), Android
-- SDK detection (belongs in shell). Re-add as one autocmd if you miss them.

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

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
