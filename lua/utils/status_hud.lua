-- Animated statusline HUD: pi.nvim loader + LSP progress
-- - pi: pixel-chase animation + status-aware nerd-font icon + label
-- - lsp: braille spinner + client/title/percentage
-- One shared uv timer, only ticking while something is actually animating.

local M = {}

-- === Animations ==============================================
-- pi: 3-pixel chase (blocks rotate around a 3x1 pixel strip)
local pi_frames = { "▖▘▝", "▘▝▗", "▝▗▖", "▗▖▘" }
-- lsp: braille dots
local lsp_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

-- pi status -> icon + label (terminal-hack style)
local pi_labels = {
  collecting_context = { icon = "󰍛", text = "reading context" },
  starting = { icon = "󰐊", text = "starting" },
  thinking = { icon = "󰧑", text = "thinking" },
  running_tool = { icon = "󰚩", text = "running" },
}

local LSP_ICON = "󰒋"
local INTERVAL_MS = 90

-- === State ===================================================
local pi_idx = 1
local lsp_idx = 1
local lsp_progress = nil -- display string, nil when idle
local timer = nil

local function ensure_hl()
  if vim.fn.hlexists "HudPi" == 0 then
    vim.api.nvim_set_hl(0, "HudPi", { link = "Special", default = true })
  end
  if vim.fn.hlexists "HudLsp" == 0 then
    vim.api.nvim_set_hl(0, "HudLsp", { link = "DiagnosticInfo", default = true })
  end
end

local function stop_timer()
  if timer then
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
    timer = nil
  end
end

local function something_active()
  local ok, pi = pcall(require, "pi")
  return (ok and pi.is_running()) or lsp_progress ~= nil
end

local function start_timer()
  if timer then
    return
  end
  timer = vim.uv.new_timer()
  timer:start(
    INTERVAL_MS,
    INTERVAL_MS,
    vim.schedule_wrap(function()
      if not something_active() then
        stop_timer()
        vim.cmd "redrawstatus"
        return
      end
      local ok, pi = pcall(require, "pi")
      if ok and pi.is_running() then
        pi_idx = (pi_idx % #pi_frames) + 1
      end
      if lsp_progress then
        lsp_idx = (lsp_idx % #lsp_frames) + 1
      end
      vim.cmd "redrawstatus"
    end)
  )
end

-- === pi module ===============================================
M.pi = function()
  local ok, pi = pcall(require, "pi")
  if not ok or not pi.is_running() then
    return ""
  end

  ensure_hl()
  start_timer()

  local session = pi._get_active_session and pi._get_active_session() or nil
  local info = (session and pi_labels[session.status]) or { icon = "󰧑", text = "working" }
  local label = info.text
  if session and session.status == "running_tool" and session.active_tool then
    label = label .. ":" .. session.active_tool
  end

  return "%#HudPi#" .. info.icon .. " " .. pi_frames[pi_idx] .. " " .. label
end

-- === LSP module ==============================================
-- Replaces NvChad's static lsp_msg with a real-time animated spinner.
local augroup = vim.api.nvim_create_augroup("StatusHud", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
  group = augroup,
  pattern = { "begin", "report", "end" },
  callback = function(args)
    if not args.data or not args.data.params then
      return
    end
    local data = args.data.params.value
    if data.kind == "end" then
      lsp_progress = nil
    else
      local parts = { LSP_ICON }
      if data.title then
        parts[#parts + 1] = data.title
      end
      if data.message and data.message ~= "" then
        parts[#parts + 1] = data.message
      end
      if data.percentage then
        parts[#parts + 1] = data.percentage .. "%%"
      end
      lsp_progress = table.concat(parts, " ")
    end
    vim.cmd "redrawstatus"
  end,
})

M.lsp = function()
  if vim.o.columns < 120 then
    return ""
  end
  if not lsp_progress then
    return ""
  end

  ensure_hl()
  start_timer()

  return "%#HudLsp#" .. lsp_frames[lsp_idx] .. " " .. lsp_progress
end

M.stop = stop_timer

return M
