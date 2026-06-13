require "nvchad.options"

-- Performance Optimizations for Node.js/Next.js
local o = vim.o
local opt = vim.opt

-- LSP Performance
o.updatetime = 150  -- Faster CursorHold trigger (default 4000ms too slow)
o.timeoutlen = 300  -- Faster key sequence timeout
o.ttimeoutlen = 10

-- Terminal rendering
o.ttyfast = true

-- Better completion experience
opt.completeopt = "menuone,noinsert,noselect"
o.pumheight = 10  -- Limit completion items

-- Reduce CPU usage for large files
o.lazyredraw = true  -- Don't redraw during macros (was false!)
o.synmaxcol = 200
o.redrawtime = 1000
o.maxmempattern = 1000

-- Memory optimizations
opt.hidden = true
opt.history = 100
opt.undolevels = 1000

-- Completion optimization - don't scan included files/tags
opt.complete:remove("i")
opt.complete:remove("t")

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
opt.foldmethod = "manual"  -- manual = FASTEST, use zR/zM or nvim-ufo
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
opt.signcolumn = "yes"

-- Clipboard: enable if clipboard provider is available
if vim.fn.has("unix") == 1 then
  local has_clip = vim.fn.executable("xclip") == 1 or vim.fn.executable("wl-copy") == 1
  if has_clip then
    opt.clipboard = "unnamedplus"
  else
    opt.clipboard = ""
  end
else
  opt.clipboard = "unnamedplus"
end

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

-- dart-vim-plugin disabled (using flutter-tools.nvim + conform.nvim instead)

-- ============================================
-- KOTLIN/ANDROID SPECIFIC OPTIONS
-- ============================================

-- Kotlin indent: 4 spaces (Android convention) + no-wrap + commentstring + gradle wrapper
vim.api.nvim_create_autocmd("FileType", {
  pattern = "kotlin",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.wrap = false
    vim.bo.commentstring = "// %s"
    -- Use project-local gradle wrapper
    local cwd = vim.fn.getcwd()
    local gradlew = cwd .. "/gradlew"
    if vim.fn.has("win32") == 1 then
      gradlew = cwd .. "/gradlew.bat"
    end
    if vim.fn.filereadable(gradlew) == 1 then
      vim.env.GRADLE_HOME = cwd
    end
  end,
})

  -- Kotlin: set path for Android SDK in environment
if vim.env.ANDROID_HOME == nil and vim.env.ANDROID_SDK_ROOT == nil then
  -- Try common locations
  local home = vim.env.HOME or vim.env.USERPROFILE or ""
  local sdk_paths = {
    home .. "/AppData/Local/Android/Sdk",
    home .. "/Library/Android/sdk",
    home .. "/Android/Sdk",
  }
  for _, path in ipairs(sdk_paths) do
    if vim.fn.isdirectory(path) == 1 then
      vim.env.ANDROID_HOME = path
      break
    end
  end
end
