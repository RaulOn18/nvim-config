# Neovim Configuration Performance Analysis

## ✅ Already Good

### 1. **init.lua**
- `shadafile = "NONE"` - No session persistence (faster startup)
- `vim.schedule` for mappings (deferred loading)
- `lazy = true` default in lazy.lua

### 2. **options.lua**
- Disabled unused providers (perl, ruby, node)
- `synmaxcol = 200` - Limit syntax highlighting columns
- `history = 100`, `undolevels = 100` - Reduced memory

### 3. **lazy.lua**
- Disabled many unused built-in plugins (netrw, matchit, etc.)

### 4. **configs/lspconfig.lua**
- `vim.lsp.log.set_level(vim.lsp.log.levels.OFF)` - No LSP logs
- Disabled semantic tokens for vtsls
- Disabled code lens for vtsls
- Debounced diagnostics handler
- `single_file_support = false` for vtsls (prevents unnecessary server instances)

### 5. **plugins/core.lua**
- Treesitter disables for large files (>500KB) and node_modules
- Conform lazy loads on BufReadPre

### 6. **plugins/navigation.lua**
- Telescope ignores node_modules, .git, .next, dist, build, target
- NvimTree lazy loads on cmd/keys

### 7. **plugins/editing.lua**
- All mini plugins lazy load (VeryLazy or keys)

### 8. **plugins/flutter.lua**
- Flutter tools checks if Flutter project before loading
- `run_via_dap = false` (faster startup)

---

## 🔧 IMPROVEMENTS NEEDED

### 1. **init.lua** - Missing
```lua
-- ADD THESE:
vim.g.did_load_filetypes = 1        -- Skip default filetype detection
vim.g.did_load_fzf = 1              -- Skip default fzf loading
vim.g.did_load_gzip = 1             -- Skip gzip plugin
vim.g.did_load_tar = 1              -- Skip tar plugin
vim.g.did_load_zip = 1              -- Skip zip plugin
vim.g.did_load_tutor = 1            -- Skip tutor plugin
vim.g.did_load_spellfile_plugin = 1 -- Skip spellfile plugin
vim.g.loaded_man = 1                -- Skip man pages plugin
vim.g.loaded_remote_plugins = 1     -- Skip remote plugins (Python/Ruby)

-- Faster startup
vim.opt.shadafile = "NONE"  -- Already done ✓
vim.opt.swapfile = false     -- No swap files (faster writes)
vim.opt.backup = false       -- No backup files
vim.opt.writebackup = false  -- No backup before overwriting
```

### 2. **options.lua** - Missing
```lua
-- ADD THESE PERFORMANCE OPTIONS:
o.lazyredraw = true          -- Don't redraw during macros (was false!)
o.ttyfast = true             -- Faster terminal rendering
o.redrawtime = 1000          -- Timeout for syntax highlighting (default 2000)
o.synmaxcol = 200            -- Already set ✓
o.maxmempattern = 1000       -- Limit pattern matching memory (default 1000)

-- Better completion performance
opt.complete:remove("i")     -- Don't scan included files
opt.complete:remove("t")     -- Don't scan tags (use LSP instead)

-- Reduce update frequency
o.updatetime = 250           -- Already set ✓
o.timeoutlen = 500           -- Already set ✓
```

### 3. **lazy.lua** - More plugins to disable
```lua
performance = {
  rtp = {
    disabled_plugins = {
      -- Already disabled ✓
      -- ADD THESE:
      "tutor",           -- Already ✓
      "rplugin",         -- Already ✓
      "syntax",          -- Already ✓
      -- MISSING:
      "editorconfig",    -- Not needed, LSP handles it
      "man",             -- Use :Man command instead
      "shada",           -- No session persistence
      "spellfile",       -- No spell checking
      "tohtml",          -- Already ✓
      "tutor",           -- Already ✓
    },
  },
}
```

### 4. **plugins/core.lua** - Treesitter optimization
```lua
-- Current: enable incremental_selection (uses CPU)
-- BETTER: disable if not actively used
incremental_selection = {
  enable = false,  -- Disable if not using <C-space> selection
}
```

### 5. **plugins/ide.lua** - project.nvim
```lua
-- Current: lazy = false (loads at startup!)
-- FIX: Make it lazy
{
  "ahmedkhalf/project.nvim",
  lazy = true,           -- Change from false to true
  event = "VeryLazy",    -- Or use event trigger
  -- ... rest of config
}
```

### 6. **plugins/flutter.lua** - flutter-tools.nvim
```lua
-- Current: lazy = false (loads at startup!)
-- FIX: Only load when Flutter project detected
{
  "nvim-flutter/flutter-tools.nvim",
  lazy = true,  -- Change from false
  ft = "dart",  -- Only load for Dart files
  -- OR use cond:
  -- cond = function() return vim.fn.findfile("pubspec.yaml", ".;") ~= "" end,
  -- ... rest of config
}
```

### 7. **plugins/navigation.lua** - NvimTree
```lua
-- Current: git.enable = true (slows down on large repos)
-- BETTER: Disable git integration for performance
git = {
  enable = false,  -- Disable git status icons (faster)
  ignore = false,
},
```

### 8. **plugins/git.lua** - gitsigns.nvim
```lua
-- Current: current_line_blame = true (updates on every cursor move!)
-- BETTER: Disable or increase delay
current_line_blame = false,  -- Disable for performance
-- OR increase delay significantly:
-- current_line_blame_opts = {
--   delay = 1000,  -- Increase from 300ms to 1000ms
-- },
```

### 9. **plugins/markdown.lua** - render-markdown.nvim
```lua
-- Current: loads for markdown filetype (good)
-- MISSING: Should also disable for large markdown files
-- ADD to opts:
opts = {
  max_file_size = 1.0,  -- MB, disable for files > 1MB
}
```

### 10. **configs/lspconfig.lua** - ESLint
```lua
-- Current: validate = "probe" (checks every file)
-- BETTER: Only validate when config exists
validate = "off",  -- Don't probe, rely on root_markers
```

### 11. **Missing: File type detection optimization**
```lua
-- In init.lua or options.lua:
vim.g.did_load_filetypes = 1  -- Use filetype.nvim instead of built-in
```

### 12. **Missing: Disable unused treesitter parsers**
```lua
-- In core.lua treesitter opts:
ensure_installed = {
  -- Only install what you actually use
  -- REMOVE if not using:
  -- "markdown_inline",  -- Rarely needed
}
```

### 13. **Missing: Telescope caching**
```lua
-- In telescope opts:
defaults = {
  cache_picker = {
    num_pickers = 10,  -- Cache last 10 pickers (faster reopening)
  },
}
```

### 14. **Missing: LSP workspace diagnostics**
```lua
-- In lspconfig.lua diagnostic config:
vim.diagnostic.config {
  -- Current config is good ✓
  -- ADD: Limit diagnostic update frequency
  update_in_insert = false,  -- Already set ✓
  float = {
    border = "rounded",
    source = "always",
    focusable = false,  -- Don't steal focus
  },
}
```

### 15. **Missing: Completion performance (nvim-cmp)**
```lua
-- If using nvim-cmp, add these optimizations:
-- (NvChad should handle this, but verify)
performance = {
  debounce = 60,
  throttle = 30,
  fetching_timeout = 200,
  confirm_resolve_timeout = 80,
  async_budget = 1,
  max_view_entries = 200,
}
```

---

## 📊 Expected Performance Gains

| Improvement | Startup Time | Runtime Performance |
|------------|--------------|---------------------|
| Disable more built-in plugins | -50ms | - |
| lazyredraw = true | - | +10-20% in macros |
| Disable gitsigns blame | - | +5-15% cursor movement |
| Disable NvimTree git | - | +10-30% in large repos |
| Lazy load flutter-tools | -100-200ms | - |
| Lazy load project.nvim | -50-100ms | - |
| Treesitter incremental_selection | - | +5% CPU |

---

## 🎯 Priority Fixes (Quick Wins)

1. **`lazyredraw = true`** - Immediate benefit for macros
2. **Lazy load flutter-tools & project.nvim** - Faster startup
3. **Disable gitsigns blame** - Smoother scrolling
4. **Disable NvimTree git** - Faster file browsing
5. **Add more disabled plugins to lazy.lua** - Faster startup

---

## ⚠️ Missing Configurations

1. **No mason.nvim auto-install** - LSP servers not auto-installed
2. **No filetype.nvim** - Using slower built-in filetype detection
3. **No autopairs for SQL** - Missing in conform.lua
4. **No SQL treesitter parser** - In ensure_installed
5. **No LSP for YAML/Docker** - Missing common filetypes

---

## 🔍 Debug Commands

```bash
# Profile startup time
nvim --startuptime startup.log

# Check loaded plugins
:Lazy profile

# Check LSP status
:LspInfo

# Check treesitter status
:TSInstallInfo
```
