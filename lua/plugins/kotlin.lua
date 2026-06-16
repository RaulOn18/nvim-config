-- Kotlin/Android/Compose Development
-- Uses kotlin.nvim with JetBrains official kotlin-lsp

return {
  -- Main Kotlin LSP support via kotlin.nvim
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "stevearc/oil.nvim",
      "folke/trouble.nvim",
    },
    config = function()
      local on_attach = require "configs.on_attach"
      local capabilities = require "configs.capabilities"

      require("kotlin").setup {
        -- Root markers for Android/Gradle projects
        root_markers = {
          "gradlew",
          "gradlew.bat",
          ".git",
          "build.gradle.kts",
          "build.gradle",
          "settings.gradle.kts",
          "settings.gradle",
        },

        -- Inlay hints (optional, can disable if too noisy)
        inlay_hints = {
          enabled = true,
          parameters = true,
          types_variable = true,
          function_return = true,
        },

        -- Code folding
        folding = { enabled = true },

        -- LSP config: force cmp capabilities + shared on_attach
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
