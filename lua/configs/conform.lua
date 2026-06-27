local options = {
  -- prettierd: long-running prettier daemon. Drops per-save Node startup
  -- (~300-500ms -> ~50ms warm). One daemon serves the whole web family.
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettierd" },
    html = { "prettierd" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    markdown = { "prettierd" },
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

  -- Format on save OFF (manual only). Trigger: <leader>fm (NvChad default) or :ConformInfo.
}

return options
