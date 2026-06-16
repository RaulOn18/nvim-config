require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Node.js/Next.js Performance Autocmds
local nodejs_group = augroup("NodeJSOptimizations", { clear = true })

-- Disable formatting for node_modules
autocmd({ "BufRead", "BufNewFile" }, {
  group = nodejs_group,
  pattern = "*/node_modules/*",
  callback = function()
    vim.opt_local.readonly = true
    vim.opt_local.modifiable = false
    vim.opt_local.buflisted = false
  end,
})

-- Large file optimizations (>1MB) - all filetypes
autocmd("BufReadPre", {
  group = nodejs_group,
  pattern = "*",
  callback = function(args)
    local fname = vim.api.nvim_buf_get_name(args.buf)
    if fname == "" or fname:match("^%w+://") then return end
    local ok, stats = pcall(vim.uv.fs_stat, fname)
    if ok and stats and stats.size > 1024 * 1024 then
      vim.opt_local.syntax = "off"
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = -1
      vim.opt_local.swapfile = false
      vim.notify("Large file detected - optimizations applied", vim.log.levels.INFO)
    end
  end,
})

-- Auto-generated/build folders - readonly, no LSP
autocmd({ "BufRead", "BufNewFile" }, {
  group = nodejs_group,
  pattern = {
    "*/build/*",
    "*/.gradle/*",
    "*/.idea/*",
    "*/.kotlin/*",
    "*/.navigation/*",
    "*/.dart_tool/*",
    "*/.flutter-plugins*",
    "*/.pub-cache/*",
    "*/.flutter/*",
  },
  callback = function()
    vim.opt_local.readonly = true
    vim.opt_local.modifiable = false
    vim.opt_local.buflisted = false
    vim.opt_local.syntax = "off"
  end,
})

-- ============================================
-- C/C++ FILTYPE SETTINGS
-- ============================================
local c_group = augroup("CFiletypeSettings", { clear = true })

-- GCC/Clang/MSVC errorformat for :make + quickfix
local C_ERRORFORMAT = table.concat({
  "%f:%l:%c: %trror: %m",
  "%f:%l:%c: %tarning: %m",
  "%f:%l:%c: %tote: %m",
  "%f:%l: %trror: %m",
  "%f:%l: %tarning: %m",
  "%f(%l): %trror: %m",       -- MSVC cl.exe
  "%f(%l,%c): %trror: %m",    -- MSVC alternative
  "%f:%l: %m",
}, ",")

autocmd("FileType", {
  group = c_group,
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.commentstring = "// %s"
    -- :make integration: route to CMake/Make
    local cwd = vim.fn.getcwd()
    if vim.fn.filereadable(cwd .. "/compile_commands.json") == 1
        or vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
      vim.opt_local.makeprg = "cmake --build build"
    elseif vim.fn.filereadable(cwd .. "/Makefile") == 1 then
      vim.opt_local.makeprg = "make"
    end
    vim.opt_local.errorformat = C_ERRORFORMAT
  end,
})

-- Disable LSP / readonly in vendored third-party C/C++ (common in CMake builds)
autocmd({ "BufRead", "BufNewFile" }, {
  group = c_group,
  pattern = { "*/_deps/*", "*/third_party/*", "*/external/*" },
  callback = function()
    vim.opt_local.readonly = true
    vim.opt_local.modifiable = false
    vim.opt_local.buflisted = false
  end,
})

-- ============================================
-- KOTLIN/ANDROID
-- ============================================
local kotlin_group = augroup("KotlinFiletypeSettings", { clear = true })

autocmd("FileType", {
  group = kotlin_group,
  pattern = "kotlin",
  callback = function()
    -- Android convention: 4 spaces, no wrap, // comments
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.wrap = false
    vim.bo.commentstring = "// %s"
    -- Use project-local gradle wrapper when present
    local cwd = vim.fn.getcwd()
    local gradlew = cwd .. "/" .. (vim.fn.has("win32") == 1 and "gradlew.bat" or "gradlew")
    if vim.fn.filereadable(gradlew) == 1 then
      vim.env.GRADLE_HOME = cwd
    end
  end,
})

-- Android SDK: set ANDROID_HOME if not already set
if vim.env.ANDROID_HOME == nil and vim.env.ANDROID_SDK_ROOT == nil then
  local home = vim.env.HOME or vim.env.USERPROFILE or ""
  for _, path in ipairs {
    home .. "/AppData/Local/Android/Sdk",
    home .. "/Library/Android/sdk",
    home .. "/Android/Sdk",
  } do
    if vim.fn.isdirectory(path) == 1 then
      vim.env.ANDROID_HOME = path
      break
    end
  end
end


