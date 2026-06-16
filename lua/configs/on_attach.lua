-- Shared on_attach for all LSP servers
-- Single place for: NvChad defaults, formatting disable, per-server overrides

local M = {}

-- Per-server on_attach overrides (keyed by server name)
-- Set to a function(client, bufnr) for custom behaviour
M.server_overrides = {
  -- vtsls: also disable codeLens + semantic tokens
  vtsls = function(client, bufnr)
    client.server_capabilities.codeLensProvider = false
    client.server_capabilities.semanticTokensProvider = nil
  end,
  -- eslint: enable formatting (it provides code actions + fixes)
  eslint = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
  end,
  -- kotlin-lsp: disable semantic tokens (heavy, slow on large projects)
  kotlin_lsp = function(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  -- gopls: disable formatting (conform handles gofumpt + goimports)
  gopls = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    -- semantic tokens already off via settings, but force nil
    client.server_capabilities.semanticTokensProvider = nil
  end,
  -- clangd: heavy on large codebases, disable semantic tokens (clangd ships its own)
  clangd = function(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil
    -- inlayHints controlled by clangd setting + vim.lsp.inlay_hint.enable() if needed
  end,
}

function M.on_attach(client, bufnr)
  -- NvChad default on_attach (highlight, signature, etc.)
  local ok_nvchad, nvconfig = pcall(require, "nvchad.configs.lspconfig")
  if ok_nvchad and nvconfig.on_attach then
    nvconfig.on_attach(client, bufnr)
  end

  -- Default: disable formatting (use conform.nvim)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  -- Disable documentColor (Neovim 0.12+ auto-enables and triggers assert in
  -- vim/lsp/document_color.lua:225 when client advertises the capability)
  client.server_capabilities.documentColorProvider = nil

  -- Per-server override
  local override = M.server_overrides[client.name]
  if override then
    override(client, bufnr)
  end
end

return M
