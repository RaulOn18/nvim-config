-- AI Assistant Plugins

return {
  -- Augment AI (lazy load)
  {
    "augmentcode/augment.vim",
    cmd = { "Augment", "AugmentChat" },
    keys = {
      { "<leader>ac", ":Augment chat ", desc = "Augment Chat" },
      { "<leader>an", "<cmd>Augment chat-new<cr>", desc = "Augment New Chat" },
    },
  },
}
