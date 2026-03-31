-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
  transparency = false,
  
  -- Better syntax highlighting
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    ["@keyword"] = { italic = true },
    ["@keyword.function"] = { italic = true },
    ["@keyword.return"] = { italic = true },
  },
}

-- Enable dashboard on startup (minimal config untuk v2.5)
M.nvdash = {
  load_on_startup = false,
}

-- UI enhancements
M.ui = {
  tabufline = {
    lazyload = true,
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = nil,
  },
  statusline = {
    theme = "default",
    separator_style = "default",
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
    modules = nil,
  },
  cmp = {
    style = "default",
    icons = true,
    border_color = "grey_fg",
    selected_item_bg = "colored",
  },
  telescope = {
    style = "bordered",
  },
}

-- Terminal configuration
M.term = {
  winopts = { number = false, relativenumber = false },
  sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
  float = {
    relative = "editor",
    row = 0.1,
    col = 0.1,
    width = 0.7,
    height = 0.7,
    border = "single",
  },
}

-- LSP signature help
M.lsp = {
  signature = true,
}

return M
