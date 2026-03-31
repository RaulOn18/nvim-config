-- Profile startup time (hapus baris ini setelah selesai profiling)
-- vim.g.startuptime = vim.fn.reltime()

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- Performance: faster startup
vim.opt.shadafile = "NONE"

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

-- Restore shada after plugins loaded
vim.schedule(function()
  vim.opt.shadafile = ""
  pcall(vim.cmd.rshada, { bang = true })
end)

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
