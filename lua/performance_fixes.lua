-- Performance Fixes for Neovim Configuration
-- Add this to init.lua or load separately

-- ============================================
-- 1. DISABLE UNUSED BUILT-IN PLUGINS
-- ============================================
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
  "matchparen",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
  "editorconfig",
  "man",
  "shada",
  "spellfile",
  "remote_plugins",
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- ============================================
-- 2. ADDITIONAL PERFORMANCE OPTIONS
-- ============================================
local o = vim.o
local opt = vim.opt

-- Terminal rendering
o.ttyfast = true
o.lazyredraw = true  -- Don't redraw during macros

-- Timeout settings
o.redrawtime = 1000
o.timeoutlen = 500
o.ttimeoutlen = 10

-- File handling
o.swapfile = false
o.backup = false
o.writebackup = false

-- Memory optimization
o.maxmempattern = 1000
o.history = 100
o.undolevels = 100

-- Completion optimization
opt.complete:remove("i")  -- Don't scan included files
opt.complete:remove("t")  -- Don't scan tags (use LSP)

-- Reduce update frequency
o.updatetime = 250

-- Syntax highlighting limits
o.synmaxcol = 200

-- ============================================
-- 3. LAZY.NVIM ADDITIONAL DISABLED PLUGINS
-- ============================================
-- Merge with existing lazy.lua performance.disabled_plugins

local additional_disabled = {
  "editorconfig",
  "man",
  "shada",
  "spellfile",
  "remote_plugins",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
}

-- ============================================
-- 4. TELESCOPE PERFORMANCE
-- ============================================
local telescope_performance = {
  defaults = {
    cache_picker = {
      num_pickers = 10,  -- Cache last 10 pickers
    },
    file_ignore_patterns = {
      "node_modules",
      ".git",
      ".next",
      "dist",
      "build",
      "target",
      "%.lock",
      "__pycache__",
      "%.pyc",
    },
  },
}

-- ============================================
-- 5. LSP PERFORMANCE
-- ============================================
local lsp_performance = {
  -- Reduce diagnostic noise
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,  -- Don't steal focus
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}

-- ============================================
-- 6. TREESITTER PERFORMANCE
-- ============================================
local treesitter_performance = {
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 500 * 1024  -- 500 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname:match("node_modules") or bufname:match("build") then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
  incremental_selection = {
    enable = false,  -- Disable for performance
  },
  -- Limit parsers to what you actually use
  ensure_installed = {
    "vim", "lua", "vimdoc",
    "html", "css", "tsx", "typescript",
    "javascript", "json", "markdown",
    "dart", "go", "sql",
  },
}

-- ============================================
-- 7. GIT SIGNS PERFORMANCE
-- ============================================
local gitsigns_performance = {
  current_line_blame = false,  -- Disable for performance
  -- OR increase delay significantly:
  -- current_line_blame_opts = {
  --   delay = 1000,
  -- },
}

-- ============================================
-- 8. NVIM-TREE PERFORMANCE
-- ============================================
local nvimtree_performance = {
  git = {
    enable = false,  -- Disable git status icons
  },
  filters = {
    dotfiles = false,
    custom = { "node_modules", ".git", ".next", "dist", "build" },
  },
}

-- ============================================
-- EXPORT CONFIGURATIONS
-- ============================================
return {
  disabled_built_ins = disabled_built_ins,
  additional_disabled = additional_disabled,
  telescope = telescope_performance,
  lsp = lsp_performance,
  treesitter = treesitter_performance,
  gitsigns = gitsigns_performance,
  nvimtree = nvimtree_performance,
}
