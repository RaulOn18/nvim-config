# 🚀 NvChad - Professional Neovim Configuration

[![Neovim](https://img.shields.io/badge/Neovim-0.10+-blueviolet.svg?style=for-the-badge&logo=neovim)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/Lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)](https://lua.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A **modern, modular, and blazing-fast** Neovim configuration built on top of [NvChad](https://github.com/NvChad/NvChad), optimized for **JavaScript/TypeScript**, **Go**, **Flutter**, and **Node.js** development.

![Preview](https://via.placeholder.com/800x400/1a1b26/a9b1d6?text=Neovim+Configuration+Preview)

---

## ✨ Features

- ⚡ **Fast Startup** - Lazy-loaded plugins for optimal performance
- 🎯 **LSP Ready** - Pre-configured for TypeScript, JavaScript, Go, Flutter, and more
- 🎨 **Beautiful UI** - Modern theme with customizable icons and highlights
- 🔧 **Modular Structure** - Easy to maintain and extend
- 🐛 **Debug Support** - Integrated DAP with lazy-loaded adapters
- 🌳 **File Explorer** - Oil.nvim for buffer-like file editing
- 🔍 **Fuzzy Finder** - Telescope with ripgrep integration
- 🤖 **AI Assistant** - Augment AI integration for code assistance
- 📦 **Auto-formatting** - Conform.nvim with Prettier, biome, and more

---

## 📋 Prerequisites

- [Neovim](https://neovim.io/) >= 0.10
- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (for JavaScript/TypeScript LSP)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for Telescope)
- [Nerd Font](https://www.nerdfonts.com/) (for icons)

### Optional but Recommended

- [vtsls](https://github.com/yioneko/vtsls) - TypeScript language server
- [eslint-language-server](https://www.npmjs.com/package/vscode-langservers-extracted) - ESLint LSP
- [tailwindcss-language-server](https://www.npmjs.com/package/@tailwindcss/language-server) - Tailwind support

---

## 🚀 Installation

### 1. Backup Existing Config (if any)

```bash
# Linux/Mac
mv ~/.config/nvim ~/.config/nvim.bak

# Windows (PowerShell)
Rename-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak
```

### 2. Clone This Repository

```bash
# Linux/Mac
git clone https://github.com/username/nvchad-config.git ~/.config/nvim

# Windows (PowerShell)
git clone https://github.com/username/nvchad-config.git $env:LOCALAPPDATA\nvim
```

### 3. Start Neovim

```bash
nvim
```

Lazy.nvim will automatically install all plugins on first run.

---

## 📁 Project Structure

```
.
├── init.lua                    # Entry point
├── lua/
│   ├── options.lua            # Vim options & performance settings
│   ├── mappings.lua           # Key mappings
│   ├── autocmds.lua           # Autocommands
│   ├── chadrc.lua            # NvChad UI configuration
│   ├── configs/
│   │   ├── lspconfig.lua     # LSP server configurations
│   │   ├── conform.lua       # Formatter configuration
│   │   ├── dap.lua          # Debug adapter configuration
│   │   └── lazy.lua         # Lazy.nvim settings
│   └── plugins/
│       ├── init.lua          # Plugin entry point
│       ├── core.lua          # Core dev tools (LSP, formatter, treesitter)
│       ├── git.lua           # Git integration
│       ├── navigation.lua    # File explorer, telescope
│       ├── editing.lua       # Editing enhancements
│       ├── ide.lua           # Project management, UI
│       ├── ai.lua            # AI assistants
│       ├── debug.lua         # DAP debugging
│       ├── flutter.lua       # Flutter support
│       └── markdown.lua      # Markdown support
```

---

## ⌨️ Key Mappings

### General

| Key | Description |
|-----|-------------|
| `<leader>` | Space key |
| `;` | Enter command mode |
| `jk` | Exit insert mode |
| `<C-s>` | Save file |
| `<leader>qq` | Quit all |
| `<Esc>` | Clear search highlights |

### Navigation

| Key | Description |
|-----|-------------|
| `<C-h/j/k/l>` | Navigate windows |
| `<C-Up/Down/Left/Right>` | Resize windows |
| `<C-d/u>` | Scroll with centering |
| `s` | Flash jump |
| `S` | Flash treesitter |
| `-` | Open oil.nvim (file explorer) |

### LSP

| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename |
| `<leader>f` | Format file |

### Git

| Key | Description |
|-----|-------------|
| `<leader>gg` | Open Neogit |
| `]c` / `[c` | Next/previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |

### Telescope

| Key | Description |
|-----|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fp` | Projects |

### Debug (DAP)

| Key | Description |
|-----|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue/Start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dO` | Step over |
| `<leader>du` | Toggle DAP UI |

### AI Assistant

| Key | Description |
|-----|-------------|
| `<leader>ac` | Augment Chat |
| `<leader>an` | Augment New Chat |

---

## 🎨 Customization

### Adding New Plugins

Create a new file in `lua/plugins/` or add to existing category:

```lua
-- lua/plugins/myplugin.lua
return {
  {
    "username/plugin-name",
    event = "VeryLazy",
    opts = {},
  },
}
```

### LSP Configuration

Edit `lua/configs/lspconfig.lua` to add/modify language servers:

```lua
vim.lsp.config("myserver", {
  cmd = { "myserver", "--stdio" },
  filetypes = { "myfiletype" },
  root_markers = { ".git", "config.json" },
})
```

### Key Mappings

Add custom mappings in `lua/mappings.lua`:

```lua
local map = vim.keymap.set
map("n", "<leader>xx", "<cmd>MyCommand<cr>", { desc = "My description" })
```

---

## 🔧 Language Support

| Language | LSP | Formatter | Debugger |
|----------|-----|-----------|----------|
| JavaScript/TypeScript | ✅ vtsls | ✅ prettier/biome | ✅ node2/pwa-node |
| Go | ✅ gopls | ✅ gofmt/gofumpt | ✅ delve |
| Python | ✅ pyright | ✅ black | ✅ debugpy |
| Flutter/Dart | ✅ dartls | ✅ dart_format | ✅ flutter-tools |
| CSS/SCSS | ✅ cssls | ✅ prettier | ❌ |
| HTML | ✅ html | ✅ prettier | ❌ |
| Lua | ✅ lua_ls | ✅ stylua | ❌ |

---

## ⚡ Performance Optimizations

- **Lazy Loading** - All plugins loaded on-demand
- **Treesitter** - Disabled for large files (>500KB) and node_modules
- **LSP Handlers** - Optimized diagnostic handling
- **File Watcher** - libuv-based file watching
- **Debounced Updates** - Reduced CPU usage for diagnostics

---

## 🐛 Troubleshooting

### LSP not working?

```bash
# Check if language server is installed
:Mason

# Check LSP status
:LspInfo
```

### Treesitter errors?

```vim
:TSUpdate
```

### Slow startup?

```vim
:Lazy profile
```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- [NvChad](https://github.com/NvChad/NvChad) - The base configuration
- [LazyVim Starter](https://github.com/LazyVim/starter) - Inspiration for structure
- [Neovim](https://neovim.io/) - The best editor ever

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

---

<p align="center">
  Made with 💜 and ☕
</p>
