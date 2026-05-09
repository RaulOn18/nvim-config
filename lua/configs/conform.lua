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

  -- Format on save disabled globally
  -- Use :ConformFormat or <leader>fm manually when needed
  format_on_save = function(bufnr)
    local ignore_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "lua", "dart" }
    if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
      return nil
    end
    return nil
  end,
}

return options
