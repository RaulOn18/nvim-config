-- Kotlin/JVM and Android/Compose development.

local function gradle(command)
  local root = vim.fs.root(0, { "gradlew", "gradlew.bat", "settings.gradle.kts", "settings.gradle" })
  if not root then
    vim.notify("Gradle project root not found", vim.log.levels.WARN)
    return
  end
  local wrapper = vim.fn.has "win32" == 1 and "gradlew.bat" or "./gradlew"
  vim.cmd.terminal({ args = { wrapper, unpack(command) }, bang = true })
  vim.fn.chdir(root)
end

return {
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin", "kotlin_settings" },
    keys = {
      { "<leader>rG", function() gradle {} end, desc = "Gradle" },
      { "<leader>rB", function() gradle { "build" } end, desc = "Gradle Build" },
      { "<leader>rt", function() gradle { "test" } end, desc = "Gradle Test" },
      { "<leader>ra", function() gradle { "assembleDebug" } end, desc = "Android Assemble Debug" },
      { "<leader>ri", function() gradle { "installDebug" } end, desc = "Android Install Debug" },
      { "<leader>rc", function() gradle { "connectedAndroidTest" } end, desc = "Android Instrumented Test" },
    },
    config = function()
      local mason_lsp = vim.fn.stdpath "data" .. "/mason/packages/kotlin-lsp"
      if vim.env.KOTLIN_LSP_DIR == nil then
        local candidates = vim.fn.glob(mason_lsp .. "/kotlin-server-*", false, true)
        if #candidates > 0 then vim.env.KOTLIN_LSP_DIR = candidates[1] end
      end
      local on_attach = require "configs.on_attach"
      local capabilities = require "configs.capabilities"
      require("kotlin").setup {
        root_markers = { "gradlew", "gradlew.bat", "settings.gradle.kts", "settings.gradle", ".git" },
        lsp = { on_attach = on_attach.on_attach, capabilities = capabilities.default },
      }
    end,
  },
  { "hdiniz/vim-gradle", ft = { "kotlin", "groovy", "java", "gradle" } },
}
