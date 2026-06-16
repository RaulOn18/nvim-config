-- Main plugin entry point
-- All plugins are organized in separate files by category

return {
  { import = "plugins.core" },       -- LSP, formatter, treesitter
  { import = "plugins.git" },        -- Git integration
  { import = "plugins.navigation" }, -- File explorer, search, replace
  { import = "plugins.editing" },    -- Mini.surround, comments, snippets, render-markdown
  { import = "plugins.ide" },        -- Project management, which-key
  { import = "plugins.ai" },         -- AI assistants
  { import = "plugins.debug" },      -- DAP debugging
  { import = "plugins.flutter" },    -- Flutter development
  { import = "plugins.sql" },        -- SQL editor support
  { import = "plugins.kotlin" },     -- Kotlin/Android/Compose support
}
