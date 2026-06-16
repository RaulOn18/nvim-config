-- Project management configuration
local M = {}

-- Find git root (walks up to parent repo if inside submodule)
M.find_git_root = function()
  local path = vim.fn.expand("%:p:h")
  local toplevel = vim.fn.systemlist("git -C " .. path .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not toplevel then
    return nil
  end
  -- If inside submodule, --show-superproject-working-tree returns the parent repo
  local super = vim.fn.systemlist("git -C " .. path .. " rev-parse --show-superproject-working-tree")
  if super and super[1] and super[1] ~= "" then
    return super[1]
  end
  return toplevel
end

-- Project picker (vim.ui.select, backed by Telescope via ui_select)
M.project_picker = function()
  local ok = pcall(require, "project_nvim")
  if not ok then
    vim.notify("project.nvim not loaded", vim.log.levels.WARN)
    return
  end
  local history = require("project_nvim.utils.history")
  local projects = history.get_recent_projects()
  if not projects or #projects == 0 then
    vim.notify("No recent projects found", vim.log.levels.INFO)
    return
  end
  vim.ui.select(projects, { prompt = "Projects" }, function(choice)
    if choice then
      vim.cmd("cd " .. choice)
      vim.notify("Changed to: " .. choice, vim.log.levels.INFO)
    end
  end)
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
