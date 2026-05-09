local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    markdown = { "prettier" },
    -- ============================================
    -- DART/FLUTTER FORMATTERS
    -- ============================================
    dart = { "dart_format" },
  },

  -- Formatters configuration
  formatters = {
    dart_format = {
      command = "dart",
      args = { "format", "$FILENAME" },
      stdin = false,
    },
  },

  -- Enable format on save untuk Dart (Flutter) files saja
  format_on_save = function(bufnr)
    -- Disable format on save untuk filetypes tertentu
    local ignore_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "lua" }
    if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
      return nil
    end
    
    -- Enable untuk Dart files
    if vim.bo[bufnr].filetype == "dart" then
      return { timeout_ms = 2000, lsp_fallback = false }
    end
    
    return nil
  end,
}

return options
