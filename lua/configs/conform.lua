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
}

return options
