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
    dart = { "dart_format" },
    sql = { "sql_formatter" },
    go = { "gofumpt", "goimports" },
    kotlin = { "ktfmt" },
    c = { "clang_format" },
    cpp = { "clang_format" },
  },

  formatters = {
    dart_format = { command = "dart", args = { "format", "$FILENAME" }, stdin = false },
    gofumpt = { command = "gofumpt", stdin = true },
    goimports = { command = "goimports", stdin = true },
    ktfmt = {
      command = "ktfmt",
      args = { "--google_style", "--stdin", "$FILENAME" },
      stdin = true,
    },
    clang_format = {
      command = "clang-format",
      args = { "--style=file", "--fallback-style=LLVM" },
      stdin = true,
    },
  },
}

return options
