-- Kotlin/Android/Compose Development

return {
  -- Kotlin syntax highlighting (beyond treesitter)
  {
    "udalov/kotlin-vim",
    ft = "kotlin",
    init = function()
      -- Disable default mappings
      vim.g.kotlin_map_prefix = "<leader>Kv"
    end,
  },

  -- Gradle build file syntax
  {
    "hdiniz/vim-gradle",
    ft = { "kotlin", "groovy", "java" },
  },

  -- Kotlin code actions
  {
    "aznhe21/actions-preview.nvim",
    ft = "kotlin",
  },
}
