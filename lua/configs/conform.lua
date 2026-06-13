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
    -- ============================================
    -- SQL FORMATTERS
    -- ============================================
    sql = { "sql_formatter" },
    -- ============================================
    -- GO FORMATTERS
    -- ============================================
    go = { "gofumpt", "goimports" },
    -- ============================================
    -- KOTLIN FORMATTERS
    -- ============================================
    kotlin = { "ktfmt" },
  },

  -- Formatters configuration
  formatters = {
    dart_format = {
      command = "dart",
      args = { "format", "$FILENAME" },
      stdin = false,
    },
    sql_formatter = {
      args = { "--language", "sql" },
    },
    gofumpt = {
      command = "gofumpt",
      stdin = true,
    },
    goimports = {
      command = "goimports",
      stdin = true,
    },
    ktfmt = {
      command = "ktfmt",
      args = {
        "--google_style",
        "--stdin",
        "$FILENAME",
      },
      stdin = true,
      -- fallback: try ktlint if ktfmt not found
      condition = function(self, ctx)
        return vim.fn.executable("ktfmt") == 1
      end,
    },
    ktlint = {
      command = "ktlint",
      args = { "--format", "--stdin" },
      stdin = true,
    },
  },

  -- Format on save disabled globally
  -- Use :ConformFormat or <leader>fm manually when needed
}

return options
