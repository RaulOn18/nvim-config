-- Project management configuration
local M = {}

-- Find git root
M.find_git_root = function()
  local path = vim.fn.expand("%:p:h")
  local git_root = vim.fn.systemlist("git -C " .. path .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 then
    return git_root
  end
  return nil
end

-- Telescope projects picker
M.project_picker = function()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    vim.notify("Telescope not loaded", vim.log.levels.WARN)
    return
  end
  
  telescope.extensions.projects.projects({})
end

-- Auto change directory to git root
M.auto_cd_git_root = function()
  local git_root = M.find_git_root()
  if git_root then
    vim.cmd("cd " .. git_root)
    vim.notify("Changed to project root: " .. git_root, vim.log.levels.INFO)
  end
end

return M
