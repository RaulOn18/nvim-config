-- Blink.cmp overrides on top of NvChad's nvchad.blink.lazyspec defaults.
-- Returned table gets deep-merged by lazy.nvim into the base opts.

return {
  appearance = {
    -- 'normal' aligns with standard Nerd Font (use 'mono' for Mono variants)
    nerd_font_variant = "normal",
  },

  completion = {
    -- Disable auto-pick of first item — avoids accidental acceptance
    list = { selection = { preselect = false } },

    -- Layout: icon (left) | label + description | kind (right)
    menu = {
      draw = {
        padding = { 0, 1 },
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "kind" },
        },
      },
    },

    -- Show doc popup when an item is selected (short delay feels instant)
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 100,
    },

    -- UX boosters: auto-brackets after functions, dot-repeat, single-undo
    accept = {
      auto_brackets = { enabled = true },
      dot_repeat = true,
      create_undo_point = true,
    },
  },
}
