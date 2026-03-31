-- Main plugin entry point
-- All plugins are organized in separate files by category

return {
  { import = "plugins.core" },      -- LSP, formatter, treesitter
  { import = "plugins.git" },       -- Git integration
  { import = "plugins.navigation" }, -- File explorer, telescope, search
  { import = "plugins.editing" },   -- Mini plugins, editing enhancements
  { import = "plugins.ide" },       -- Project management, UI features
  { import = "plugins.ai" },        -- AI assistants
  { import = "plugins.debug" },     -- DAP debugging
  { import = "plugins.flutter" },   -- Flutter development
  { import = "plugins.markdown" },  -- Markdown support
}
