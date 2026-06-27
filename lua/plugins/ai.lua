-- AI Assistant Plugins

return {
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
