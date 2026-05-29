-- Profile startup time (hapus baris ini setelah selesai profiling)
-- vim.g.startuptime = vim.fn.reltime()

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable shada (no session persistence)
vim.opt.shadafile = "NONE"

-- Performance: Disable unused built-in plugins
-- vim.g.did_load_filetypes = 1  -- REMOVED: breaks filetype detection
vim.g.did_load_fzf = 1
vim.g.loaded_man = 1
vim.g.loaded_remote_plugins = 1

-- Performance: Disable swap/backup files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Basic settings
vim.opt.relativenumber = true
vim.opt.number = true
vim.o.shell = "pwsh"
