-- C/C++ utilities: build, run, header/source switcher
-- Auto-detects CMake / Meson / Make and uses Ninja when available

local M = {}

-- ============================================================================
-- Project detection
-- ============================================================================
function M.project_kind(cwd)
  cwd = cwd or vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
    return "cmake"
  elseif vim.fn.filereadable(cwd .. "/meson.build") == 1 then
    return "meson"
  elseif vim.fn.filereadable(cwd .. "/Makefile") == 1 or vim.fn.filereadable(cwd .. "/makefile") == 1 then
    return "make"
  end
  return nil
end

function M.build_dir(cwd)
  cwd = cwd or vim.fn.getcwd()
  if vim.fn.isdirectory(cwd .. "/build") == 1 then return cwd .. "/build" end
  if vim.fn.isdirectory(cwd .. "/out") == 1 then return cwd .. "/out" end
  return cwd
end

-- ============================================================================
-- Configure
-- ============================================================================
function M.cmake_configure()
  local cwd = vim.fn.getcwd()
  if vim.fn.executable("cmake") == 0 then
    vim.notify("cmake not found in PATH", vim.log.levels.ERROR)
    return
  end
  local build = M.build_dir(cwd)
  vim.fn.mkdir(build, "p")
  local generator = vim.fn.executable("ninja") == 1 and "Ninja" or "NMake Makefiles"
  local cmd = string.format('cd /d "%s" && cmake -S . -B "%s" -G %s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON',
    cwd, build, generator)
  vim.cmd("terminal " .. cmd)
end

-- ============================================================================
-- Build
-- ============================================================================
function M.build()
  local cwd = vim.fn.getcwd()
  local kind = M.project_kind(cwd)
  local cmd
  if kind == "cmake" then
    local build = M.build_dir(cwd)
    if vim.fn.executable("ninja") == 1 then
      cmd = string.format('cd /d "%s" && ninja -C "%s"', cwd, build)
    else
      cmd = string.format('cd /d "%s" && cmake --build "%s" --config Release', cwd, build)
    end
  elseif kind == "meson" then
    if vim.fn.executable("ninja") == 1 then
      cmd = string.format('cd /d "%s" && ninja -C build', cwd)
    else
      cmd = string.format('cd /d "%s" && meson compile -C build', cwd)
    end
  elseif kind == "make" then
    cmd = string.format('cd /d "%s" && make -j', cwd)
  else
    vim.notify("No build system found (CMakeLists.txt / meson.build / Makefile)", vim.log.levels.WARN)
    return
  end
  vim.cmd("terminal " .. cmd)
end

-- ============================================================================
-- Run: find binary from compile_commands or prompt
-- ============================================================================
function M.find_binary()
  local cc = vim.fn.findfile("compile_commands.json", vim.fn.getcwd() .. ";")
  if cc == "" then return nil end
  local f = io.open(cc, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  -- Naive regex: capture first "output" field (relative path is rare; usually absolute)
  local output = content:match('"output"%s*:%s*"([^"]+)"')
  if output and vim.fn.filereadable(output) == 1 then return output end
  return nil
end

function M.run(args)
  args = args or ""
  local cwd = vim.fn.getcwd()
  local bin = M.find_binary() or vim.fn.input("Executable: ", cwd .. "/build/", "file")
  if bin == "" or not bin then return end
  -- Quote path for safety on Windows
  local cmd = string.format('cd /d "%s" && "%s" %s', cwd, bin, args)
  vim.cmd("terminal " .. cmd)
end

function M.run_with_args()
  local args = vim.fn.input("Args: ")
  M.run(args)
end

-- ============================================================================
-- Header <-> source switcher
-- ============================================================================
local SOURCE_EXTS = { "c", "cpp", "cc", "cxx", "m", "mm", "C" }
local HEADER_EXTS = { "h", "hpp", "hh", "hxx", "H" }

function M.switch_header()
  local current = vim.fn.expand("%:p")
  if current == "" or current == nil then
    vim.notify("No file", vim.log.levels.WARN)
    return
  end
  local ext = vim.fn.expand("%:e")
  local target

  local function exists(p)
    return p and p ~= "" and vim.fn.filereadable(p) == 1
  end

  if vim.tbl_contains(SOURCE_EXTS, ext) then
    -- Source -> header: same dir, then include/, ../include, src/
    local base = current:sub(1, -#ext - 2)
    for _, hdr in ipairs(HEADER_EXTS) do
      if exists(base .. hdr) then target = base .. hdr; break end
    end
    if not target then
      local basename = vim.fn.fnamemodify(current, ":t"):sub(1, -#ext - 2)
      for _, dir in ipairs({ "include", "../include", "src", "../src" }) do
        for _, hdr in ipairs(HEADER_EXTS) do
          local candidate = vim.fn.getcwd() .. "/" .. dir .. "/" .. basename .. "." .. hdr
          if exists(candidate) then target = candidate; break end
        end
        if target then break end
      end
    end
  elseif vim.tbl_contains(HEADER_EXTS, ext) then
    -- Header -> source: same dir, ../src, ../../src
    local dir = vim.fn.fnamemodify(current, ":h")
    local stem = vim.fn.fnamemodify(current, ":t"):sub(1, -#ext - 2)
    local search_dirs = { dir, dir .. "/../src", dir .. "/../../src", dir .. "/src" }
    for _, d in ipairs(search_dirs) do
      for _, s in ipairs(SOURCE_EXTS) do
        if exists(d .. "/" .. stem .. "." .. s) then target = d .. "/" .. stem .. "." .. s; break end
      end
      if target then break end
    end
  else
    vim.notify("Not a C/C++ file (ext: " .. tostring(ext) .. ")", vim.log.levels.WARN)
    return
  end

  if target then
    vim.cmd("edit " .. vim.fn.fnameescape(target))
  else
    vim.notify("Header/source not found", vim.log.levels.WARN)
  end
end

return M
