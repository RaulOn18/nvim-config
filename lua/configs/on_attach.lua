-- Shared on_attach for all LSP servers

local M = {}

-- 3 servers that only set semanticTokensProvider = nil collapsed into a single
-- loop. Append to SEM_TOK_OFF if a new server joins that ships unwanted
-- semantic tokens.
local SEM_TOK_OFF = { "vtsls", "gopls", "clangd" }

local PER_SERVER = {
  eslint = function(c) c.server_capabilities.documentFormattingProvider = true end,
  sqlls = function(c) c.server_capabilities.completionProvider = { triggerCharacters = { ".", " ", "(" } } end,
}

for _, name in ipairs(SEM_TOK_OFF) do
  PER_SERVER[name] = function(c) c.server_capabilities.semanticTokensProvider = nil end
end

function M.on_attach(client, _)
  -- ponytail: skip attaching to buffers flagged as bigfiles in autocmds.lua
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.b[bufnr].bigfile then return end

  local ok, nvconfig = pcall(require, "nvchad.configs.lspconfig")
  if ok and nvconfig.on_attach then nvconfig.on_attach(client, _) end

  -- Default: disable formatting (use conform.nvim)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  -- Neovim 0.12+ auto-enables and asserts when client advertises this
  client.server_capabilities.documentColorProvider = nil

  local override = PER_SERVER[client.name]
  if override then override(client) end
end

return M
