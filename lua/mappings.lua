require "nvchad.mappings"

local map = vim.keymap.set

-- Exit insert mode with jk
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Ask Prime Agent with the current buffer or visual selection as context.
map("n", "<leader>ai", "<cmd>PiAsk<cr>", { desc = "Ask Prime Agent" })
map("v", "<leader>ai", "<cmd>PiAskSelection<cr>", { desc = "Ask Prime Agent (selection)" })

-- ; → : in normal mode (skip Shift for command mode)
map("n", ";", ":", { desc = "Command mode" })

-- Splits (NvChad doesn't ship these by default)
map("n", "<leader>sv", "<C-w>v", { desc = "Split: Vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split: Horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Split: Equalize" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Split: Close" })

-- One copy_path helper, three keymaps (line / full / visual range).
local function copy_path(opts)
  -- nvim_buf_get_name is the canonical API; expand("%") has stale-name edge cases.
  local name = vim.api.nvim_buf_get_name(0)
  local rel = name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]"
  local text = rel
  if opts.line then
    text = rel .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
  elseif opts.range then
    -- ponytail: "<"/">" marks are written on visual EXIT, so first entry reads 0.
    -- line("v") + line(".") is the live visual range.
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then s, e = e, s end
    text = (s == e) and (rel .. ":" .. s) or (rel .. ":" .. s .. "-" .. e)
  end
  vim.fn.setreg("+", text)
  -- ponytail: defer toast so the handler returns the instant the clipboard is filled.
  vim.schedule(function() vim.notify(text, vim.log.levels.INFO) end)
end
map("n", "<leader>cp", function() copy_path { line = true } end, { desc = "Copy path:line" })
map("n", "<leader>cP", function() copy_path {} end, { desc = "Copy path" })
map("v", "<leader>cp", function() copy_path { range = true } end, { desc = "Copy path:lines" })

-- Keep NvChad's terminal registry intact: a hidden float has an invalid window,
-- but its terminal buffer is still the session we want to restore.
map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Toggle floating terminal" })

-- C/C++
local c = function(fn) return function() require("utils.c")[fn]() end end
-- map("n", "<leader>cc", c "cmake_configure", { desc = "C: CMake Configure" })
-- map("n", "<leader>cb", c "build", { desc = "C: Build" })
-- map("n", "<leader>cx", c "run", { desc = "C: Run" })
-- map("n", "<leader>cX", c "run_with_args", { desc = "C: Run with args" })
-- map("n", "<leader>ch", c "switch_header", { desc = "C: Switch header/source" })

