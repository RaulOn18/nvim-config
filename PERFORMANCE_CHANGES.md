# Performance Optimization Changes

## Changes Applied

### 1. init.lua
- Disabled `did_load_filetypes` (BREAKS FILETYPE DETECTION - REVERTED)
- Disabled `did_load_fzf`
- Disabled `loaded_man`, `loaded_remote_plugins`
- Disabled swap/backup files

### 2. options.lua
- `lazyredraw = true` (was false)
- `ttyfast = true`
- `redrawtime = 1500`
- `maxmempattern = 2000`
- Completion optimizations

### 3. configs/lazy.lua
- Disabled: editorconfig, man, shada, spellfile, remote_plugins, tohtml, tutor

### 4. plugins/ide.lua
- `project.nvim`: `lazy = true, event = "VeryLazy"`

### 5. plugins/flutter.lua
- `flutter-tools.nvim`: `lazy = true, ft = "dart"`

### 6. plugins/git.lua
- `gitsigns`: disabled `current_line_blame`

### 7. plugins/navigation.lua
- `nvim-tree`: disabled git integration

### 8. plugins/core.lua
- `treesitter`: disabled `incremental_selection`
- `nvim-lspconfig`: `lazy = false, priority = 1000`
- Treesitter event changed to `BufReadPost` + `BufNewFile`

### 9. configs/lspconfig.lua
- **FIX**: Using `vim.lsp.start()` directly (not deprecated `vim.lsp.config`)
- FileType autocommand to start LSP when buffer is opened
- Proper `on_attach` to disable formatting

## Known Issues & Fixes

### Issue: LSP not starting
**Root cause**: `vim.lsp.config` + `vim.lsp.enable` doesn't work reliably in Neovim 0.12  
**Fix**: Using `vim.lsp.start()` directly with FileType autocommand

### Issue: Treesitter not loading
**Root cause**: `nvim-treesitter.configs` module renamed to `nvim-treesitter.config`  
**Fix**: Updated config to use new API

### Issue: Deprecation warning from nvim-lspconfig
**Root cause**: Old `require('lspconfig')` API deprecated  
**Fix**: Using native `vim.lsp.start()` API

## Startup Time
- Before: ~173ms
- After: TBD

## Next Steps
- Test in real projects
- Add more LSP servers as needed
- Fine-tune completion settings
