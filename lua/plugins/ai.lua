-- AI Assistant Plugins

return {
  {
    "rcarriga/nvim-notify",
    lazy = false,
    opts = {
      render = "compact",
      stages = "static",
      timeout = 3000,
      minimum_width = 1,
      max_width = 80,
      background_colour = "NormalFloat",
    },
    config = function(_, opts)
      local notify = require "notify"
      notify.setup(opts)

      local highlights = {
        NotifyBackground = "NormalFloat",
        NotifyERRORBorder = "DiagnosticError",
        NotifyERRORIcon = "DiagnosticError",
        NotifyERRORTitle = "DiagnosticError",
        NotifyERRORBody = "NormalFloat",
        NotifyWARNBorder = "DiagnosticWarn",
        NotifyWARNIcon = "DiagnosticWarn",
        NotifyWARNTitle = "DiagnosticWarn",
        NotifyWARNBody = "NormalFloat",
        NotifyINFOBorder = "DiagnosticInfo",
        NotifyINFOIcon = "DiagnosticInfo",
        NotifyINFOTitle = "DiagnosticInfo",
        NotifyINFOBody = "NormalFloat",
        NotifyDEBUGBorder = "Comment",
        NotifyDEBUGIcon = "Comment",
        NotifyDEBUGTitle = "Comment",
        NotifyDEBUGBody = "NormalFloat",
        NotifyTRACEBorder = "DiagnosticHint",
        NotifyTRACEIcon = "DiagnosticHint",
        NotifyTRACETitle = "DiagnosticHint",
        NotifyTRACEBody = "NormalFloat",
      }
      for group, target in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, { link = target })
      end

      vim.notify = notify
    end,
  },

  -- Local checkout until Prime Agent support is published upstream.
  {
    dir = "/home/raulon/Projects/Git/pi.nvim",
    cmd = { "PiAsk", "PiAskSelection", "PiCancel", "PiLog" },
    config = function()
      require("pi").setup()
    end,
  },

  -- Supermaven: fastest free AI completions (<100ms response, unlimited free tier)
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      local sm = require "supermaven-nvim"

      sm.setup {
        keymaps = {
          accept_suggestion = "<A-f>",
          clear_suggestion = "<A-c>",
          accept_word = "<A-w>",
        },
        -- ponytail: skip noisy logs in production
        log_level = "off",
        -- integrate with cmp: disable inline if cmp is visible
        disable_inline_completion = false,
      }
    end,
  },
}
