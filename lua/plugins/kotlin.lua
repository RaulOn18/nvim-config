-- Kotlin/Android/Compose Development
-- Uses kotlin.nvim with JetBrains official kotlin-lsp
-- Gradle keymaps (<leader>rG/B/R) live in this spec's `keys` field, registered
-- globally when kotlin.nvim loads at VeryLazy.

return {
  {
    "AlexandrosAlexiou/kotlin.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>rG", "<cmd>terminal ./gradlew<cr>",       { desc = "Gradle Wrapper" } },
      { "<leader>rB", "<cmd>terminal ./gradlew build<cr>", { desc = "Gradle Build" } },
      { "<leader>rR", "<cmd>terminal ./gradlew run<cr>",   { desc = "Gradle Run" } },
    },
    config = function()
      local on_attach = require "configs.on_attach"
      local capabilities = require "configs.capabilities"

      require("kotlin").setup {
        root_markers = {
          "gradlew", "gradlew.bat", ".git",
          "build.gradle.kts", "build.gradle",
          "settings.gradle.kts", "settings.gradle",
        },
        lsp = {
          on_attach = on_attach.on_attach,
          capabilities = capabilities.default,
        },
      }
    end,
  },

  -- Gradle build file syntax (keep for highlighting)
  {
    "hdiniz/vim-gradle",
    ft = { "kotlin", "groovy", "java" },
  },
}
