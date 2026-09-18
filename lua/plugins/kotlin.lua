-- Kotlin/Android tooling. kmp-lsp provides Kotlin/Java/KMP LSP support.

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

local function logcat()
  if vim.fn.executable "adb" ~= 1 then
    vim.notify("adb not found in PATH", vim.log.levels.WARN)
    return
  end
  vim.cmd "botright 15new"
  vim.fn.termopen { "adb", "logcat", "-v", "color" }
  vim.cmd "startinsert"
end

return {
  {
    "hdiniz/vim-gradle",
    ft = { "kotlin", "groovy", "java", "gradle" },
    keys = {
      {
        "<leader>rG",
        function()
          gradle {}
        end,
        desc = "Gradle",
      },
      {
        "<leader>rB",
        function()
          gradle { "build" }
        end,
        desc = "Gradle Build",
      },
      {
        "<leader>rt",
        function()
          gradle { "test" }
        end,
        desc = "Gradle Test",
      },
      {
        "<leader>ra",
        function()
          gradle { "assembleDebug" }
        end,
        desc = "Android Assemble Debug",
      },
      {
        "<leader>ri",
        function()
          gradle { "installDebug" }
        end,
        desc = "Android Install Debug",
      },
      {
        "<leader>rc",
        function()
          gradle { "connectedAndroidTest" }
        end,
        desc = "Android Instrumented Test",
      },
      {
        "<leader>rk",
        function()
          gradle { ":shared:testAndroidHostTest" }
        end,
        desc = "KMP Android Host Test",
      },
      {
        "<leader>rd",
        function()
          gradle { ":androidApp:assembleDebug" }
        end,
        desc = "Android Debug APK",
      },
      {
        "<leader>rp",
        function()
          gradle { ":androidApp:installDebug" }
        end,
        desc = "Install Android Debug",
      },
      { "<leader>rl", logcat, desc = "Android Logcat" },
    },
  },
}
