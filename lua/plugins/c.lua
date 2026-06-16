-- C/C++ Development: clangd LSP, clang-format, codelldb debug
-- Tree-sitter parsers added in core.lua
-- Keymaps/utility in utils/c.lua and mappings.lua

return {
  -- Mason: ensure clangd + clang-format installed
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
      },
    },
  },
}
