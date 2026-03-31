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
