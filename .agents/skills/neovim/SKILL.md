---
name: neovim
description: Comprehensive guide for this Neovim configuration - a modular, performance-optimized NvChad v2.5 based IDE. Use when configuring plugins, adding keybindings, setting up LSP servers, debugging, or extending the configuration. Covers lazy.nvim, NvChad UI framework, Flutter/Next.js/Go/SQL development, DAP debugging, AI integrations, and performance optimization.
---

# Neovim Configuration Skill

A NvChad v2.5 based configuration for Windows (PowerShell). Optimized for **Flutter/Dart**, **Next.js/TypeScript**, **Go**, and **SQL** development.

## Quick Reference

| Metric | Value |
|--------|-------|
| Framework | NvChad v2.5 |
| Plugin Manager | lazy.nvim |
| Leader Key | `<Space>` |
| Shell | `pwsh` (PowerShell) |
| OS | Windows |
| Theme | `ayu_dark` (transparent) |

## Architecture

```
~\AppData\Local\nvim\
├── init.lua                    # Entry point: bootstrap lazy.nvim, load NvChad, options, autocmds, mappings
├── lua/
│   ├── chadrc.lua              # NvChad UI config (theme, statusline, cmp, terminal, telescope style)
│   ├── options.lua             # Vim options (performance, tabs, folds, clipboard, split behavior)
│   ├── mappings.lua            # All keybindings (NvChad defaults + custom)
│   ├── autocmds.lua            # Autocommands (NodeJS, Flutter, SQL optimizations)
│   ├── configs/
│   │   ├── lazy.lua            # lazy.nvim settings + disabled builtins
│   │   ├── lspconfig.lua       # LSP server configs (vim.lsp.start pattern, Neovim 0.12+)
│   │   ├── conform.lua         # Formatter configs
│   │   └── dap.lua             # DAP adapter configs (JS/TS, Go)
│   ├── plugins/
│   │   ├── init.lua            # Imports all plugin categories
│   │   ├── core.lua            # LSP, conform, fidget, treesitter
│   │   ├── git.lua             # gitsigns, neogit + diffview
│   │   ├── navigation.lua      # nvim-tree, telescope, flash, grug-far, trouble
│   │   ├── editing.lua         # mini.pairs, mini.surround, ts-comments
│   │   ├── ide.lua             # project.nvim, which-key, indent-blankline, nvim-ufo
│   │   ├── ai.lua              # augment.vim
│   │   ├── debug.lua           # nvim-dap, dap-ui, dap-virtual-text
│   │   ├── flutter.lua         # flutter-tools, nvim-lightbulb, actions-preview
│   │   ├── markdown.lua        # render-markdown
│   │   └── sql.lua             # vim-dadbod, dadbod-ui, dadbod-completion, sqlls
│   └── utils/
│       └── project.lua         # Git root detection, project picker
└── lazy-lock.json              # Plugin version lock
```

## NvChad v2.5 Specifics

This config uses **NvChad v2.5** as base framework. Key differences from vanilla Neovim:

- **`chadrc.lua`** — NvChad UI configuration (theme, statusline, cmp, telescope style)
- **`nvchad.plugins`** — NvChad's built-in plugins imported in `init.lua`
- **`require "nvchad.options"`** — NvChad default options loaded in `options.lua`
- **`require "nvchad.mappings"`** — NvChad default keybindings loaded in `mappings.lua`
- **`require "nvchad.autocmds"`** — NvChad default autocommands loaded in `autocmds.lua`
- **`vim.g.base46_cache`** — NvChad theme cache directory
- **NvChad UI components**: statusline, tabufline (buffer tabs), nvdash, cmp styling all configured via `chadrc.lua`

### NvChad Built-in Features

NvChad provides out of the box:
- Statusline (`nvchad.statusline`)
- Buffer tab bar (`nvchad.tabufline`)
- Dashboard (`nvdash`)
- Theme system (`base46`)
- LSP defaults (`nvchad.configs.lspconfig`)
- Completion defaults (`nvchad.configs.cmp`)

### Extending NvChad

Override NvChad defaults in `chadrc.lua`:

```lua
-- lua/chadrc.lua
local M = {}

M.base46 = {
  theme = "ayu_dark",
  transparency = true,
  hl_override = {
    Comment = { italic = true },
  },
}

M.ui = {
  statusline = { ... },
  telescope = { style = "bordered" },
}

return M
```

## Keybindings

### Core Navigation (mappings.lua)

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Window navigation |
| `<C-Up/Down/Left/Right>` | Resize windows |
| `<S-h>` / `<S-l>` | Previous/next buffer |
| `;` | Enter command mode (`:`) |
| `jk` | Exit insert mode |
| `<C-s>` | Save file (all modes) |
| `<Esc>` | Clear search highlights |

### File Explorer & Telescope

| Key | Action |
|-----|--------|
| `<C-n>` / `<leader>e` | Toggle NvimTree |
| `<leader>E` | Find file in tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fo` | Recent files |
| `<leader>fc` | Grep string under cursor |
| `<leader>fr` | Resume last search |
| `<leader>fk` | Find keymaps |
| `<leader>fC` | Find commands |
| `<leader>fp` | Find projects |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open Neogit |
| `<leader>gd` | Diffview open |
| `<leader>gD` | Diffview close |
| `<leader>gh` | File history |
| `<leader>gb` | Git branches |
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |
| `<leader>hs/hr` | Stage/reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>tbl` | Toggle line blame |
| `]c` / `[c` | Next/prev hunk |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition (native jump) |
| `gD` | Go to declaration (fallback to definition) |
| `<leader>gD` | Definition picker (Telescope) |
| `gr` | Find references (Telescope) |
| `gI` | Go to implementation |
| `gy` | Type definition |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cd` | Line diagnostics |
| `<leader>cl` | LSP Info |
| `[d` / `]d` | Prev/next diagnostic |

### Search & Replace

| Key | Action |
|-----|--------|
| `<leader>sr` | Search and replace (grug-far) |
| `<leader>sw` | Replace word under cursor |
| `gs` | Flash jump |
| `S` | Flash treesitter |

### Diagnostics (Trouble)

| Key | Action |
|-----|--------|
| `<leader>dd` | All diagnostics |
| `<leader>db` | Buffer diagnostics |
| `<leader>ds` | Symbols |

### Buffer & Quit

| Key | Action |
|-----|--------|
| `<leader>bd` | Close buffer |
| `<leader>bo` | Close other buffers |
| `<leader>qq` | Quit all |
| `<leader>qQ` | Force quit all |

### DAP Debugging

| Key | Action |
|-----|--------|
| `<leader>dc` | Continue/Start |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>di` | Step into |
| `<leader>dO` | Step over |
| `<leader>do` | Step out |
| `<leader>du` | Toggle DAP UI |
| `<leader>dr` | Toggle REPL |
| `<leader>dt` | Terminate |

### Flutter (only in Dart files)

| Key | Action |
|-----|--------|
| `<leader>Fr` | Flutter run |
| `<leader>FR` | Flutter restart |
| `<leader>Fq` | Flutter quit |
| `<leader>Fc` | Hot reload |
| `<leader>Ft` | Flutter commands (Telescope) |
| `<leader>fe` | Extract widget/method |
| `<leader>fx` | Quick fix |

### SQL

| Key | Action |
|-----|--------|
| `<leader>Du` | Toggle DB UI |
| `<leader>Df` | Find DB buffer |
| `<leader>Dr` | Rename DB buffer |
| `<leader>Dq` | Last query info |

### AI (Augment)

| Key | Action |
|-----|--------|
| `<leader>ac` | Augment chat |
| `<leader>an` | New chat |
| `<leader>at` | Toggle chat |
| `<leader>as` | Status |
| `<leader>al` | List chats |

### Formatting

| Key | Action |
|-----|--------|
| `<leader>cf` | Format selection |
| `<leader>cF` | Format file |
| `<leader>cd` | Line diagnostics float |

### Projects

| Key | Action |
|-----|--------|
| `<leader>fp` | Find projects (Telescope) |
| `<leader>cd` | CD to git root |

## LSP Configuration

Uses **custom `vim.lsp.start()` pattern** (Neovim 0.12+), NOT the old `lspconfig[server].setup()` pattern.

### Config File: `lua/configs/lspconfig.lua`

Pattern:

```lua
local M = {}

M.setup_lsp("server_name", {
  cmd = { "server", "--stdio" },
  filetypes = { "filetype1", "filetype2" },
  settings = { ... },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
  end,
})

-- Diagnostic config at bottom
vim.diagnostic.config { ... }

return M
```

### Configured LSP Servers

| Server | Filetypes |
|--------|----------|
| `vtsls` | javascript, javascriptreact, typescript, typescriptreact |
| `eslint` | javascript, javascriptreact, typescript, typescriptreact, vue, svelte |
| `tailwindcss` | html, css, scss, javascript, javascriptreact, typescript, typescriptreact |
| `html` | html |
| `cssls` | css, scss, less |
| `gopls` | go, gomod, gowork, gotmpl |
| `sqlls` | sql, mysql |
| `dartls` | dart (via flutter-tools.nvim, NOT in lspconfig.lua) |

### Adding a New LSP Server

In `lua/configs/lspconfig.lua`:

```lua
M.setup_lsp("server_name", {
  cmd = { "server", "--stdio" },
  filetypes = { "your_filetype" },
  settings = {
    -- Server settings
  },
})
```

Mason auto-install is NOT configured. Install servers manually via `:Mason` or system package manager.

## Formatter Configuration

### Config File: `lua/configs/conform.lua`

| Filetype | Formatter |
|----------|-----------|
| lua | stylua |
| css, html | prettier |
| javascript, typescript, jsx, tsx | prettier |
| json, jsonc | prettier |
| markdown | prettier |
| dart | dart_format (`dart format`) |

**Format on save: DISABLED.** Use `<leader>cf` (selection) or `<leader>cF` (file) manually.

### Adding a Formatter

```lua
-- In lua/configs/conform.lua
formatters_by_ft = {
  your_filetype = { "formatter_name" },
},
formatters = {
  formatter_name = {
    command = "formatter_cmd",
    args = { "--flag", "$FILENAME" },
  },
},
```

## Plugin Categories

### Core (4 plugins) — `plugins/core.lua`
- `stevearc/conform.nvim` — Formatting
- `neovim/nvim-lspconfig` — LSP (lazy=false, priority=1000)
- `j-hui/fidget.nvim` — LSP progress (on LspAttach)
- `nvim-treesitter/nvim-treesitter` — Syntax (vim, lua, vimdoc, html, css, tsx, typescript, javascript, json, markdown, dart, go, sql)

### Git (2 plugins) — `plugins/git.lua`
- `lewis6991/gitsigns.nvim` — Git signs + hunk actions
- `NeogitOrg/neogit` — Git UI (with diffview + telescope integration)

### Navigation (5 plugins) — `plugins/navigation.lua`
- `nvim-tree/nvim-tree.lua` — File explorer (cmd/keys loaded)
- `nvim-telescope/telescope.nvim` — Fuzzy finder (with fzf-native, ui-select)
- `folke/flash.nvim` — Fast navigation
- `MagicDuck/grug-far.nvim` — Async search & replace
- `folke/trouble.nvim` — Diagnostics list

### Editing (3 plugins) — `plugins/editing.lua`
- `echasnovski/mini.pairs` — Auto brackets
- `echasnovski/mini.surround` — Surround (gsa/gsd/gsf/gsr/gsh)
- `folke/ts-comments.nvim` — Better comments

### IDE (4 plugins) — `plugins/ide.lua`
- `ahmedkhalf/project.nvim` — Project management (pattern detection: .git, package.json, etc.)
- `folke/which-key.nvim` — Keybinding discoverability
- `lukas-reineke/indent-blankline.nvim` — Indent guides
- `kevinhwang91/nvim-ufo` — Code folding (treesitter + indent)

### AI (1 plugin) — `plugins/ai.lua`
- `augmentcode/augment.vim` — AI assistant (cmd/keys loaded)

### Debug (3 plugins) — `plugins/debug.lua`
- `mfussenegger/nvim-dap` — DAP core (JS/TS via node2/pwa-node, Go via delve)
- `rcarriga/nvim-dap-ui` — Debug UI (auto open/close on session)
- `theHamsta/nvim-dap-virtual-text` — Inline debug values

### Flutter (3 plugins) — `plugins/flutter.lua`
- `nvim-flutter/flutter-tools.nvim` — Flutter IDE (ft=dart, with widget guides, closing tags, debugger)
- `kosayoda/nvim-lightbulb` — Code action lightbulb
- `aznhe21/actions-preview.nvim` — Code action preview UI

### Markdown (1 plugin) — `plugins/markdown.lua`
- `MeanderingProgrammer/render-markdown.nvim` — Markdown rendering (ft=markdown)

### SQL (4 plugins) — `plugins/sql.lua`
- `tpope/vim-dadbod` — Database client
- `kristijanhusak/vim-dadbod-ui` — DB UI
- `kristijanhusak/vim-dadbod-completion` — SQL completion
- sqlls configured via lspconfig

## Performance Optimizations

### In `options.lua`

- `updatetime = 250` (faster CursorHold events)
- `lazyredraw = true` (skip redraw during macros)
- `synmaxcol = 200` (limit syntax highlighting columns)
- Disabled providers: perl, ruby, node
- `completeopt` optimized for completion
- Reduced undo/swap/backup overhead

### In `lua/configs/lazy.lua`

Disabled built-in plugins: netrw, matchit, tar/zip plugins, tutor, rplugin, syntax, ftplugin, etc.

### In `autocmds.lua`

- `node_modules/` — readonly, not buflisted
- Large files (>1MB) — syntax off, foldmethod manual
- `vtsls` — semantic tokens disabled
- Flutter build/cache dirs — readonly, syntax off
- Large Dart files (>500KB) — syntax off

### Treesitter Parsers

Installed: vim, lua, vimdoc, html, css, tsx, typescript, javascript, json, markdown, markdown_inline, dart, go, sql

### In `init.lua`

- `vim.opt.shadafile = "NONE"` — No session persistence
- Disabled builtins: fzf, man, remote_plugins
- Shell: `pwsh`

## Common Tasks

### Adding a Plugin

Add to appropriate file in `lua/plugins/`:

```lua
-- lua/plugins/ide.lua (or create new category file)
return {
  {
    "author/plugin-name",
    event = "VeryLazy",  -- or cmd, keys, ft
    opts = { ... },
    dependencies = { "dep/name" },
  },
}

-- If new file, add import to lua/plugins/init.lua:
{ import = "plugins.your_category" },
```

### Adding Keybindings

In `lua/mappings.lua`:

```lua
map("n", "<leader>xx", "<cmd>Command<cr>", { desc = "Description" })
```

Or in plugin spec `keys = { ... }`.

### Adding an Autocommand

In `lua/autocmds.lua`:

```lua
local group = augroup("GroupName", { clear = true })
autocmd("EventName", {
  group = group,
  pattern = "*.ext",
  callback = function(args) ... end,
})
```

## Split Management

| Key | Action |
|-----|--------|
| `<C-w>v` | Vertical split |
| `<C-w>s` | Horizontal split |
| `<C-w>c` | Close split |
| `<C-w>o` | Close all other splits |
| `<C-h/j/k/l>` | Navigate splits |
| `<C-Up/Down/Left/Right>` | Resize splits |

Telescope: `<C-x>` horizontal split, `<C-v>` vertical split, `<C-t>` new tab.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Plugins not loading | `:Lazy sync` |
| LSP not starting | `:LspInfo`, `:Mason` |
| Icons missing | Install a Nerd Font |
| Slow startup | `:Lazy profile` |
| Treesitter errors | `:TSUpdate` |
| Keybinding conflicts | `:verbose map <key>` |
| NvChad UI broken | Check `chadrc.lua` structure matches [nvconfig.lua](https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua) |
| LSP deprecation warning | Normal — config suppresses it via notify override |
| Flutter tools not loading | Check `pubspec.yaml` exists in project root |

## Gotchas

- **NvChad v2.5 specific:** `chadrc.lua` structure must match `nvconfig.lua` from NvChad UI repo. Wrong keys = silent failure.
- **`vim.lsp.start()` pattern:** This config does NOT use `lspconfig[server].setup()`. Uses custom `M.setup_lsp()` that registers FileType autocmds. Add servers in `configs/lspconfig.lua`, not in plugin specs.
- **Flutter LSP:** Dart LSP is managed by `flutter-tools.nvim`, NOT by `configs/lspconfig.lua`. Flutter tools check for `pubspec.yaml` before activating.
- **Format on save DISABLED:** Must use `<leader>cf`/`<leader>cF` manually. Conform ignores format_on_save for JS/TS/Lua/Dart.
- **Mason NOT auto-installing:** Servers must be installed manually. No `ensure_installed` list.
- **`lazy-lock.json` silently pins everything:** `:Lazy sync` only installs missing. `:Lazy update` needed for updates.
- **Treesitter ABI:** After Neovim upgrade, `:TSUpdate` mandatory.
- **Windows paths:** Config uses Windows path conventions. `pwsh` as shell.
- **`shadafile = "NONE"`:** No session persistence. Cursor positions, marks, registers not saved between sessions.
- **project.nvim `manual_mode = true`:** Does NOT auto-change directory. Use `<leader>cd` to cd to git root manually, or `<leader>fp` to pick project.
- **`node_provider` disabled:** Node.js provider disabled for performance. If you need Node plugins, re-enable in `options.lua`.
