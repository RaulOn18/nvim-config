require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- Override NvChad's <leader>x (buffer close) to go to previous buffer
map("n", "<leader>x", function()
  local cur = vim.api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(bufs, function(a, b) return a.lastused > b.lastused end)
  
  local target = nil
  for _, buf in ipairs(bufs) do
    if buf.bufnr ~= cur then
      target = buf.bufnr
      break
    end
  end
  
  if target then
    vim.cmd("buffer " .. target)
  else
    vim.cmd("enew")
  end
  
  vim.cmd("bdelete " .. cur)
end, { desc = "Close buffer (go to previous)" })

-- Basic mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Switch Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch Window up" })

-- Resize windows with arrow keys
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Better indenting in visual mode
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Keep cursor centered when searching
map("n", "n", "nzzzv", { desc = "Next search result and center" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Quick save
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "Save file" })

-- Buffer management: close and go to previous buffer
map("n", "<leader>bd", function()
  local cur = vim.api.nvim_get_current_buf()
  -- Find previous buffer (most recently used)
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  -- Sort by last used time (descending)
  table.sort(bufs, function(a, b) return a.lastused > b.lastused end)
  
  -- Find the buffer that's not current
  local target = nil
  for _, buf in ipairs(bufs) do
    if buf.bufnr ~= cur then
      target = buf.bufnr
      break
    end
  end
  
  if target then
    vim.cmd("buffer " .. target)
  else
    -- No other buffer, open new empty
    vim.cmd("enew")
  end
  
  -- Delete the old buffer
  vim.cmd("bdelete " .. cur)
end, { desc = "Close buffer (go to previous)" })

map("n", "<leader>bo", "<cmd>%bd|e#<cr>", { desc = "Close other buffers" })

-- Window splits: close and go to previous window
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal Split" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })
map("n", "<leader>sx", function()
  local win_count = #vim.api.nvim_list_wins()
  if win_count > 1 then
    -- Go to previous window before closing
    vim.cmd("wincmd p")
    -- Close the window we just left (which was the current one)
    vim.cmd("close")
  else
    vim.notify("Only one window", vim.log.levels.INFO)
  end
end, { desc = "Close Split (go to previous)" })

-- Quick close
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>qQ", "<cmd>qa!<cr>", { desc = "Force quit all" })

-- Projects
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find Projects" })
map("n", "<leader>cd", function() require("utils.project").auto_cd_git_root() end, { desc = "CD to Git Root" })

-- Telescope shortcuts
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find Help" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Recent Files" })
map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find String Under Cursor" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume Last Search" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find Keymaps" })
map("n", "<leader>fC", "<cmd>Telescope commands<cr>", { desc = "Find Commands" })

-- Diagnostics (Telescope - faster than trouble.nvim)
map("n", "<leader>xx", "<cmd>Telescope diagnostics<cr>", { desc = "All Diagnostics" })
map("n", "<leader>xb", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Buffer Diagnostics" })
map("n", "<leader>xs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document Symbols" })
map("n", "<leader>xl", "<cmd>Telescope lsp_references<cr>", { desc = "LSP References" })
map("n", "<leader>xq", "<cmd>Telescope quickfix<cr>", { desc = "Quickfix List" })

-- LSP shortcuts (akan aktif saat LSP attach)
-- gd = native jump (paling cepat)
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })

-- gD = declaration dengan fallback ke definition
map("n", "gD", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local has_declaration = false
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/declaration") then
      has_declaration = true
      break
    end
  end
  
  if has_declaration then
    vim.lsp.buf.declaration()
  else
    vim.lsp.buf.definition()
  end
end, { desc = "Go to Declaration (or Definition)" })

-- <leader>gd = Telescope picker (kalau ada multiple results)
map("n", "<leader>gD", "<cmd>Telescope lsp_definitions<cr>", { desc = "Definition (Picker)" })

-- gr = LSP References (Telescope, project-relative path)
map("n", "gr", function()
  require("telescope.builtin").lsp_references({
    path_display = { "truncate" },
    layout_config = {
      preview_width = 0.5,
    },
  })
end, { desc = "Find References" })

map("n", "gI", "<cmd>Telescope lsp_implementations<cr>", { desc = "Go to Implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
map({ "n", "v" }, "<leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "Code Action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Augment AI Mappings
map("n", "<leader>ac", ":Augment chat ", { desc = "Augment Chat" })
map("v", "<leader>ac", ":Augment chat ", { desc = "Augment Chat (selection)" })
map("n", "<leader>an", "<cmd>Augment chat-new<cr>", { desc = "Augment New Chat" })
map("n", "<leader>at", "<cmd>Augment chat-toggle<cr>", { desc = "Augment Toggle Chat" })
map("n", "<leader>as", "<cmd>Augment status<cr>", { desc = "Augment Status" })
map("n", "<leader>al", "<cmd>Augment list<cr>", { desc = "Augment List" })

-- Formatting (Manual - hanya format yang kamu rubah)
-- Format visual selection (hanya yang di-select)
map("v", "<leader>cf", function()
  require("conform").format({
    lsp_fallback = true,
    range = {
      start = vim.api.nvim_buf_get_mark(0, "<")[1],
      ["end"] = vim.api.nvim_buf_get_mark(0, ">")[1],
    },
  })
end, { desc = "Format Selection" })

-- Format seluruh file (kalau butuh sekali-sekali)
map("n", "<leader>cF", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format File" })

