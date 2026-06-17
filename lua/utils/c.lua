-- C/C++ utilities: build, run, header/source switcher
-- Reads compile_commands.json for the canonical build dir.

local M = {}

local function compile_commands_dir()
  local path = vim.fn.getcwd() .. "/compile_commands.json"
  if vim.fn.filereadable(path) == 0 then return nil end
  local lines = vim.fn.readfile(path)
  if not lines or #lines == 0 then return nil end
  local text = table.concat(lines, "\n")
  local dir = text:match('"directory"%s*:%s*"([^"]+)"')
  if dir then return dir end
  local out = text:match('"output"%s*:%s*"([^"]+)"')
  if out then return vim.fn.fnamemodify(out, ":h") end
end

function M.project_kind(cwd)
  cwd = cwd or vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then return "cmake" end
  if vim.fn.filereadable(cwd .. "/meson.build") == 1 then return "meson" end
  if vim.fn.filereadable(cwd .. "/Makefile") == 1 or vim.fn.filereadable(cwd .. "/makefile") == 1 then
    return "make"
  end
end

function M.build_dir(cwd)
  cwd = cwd or vim.fn.getcwd()
  local compile_dir = compile_commands_dir()
  if compile_dir and vim.fn.isdirectory(compile_dir) == 1 then return compile_dir end
  if vim.fn.isdirectory(cwd .. "/build") == 1 then return cwd .. "/build" end
  if vim.fn.isdirectory(cwd .. "/out") == 1 then return cwd .. "/out" end
  return cwd
end

function M.cmake_configure()
  if vim.fn.executable "cmake" == 0 then
    vim.notify "cmake not found in PATH"
    return
  end
  local build = M.build_dir()
  vim.fn.mkdir(build, "p")
  local gen = vim.fn.executable "ninja" == 1 and "Ninja" or "Unix Makefiles"
  vim.cmd("terminal cmake -S . -B " .. vim.fn.shellescape(build) .. " -G " .. gen .. " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
end

function M.build()
  local kind = M.project_kind()
  local cmd
  if kind == "cmake" then
    local build = M.build_dir()
    cmd = vim.fn.executable "ninja" == 1
        and "ninja -C " .. vim.fn.shellescape(build)
        or "cmake --build " .. vim.fn.shellescape(build) .. " --config Release"
  elseif kind == "meson" then
    cmd = vim.fn.executable "ninja" == 1 and "ninja -C build" or "meson compile -C build"
  elseif kind == "make" then
    cmd = "make -j"
  else
    vim.notify "No build system found (CMakeLists.txt / meson.build / Makefile)"
    return
  end
  vim.cmd("terminal " .. cmd)
end

function M.run(args)
  args = args or ""
  local bin = vim.fn.input("Executable: ", vim.fn.getcwd() .. "/build/", "file")
  if bin == "" then return end
  vim.cmd("terminal " .. bin .. " " .. args)
end

function M.run_with_args()
  M.run(vim.fn.input "Args: ")
end

local SOURCE_EXTS = { "c", "cpp", "cc", "cxx", "m", "mm", "C" }
local HEADER_EXTS = { "h", "hpp", "hh", "hxx", "H" }

function M.switch_header()
  local current = vim.fn.expand "%:p"
  if current == "" then
    vim.notify "No file"
    return
  end
  local ext = vim.fn.expand "%:e"
  local stem = vim.fn.fnamemodify(current, ":t"):sub(1, -#ext - 2)
  local cwd = vim.fn.getcwd()
  local from, dirs
  if vim.tbl_contains(SOURCE_EXTS, ext) then
    from, dirs = HEADER_EXTS, { vim.fn.fnamemodify(current, ":h"), "include", "../include", "src", "../src" }
  elseif vim.tbl_contains(HEADER_EXTS, ext) then
    from, dirs = SOURCE_EXTS, { vim.fn.fnamemodify(current, ":h"), "../src", "../../src", "src" }
  else
    vim.notify("Not a C/C++ file (ext: " .. ext .. ")")
    return
  end
  for _, d in ipairs(dirs) do
    local abs = d:sub(1, 1) == "/" and d or (cwd .. "/" .. d)
    for _, e in ipairs(from) do
      local found = vim.fs.find(stem .. "." .. e, { path = abs, type = "file" })
      if found[1] then
        vim.cmd.edit(vim.fn.fnameescape(found[1]))
        return
      end
    end
  end
  vim.notify "Header/source not found"
end

return M
