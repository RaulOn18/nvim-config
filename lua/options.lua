require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- LSP / completion
o.updatetime = 150
o.timeoutlen = 300
o.ttimeoutlen = 10
o.pumheight = 10
opt.completeopt = "menuone,noinsert,noselect"

-- Large-file + perf
o.lazyredraw = true
o.ttyfast = true
o.synmaxcol = 200
o.redrawtime = 1000
o.maxmempattern = 2000
o.swapfile = false
o.backup = false
o.writebackup = false
opt.hidden = true
opt.history = 100
opt.complete = { ".", "w", "b", "u" }

-- Indent: 4 spaces
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- Folds: manual (cheapest), opened by default
opt.foldmethod = "manual"
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Scroll / wrap
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.signcolumn = "yes"

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Probe for system clipboard executable; configure provider if found
if vim.fn.has "clipboard" == 0 then
  local cmd
  if vim.fn.has "mac" == 1 then
    cmd = "pbcopy"
  elseif vim.fn.has "unix" == 1 then
    if vim.fn.executable "xclip" == 1 then
      cmd = "xclip"
    elseif vim.fn.executable "xsel" == 1 then
      cmd = "xsel"
    end
  elseif vim.fn.has "win32" == 1 then
    cmd = "powershell"
  end
  if cmd and vim.fn.executable(cmd) == 1 then
    vim.g.clipboard = {
      name = cmd,
      copy = { ["+"] = cmd, ["*"] = cmd },
      paste = { ["+"] = cmd, ["*"] = cmd },
    }
  end
end

-- Shell: bash on Unix, pwsh on Windows
o.shell = vim.fn.has "unix" == 1 and "/bin/bash" or "pwsh"
