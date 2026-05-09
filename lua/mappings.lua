require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

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

-- Buffer management
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#<cr>", { desc = "Close other buffers" })

-- Quick close
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>qQ", "<cmd>qa!<cr>", { desc = "Force quit all" })

-- Projects
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find Projects" })
map("n", "<leader>cd", function() require("utils.project").auto_cd_git_root() end, { desc = "CD to Git Root" })

-- Oil (file explorer)
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File Explorer (Oil)" })
map("n", "<leader>E", "<cmd>Oil --float<cr>", { desc = "File Explorer (Float)" })

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

-- Git
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diff View" })
map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close Diff View" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File History" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Git Branches" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git Commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git Status" })

-- Diagnostics (Trouble)
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols (Trouble)" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle<cr>", { desc = "LSP Definitions / References" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List" })

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
map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Find References" })
map("n", "gI", "<cmd>Telescope lsp_implementations<cr>", { desc = "Go to Implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
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

