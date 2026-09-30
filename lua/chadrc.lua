---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "material-deep-ocean",
  transparency = true,
  hl_override = {
    Comment = { italic = true },
    StatusLine = { bg = "#171a26" },
    StatusLineNC = { bg = "#171a26" },
    ["@comment"] = { italic = true },
    ["@keyword"] = { italic = true },
    ["@keyword.function"] = { italic = true },
    ["@keyword.return"] = { italic = true },
    ["@keyword.kotlin"] = { italic = true },
    ["@function.kotlin"] = { italic = false },
    ["@type.kotlin"] = { bold = true },
    ["@lsp.type.class.kotlin"] = { bold = true },
    ["@lsp.type.function.kotlin"] = { italic = false },
    ["@lsp.type.property.kotlin"] = { link = "@property" },
    ["@lsp.type.annotation.kotlin"] = { link = "@attribute" },
    ["@lsp.type.parameter.kotlin"] = { italic = true },
  },
}

M.ui = {
  -- Use NvChad's native per-tab bufferline and mappings.
  tabufline = {
    enabled = true,
    lazyload = true,
    bufwidth = 24,
  },
  statusline = {
    theme = "default",
    separator_style = "default",
    order = { "mode", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
    modules = { diagnostics = function() return require("utils.workspace_diagnostics").statusline() end },
  },
}

M.term = {
  winopts = { number = false, relativenumber = false },
  sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
  float = {
    relative = "editor", row = 0.1, col = 0.1,
    width = 0.7, height = 0.7, border = "single",
  },
}

M.lsp = { signature = true }

return M
