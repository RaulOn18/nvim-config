# AGENTS.md — Neovim Configuration

This is a Neovim configuration built on **NvChad v2.5**, using **lazy.nvim** for plugin management. Written in **Lua 5.1** (LuaJIT), optimized for JS/TS, Go, Flutter, and Node.js development.

## Build / Lint / Test

```
# Format all Lua files
stylua lua/ init.lua

# Check formatting (CI)
stylua --check lua/ init.lua

# Lint Lua files (install: luarocks install luacheck)
luacheck lua/ init.lua

# Validate config starts without errors
nvim --headless -c "lua vim.wait(3000, function() return false end)" -c "qa"

# Test a single Lua module (install: luarocks install luaunit)
# No test framework is set up currently — validate by opening Neovim and running :Lazy health
```

## Project Structure

```
init.lua                     # Entry point
lua/
  options.lua                # Vim options & performance settings
  mappings.lua               # Key mappings
  autocmds.lua               # Autocommands
  chadrc.lua                 # NvChad UI configuration
  configs/
    lazy.lua                 # Lazy.nvim settings
    lspconfig.lua            # LSP server configurations
    conform.lua              # Formatter configuration
    dap.lua                  # Debug adapter configuration
  plugins/
    init.lua                 # Plugin entry point (imports all categories)
    core.lua                 # LSP, formatter, treesitter
    git.lua                  # Git integration
    navigation.lua           # File explorer, telescope, search
    editing.lua              # Editing enhancements
    ide.lua                  # Project management, UI
    ai.lua                   # AI assistants
    debug.lua                # DAP debugging
    flutter.lua              # Flutter support
    markdown.lua             # Markdown support
    sql.lua                  # SQL editor support
  utils/
    project.lua              # Project management utilities
```

## Code Style

### Formatting
- 2-space indentation, spaces (not tabs)
- Line width: 120 columns
- Line endings: Unix (`\n`)
- Double quotes preferred (`"..."`)
- No parentheses on function calls where possible: `require "module"` not `require("module")`
- Formatter: `stylua` (config in `.stylua.toml`)

### Imports & Module Structure
```lua
-- Standard library: require directly
require "nvchad.options"

-- Local aliases for frequently used APIs
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd

-- Module pattern: local M = {} ... return M
local M = {}
M.fn_name = function() ... end
return M
```

### Naming Conventions
- `snake_case` for functions and variables
- `PascalCase` for augroup names (e.g., `FlutterOptimizations`)
- Module files: lowercase with underscores (e.g., `lspconfig.lua`)
- Plugin spec variables: lowercase (e.g., `local servers = { ... }`)
- Git commits: `type(scope): message` — types: `feat`, `fix`, `chore`, `refactor`, `docs`

### Variables
```lua
local o = vim.o           -- global options
local opt = vim.opt       -- global options (vim.opt style)
local wo = vim.wo         -- window-local options
local bo = vim.bo         -- buffer-local options
```

### Plugin Specs
```lua
return {
  {
    "author/plugin-name",
    event = "VeryLazy",           -- or: cmd, keys, ft
    opts = { ... },               -- passed to plugin's setup()
    config = function(_, opts)    -- override opts handling
      require("plugin").setup(opts)
    end,
    dependencies = { ... },
  },
}
```

### Error Handling
- Use `pcall` for optional dependencies: `local ok, mod = pcall(require, "some-module")`
- Use `vim.notify(msg, vim.log.levels.WARN/INFO/ERROR)` for user-facing messages
- Use guards to skip logic when conditions aren't met: `if not is_flutter_project() then return end`

### Key Mappings
```lua
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map({ "n", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "Save file" })
```

### Autocommands
```lua
local group = vim.api.nvim_create_augroup("GroupName", { clear = true })
autocmd("EventName", {
  group = group,
  pattern = "*.ext",
  callback = function(args) ... end,
})
```

### General Principles
- All plugins are lazy-loaded (event/cmd/keys/ft triggers)
- Performance-conscious: disable unused providers, debounce LSP, skip large files
- Graceful degradation: `pcall` wrappers around anything that might fail
- Comments in English; occasional Indonesian (`-- yang tidak digunakan`)
- Section headers with `-- ===` separators for visual grouping
- `FIX:` comment prefix marks known workarounds
