-- Main plugin entry point
-- All plugins are organized in separate files by category

return {
  { import = "plugins.core" },      -- LSP, formatter, treesitter
  { import = "plugins.git" },       -- Git integration
  { import = "plugins.navigation" }, -- File explorer, fzf-lua, search
  { import = "plugins.editing" },   -- Mini plugins, editing enhancements
  { import = "plugins.ide" },       -- Project management, UI features
  { import = "plugins.ai" },        -- AI assistants
  { import = "plugins.debug" },     -- DAP debugging
  { import = "plugins.flutter" },   -- Flutter development
  { import = "plugins.markdown" },  -- Markdown support
  { import = "plugins.sql" },       -- SQL editor support
  { import = "plugins.c" },         -- C/C++: clangd, clang-format, codelldb
  { import = "plugins.kotlin" },    -- Kotlin/Android/Compose support

  -- Disable NvChad bundled telescope (replaced by fzf-lua)
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "nvim-telescope/telescope-fzf-native.nvim", enabled = false },
  { "nvim-telescope/telescope-ui-select.nvim", enabled = false },
}
