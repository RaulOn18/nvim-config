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
  
  -- Modified buffer → confirm, else force delete
  if vim.bo[cur].modified then
    local choice = vim.fn.confirm("Save changes to " .. vim.fn.bufname(cur) .. "?", "&Yes\n&No\n&Cancel", 2)
    if choice == 1 then
      vim.cmd("bdelete " .. cur)
    elseif choice == 2 then
      vim.cmd("bdelete! " .. cur)
    end
  else
    vim.cmd("bdelete! " .. cur)
  end
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
  if vim.bo[cur].modified then
    local choice = vim.fn.confirm("Save changes to " .. vim.fn.bufname(cur) .. "?", "&Yes\n&No\n&Cancel", 2)
    if choice == 1 then
      vim.cmd("bdelete " .. cur)
    elseif choice == 2 then
      vim.cmd("bdelete! " .. cur)
    end
  else
    vim.cmd("bdelete! " .. cur)
  end
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
map("n", "<leader>fp", function() require("utils.project").project_picker() end, { desc = "Find Projects" })
map("n", "<leader>cd", function() require("utils.project").auto_cd_git_root() end, { desc = "CD to Git Root" })

-- fzf-lua shortcuts
map("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "Find Files" })
map("n", "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "Live Grep" })
map("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "Find Buffers" })
map("n", "<leader>fh", function() require("fzf-lua").helptags() end, { desc = "Find Help" })
map("n", "<leader>fo", function() require("fzf-lua").oldfiles() end, { desc = "Recent Files" })
map("n", "<leader>fc", function() require("fzf-lua").grep_cword() end, { desc = "Find String Under Cursor" })
map("n", "<leader>fr", function() require("fzf-lua").resume() end, { desc = "Resume Last Search" })
map("n", "<leader>fk", function() require("fzf-lua").keymaps() end, { desc = "Find Keymaps" })
map("n", "<leader>fC", function() require("fzf-lua").commands() end, { desc = "Find Commands" })

-- Diagnostics (fzf-lua)
map("n", "<leader>xx", function() require("fzf-lua").diagnostics_workspace() end, { desc = "All Diagnostics" })
map("n", "<leader>xb", function() require("fzf-lua").diagnostics_document() end, { desc = "Buffer Diagnostics" })
map("n", "<leader>xs", function() require("fzf-lua").lsp_document_symbols() end, { desc = "Document Symbols" })
map("n", "<leader>xl", function() require("fzf-lua").lsp_references() end, { desc = "LSP References" })
map("n", "<leader>xq", function() require("fzf-lua").quickfix() end, { desc = "Quickfix List" })

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

-- <leader>gd = fzf-lua picker (kalau ada multiple results)
map("n", "<leader>gD", function() require("fzf-lua").lsp_definitions() end, { desc = "Definition (Picker)" })

-- gr = LSP References (fzf-lua)
map("n", "gr", function()
  require("fzf-lua").lsp_references({
    winopts = {
      preview = { horizontal = "right:50%" },
    },
  })
end, { desc = "Find References" })

map("n", "gI", function() require("fzf-lua").lsp_implementations() end, { desc = "Go to Implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
map({ "n", "v" }, "<leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "Code Action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Copy relative path + line number to clipboard
map("n", "<leader>cp", function()
  local rel = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local text = rel .. ":" .. line
  vim.fn.setreg("+", text)
  vim.notify(text, vim.log.levels.INFO)
end, { desc = "Copy relative path:line" })

-- Copy relative path only (no line number)
map("n", "<leader>cP", function()
  local rel = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", rel)
  vim.notify(rel, vim.log.levels.INFO)
end, { desc = "Copy relative path" })

-- Copy path:line in visual mode (uses first selected line)
map("v", "<leader>cp", function()
  local rel = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  local start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
  local end_line = vim.api.nvim_buf_get_mark(0, ">")[1]
  local text
  if start_line == end_line then
    text = rel .. ":" .. start_line
  else
    text = rel .. ":" .. start_line .. "-" .. end_line
  end
  vim.fn.setreg("+", text)
  vim.notify(text, vim.log.levels.INFO)
end, { desc = "Copy relative path:lines" })

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


