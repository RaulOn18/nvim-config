-- Kotlin/Android tooling without the JetBrains Kotlin LSP.
-- Kotlin LSP is intentionally disabled because its IntelliJ backend is too heavy.

local function gradle(command)
  local root = vim.fs.root(0, { "gradlew", "gradlew.bat", "settings.gradle.kts", "settings.gradle" })
  if not root then
    vim.notify("Gradle project root not found", vim.log.levels.WARN)
    return
  end
  local wrapper = vim.fn.has "win32" == 1 and "gradlew.bat" or "./gradlew"
  vim.fn.jobstart({ wrapper, unpack(command) }, { cwd = root, detach = true })
  vim.notify("Gradle started: " .. table.concat(command, " "), vim.log.levels.INFO)
end

return {
  {
    "hdiniz/vim-gradle",
    ft = { "kotlin", "groovy", "java", "gradle" },
    keys = {
      { "<leader>rG", function() gradle {} end, desc = "Gradle" },
      { "<leader>rB", function() gradle { "build" } end, desc = "Gradle Build" },
      { "<leader>rt", function() gradle { "test" } end, desc = "Gradle Test" },
      { "<leader>ra", function() gradle { "assembleDebug" } end, desc = "Android Assemble Debug" },
      { "<leader>ri", function() gradle { "installDebug" } end, desc = "Android Install Debug" },
      { "<leader>rc", function() gradle { "connectedAndroidTest" } end, desc = "Android Instrumented Test" },
    },
  },
}
