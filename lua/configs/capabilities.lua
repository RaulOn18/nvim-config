-- Shared LSP client capabilities (used by lspconfig + kotlin.nvim)
local M = {}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Merge cmp_nvim_lsp capabilities when nvim-cmp is loaded
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
end

M.default = capabilities
return M
