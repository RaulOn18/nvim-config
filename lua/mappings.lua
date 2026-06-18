require "nvchad.mappings"

local map = vim.keymap.set

-- Splits (NvChad doesn't ship these by default)
map("n", "<leader>sv", "<C-w>v", { desc = "Split: Vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split: Horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Split: Equalize" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Split: Close" })

map("n", "<leader>cm", "<cmd>Neogit commit<cr>", { desc = "Git Commit (Neogit)" })

-- One copy_path helper, three keymaps (line / full / visual range).
local function copy_path(opts)
  local rel = vim.fn.fnamemodify(vim.fn.expand "%", ":.")
  local text = rel
  if opts.line then
    local l = vim.api.nvim_win_get_cursor(0)[1]
    text = rel .. ":" .. l
  end
  if opts.range then
    local s, e = vim.api.nvim_buf_get_mark(0, "<")[1], vim.api.nvim_buf_get_mark(0, ">")[1]
    text = s == e and (rel .. ":" .. s) or (rel .. ":" .. s .. "-" .. e)
  end
  vim.fn.setreg("+", text)
  vim.notify(text, vim.log.levels.INFO)
end
map("n", "<leader>cp", function() copy_path { line = true } end, { desc = "Copy path:line" })
map("n", "<leader>cP", function() copy_path {} end, { desc = "Copy path" })
map("v", "<leader>cp", function() copy_path { range = true } end, { desc = "Copy path:lines" })

-- C/C++
local c = function(fn) return function() require("utils.c")[fn]() end end
map("n", "<leader>cc", c "cmake_configure", { desc = "C: CMake Configure" })
map("n", "<leader>cb", c "build", { desc = "C: Build" })
map("n", "<leader>cx", c "run", { desc = "C: Run" })
map("n", "<leader>cX", c "run_with_args", { desc = "C: Run with args" })
map("n", "<leader>ch", c "switch_header", { desc = "C: Switch header/source" })
