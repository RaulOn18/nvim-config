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
  { import = "plugins.kotlin" },     -- Kotlin/Android/Compose support
  { import = "nvchad.blink.lazyspec" }, -- Completion (NvChad's official blink.cmp setup)
  {
    "Saghen/blink.cmp",
    -- ponytail: NvChad sets fuzzy.implementation = "prefer_rust". Auto-download of prebuilt binaries
    -- fails silently when offline / on unsupported targets; without this build directive the Rust
    -- fuzzy matcher is never compiled and completion falls back to Lua + frecency breaks.
    build = "cargo build --release",
    opts = require "configs.blink",
  }, -- Personal overrides
}
