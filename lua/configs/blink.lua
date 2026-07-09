-- Blink.cmp overrides on top of NvChad's nvchad.blink.lazyspec defaults.
-- Returned table gets deep-merged by lazy.nvim into the base opts.

return {
  completion = {
    list = {
      -- Disable auto-pick of first item — avoids accidental acceptance,
      -- user explicitly navigates before pressing Enter/Tab.
      selection = { preselect = false },
    },
    menu = {
      -- Right-only padding for cleaner alignment with NvChad's UI.
      draw = { padding = { 0, 1 } },
    },
  },
}
