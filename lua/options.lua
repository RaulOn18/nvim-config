require "nvchad.options"

-- Performance Optimizations for Node.js/Next.js
local o = vim.o
local opt = vim.opt

-- LSP Performance
o.updatetime = 250  -- Faster completion (default 4000ms too slow)
o.timeoutlen = 500
o.ttimeoutlen = 10

-- Better completion experience
opt.completeopt = "menuone,noinsert,noselect"
o.pumheight = 10  -- Limit completion items

-- Reduce CPU usage for large files
o.lazyredraw = false
o.synmaxcol = 200

-- Memory optimizations
opt.hidden = true
opt.history = 100
opt.undolevels = 100

-- Disable providers yang tidak digunakan (speedup startup)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Python provider (biarkan jika butuh, atau set path jika ada)
-- vim.g.python3_host_prog = 'C:\\Python311\\python.exe'

-- Tab settings: 4 spaces
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- ============================================
-- FLUTTER/DART SPECIFIC OPTIONS
-- ============================================

-- Dart/Flutter specific: fold settings untuk widget tree
opt.foldmethod = "syntax"
opt.foldlevel = 99  -- Open semua fold by default
opt.foldlevelstart = 99

-- Better scrolling untuk file Dart yang panjang
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Wrap lines untuk Dart (banyak nested widgets)
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

-- Sign column untuk LSP diagnostics (Flutter banyak warning/error saat dev)
opt.signcolumn = "yes:2"

-- Clipboard untuk copy-paste code snippets Flutter
opt.clipboard = "unnamedplus"

-- Better search untuk Flutter projects
opt.ignorecase = true
opt.smartcase = true

-- Split behavior untuk Flutter (sering buka banyak file)
opt.splitbelow = true
opt.splitright = true

-- ============================================
-- FLUTTER/DART GLOBAL VARIABLES
-- ============================================

-- Flutter tools specific settings
vim.g.flutter_tools_log_level = "WARN"  -- Reduce log spam
vim.g.flutter_show_log_on_run = "error"  -- Only show log on error

-- Dart fmt settings
vim.g.dart_format_on_save = 1  -- Handled by conform.nvim atau LSP
vim.g.dart_style_guide = 2  -- 2-space indent untuk Dart (Flutter standard)

-- Disable dart-vim-plugin built-in LSP kalau ada (conflict dengan flutter-tools)
vim.g.dart_style_guide = 0
vim.g.dart_format_on_save = 0
