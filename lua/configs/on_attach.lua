-- Shared on_attach for all LSP servers
-- Single place for: NvChad defaults, formatting disable, per-server overrides

local M = {}

-- Per-server on_attach overrides (keyed by server name)
local PER_SERVER = {
  vtsls = function(c)
    c.server_capabilities.codeLensProvider = false
    c.server_capabilities.semanticTokensProvider = nil
  end,
  eslint = function(c)
    c.server_capabilities.documentFormattingProvider = true
  end,
  kotlin_lsp = function(c)
    c.server_capabilities.semanticTokensProvider = nil
  end,
  gopls = function(c)
    c.server_capabilities.documentFormattingProvider = false
    c.server_capabilities.documentRangeFormattingProvider = false
    c.server_capabilities.semanticTokensProvider = nil
  end,
  clangd = function(c)
    c.server_capabilities.semanticTokensProvider = nil
  end,
  sqlls = function(c)
    c.server_capabilities.completionProvider = {
      triggerCharacters = { ".", " ", "(" },
    }
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

  local override = PER_SERVER[client.name]
  if override then
    override(client)
  end
end

return M
