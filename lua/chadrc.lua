---@type ChadrcConfig
local M = {}

local function set_file_header(args)
  local win = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(win)
  local buftype = vim.bo[args.buf].buftype

  -- Floating pickers need every available row; winbar can trigger E36 there.
  if config.relative ~= "" or buftype ~= "" then
    vim.wo[win].winbar = ""
    return
  end

  local name = vim.api.nvim_buf_get_name(args.buf)
  local display = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
  local icon = "󰈔"
  vim.wo[win].winbar = "  " .. icon .. "  " .. display .. "  %="
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("FileHeader", { clear = true }),
  callback = function(args)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) and vim.api.nvim_win_is_valid(vim.api.nvim_get_current_win()) then
        set_file_header(args)
      end
    end)
  end,
})

M.base46 = {
  theme = "material-deep-ocean",
  transparency = true,
  hl_override = {
    Comment = { italic = true },
    WinBar = { fg = "#8be9fd", bg = "#1b2030", bold = true },
    WinBarNC = { fg = "#6272a4", bg = "#171a26" },
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
  tabufline = {
    enabled = false,
  },
  statusline = {
    theme = "vscode",
    separator_style = "round",
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
