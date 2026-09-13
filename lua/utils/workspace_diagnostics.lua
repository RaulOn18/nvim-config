local M = {}

local severity = vim.diagnostic.severity
local roots = {}
local redraw_pending = false

local function new_state()
  return {
    buffers = {},
    diagnostics = {},
    counts = { [severity.ERROR] = 0, [severity.WARN] = 0, [severity.INFO] = 0, [severity.HINT] = 0 },
  }
end

local function root_for_buffer(bufnr)
  return vim.fs.root(bufnr, { ".git" }) or vim.fn.getcwd()
end

local function belongs_to_root(root, bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name ~= "" and vim.fs.relpath(root, name) ~= nil
end

local function tally(diagnostics)
  local result = { [severity.ERROR] = 0, [severity.WARN] = 0, [severity.INFO] = 0, [severity.HINT] = 0 }
  for _, diagnostic in ipairs(diagnostics) do
    result[diagnostic.severity] = (result[diagnostic.severity] or 0) + 1
  end
  return result
end

local function replace_buffer(root, bufnr, diagnostics)
  local state = roots[root]
  if not state then
    return
  end

  local old = state.buffers[bufnr] or {}
  local new = tally(diagnostics)
  for level, count in pairs(old) do
    state.counts[level] = state.counts[level] - count
  end
  for level, count in pairs(new) do
    state.counts[level] = state.counts[level] + count
  end
  state.buffers[bufnr] = new
  state.diagnostics[bufnr] = diagnostics
end

local function refresh(root)
  local state = new_state()
  roots[root] = state
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if belongs_to_root(root, bufnr) then
      replace_buffer(root, bufnr, vim.diagnostic.get(bufnr))
    end
  end
  return state
end

local function schedule_redraw()
  if redraw_pending then
    return
  end
  redraw_pending = true
  vim.schedule(function()
    redraw_pending = false
    vim.cmd.redrawstatus()
  end)
end

local group = vim.api.nvim_create_augroup("WorkspaceDiagnosticStatus", { clear = true })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = group,
  callback = function(args)
    local root = root_for_buffer(args.buf)
    if roots[root] then
      replace_buffer(root, args.buf, vim.diagnostic.get(args.buf))
    end
    schedule_redraw()
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = group,
  callback = function(args)
    local root = root_for_buffer(args.buf)
    local state = roots[root]
    if state and state.buffers[args.buf] then
      replace_buffer(root, args.buf, {})
      state.buffers[args.buf] = nil
      state.diagnostics[args.buf] = nil
    end
    schedule_redraw()
  end,
})

local function state_for_buffer(bufnr)
  local root = root_for_buffer(bufnr)
  return root, roots[root] or refresh(root)
end

function M.statusline()
  local statusline_win = vim.g.statusline_winid or 0
  if not vim.api.nvim_win_is_valid(statusline_win) then
    statusline_win = 0
  end
  local root, state = state_for_buffer(vim.api.nvim_win_get_buf(statusline_win))

  local items = {
    { severity.ERROR, "%#St_lspError#", " " },
    { severity.WARN, "%#St_lspWarning#", " " },
    { severity.INFO, "%#St_lspInfo#", "󰋼 " },
    { severity.HINT, "%#St_lspHints#", "󰛩 " },
  }
  local result = " "
  for _, item in ipairs(items) do
    local count = state.counts[item[1]]
    if count > 0 then
      result = result .. item[2] .. item[3] .. count .. " "
    end
  end
  return result
end

function M.open_list()
  local statusline_win = vim.g.statusline_winid or 0
  if not vim.api.nvim_win_is_valid(statusline_win) then
    statusline_win = 0
  end
  local _, state = state_for_buffer(vim.api.nvim_win_get_buf(statusline_win))
  local diagnostics = {}
  for _, buffer_diagnostics in pairs(state.diagnostics) do
    vim.list_extend(diagnostics, buffer_diagnostics)
  end

  vim.fn.setqflist({}, " ", {
    title = "Workspace Diagnostics",
    items = vim.diagnostic.toqflist(diagnostics),
  })
  vim.cmd "botright copen"
end

return M
