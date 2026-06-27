-- Git Integration Plugins

-- ponytail: separate keymap for submodule status (git-status porcelain doesn't support
-- --recurse-submodules, so show submodule status in a scratch split).
vim.keymap.set("n", "<leader>gS", function()
  local lines = vim.fn.systemlist("git submodule status")
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repo or no submodules", vim.log.levels.WARN)
    return
  end
  vim.cmd "belowright 10new"
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.api.nvim_buf_set_name(0, "Submodule Status")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modified = false
end, { desc = "Git Submodule Status" })

return {
  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      -- Enable virtual text blame line otomatis
      current_line_blame = false,  -- Disable for performance (enable manually with <leader>tbl)
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,  -- Increased from 300ms
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        
        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, { expr = true })
        
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, { expr = true })
        
        -- Actions
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end)
        map("n", "<leader>tbl", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function() gs.diffthis("~") end)
        map("n", "<leader>td", gs.toggle_deleted)
        
        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
      end,
    },
  },

  -- Git integration yang lebih baik
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      integrations = {
        diffview = true,
      },
    },
  },
}
