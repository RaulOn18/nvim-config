-- LSP configuration: Neovim 0.12+ native vim.lsp.enable
-- Replaces custom M.setup_lsp (root cache, ft_set, root_uri/workspace_folders dance)
-- that re-implemented what vim.lsp.enable provides natively.

local on_attach = require "configs.on_attach"
local capabilities = require "configs.capabilities"

-- Suppress noisy notifications:
--   -32603 on publishDiagnostics / diagnostic = ESLint Windows path-handling bug
--   any err on codeAction/resolve              = vtsls TypeScript 5.9.x bug
local function silent_on(method, code)
  local orig = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, result, ctx, config)
    if err and (not code or err.code == code) then return end
    if orig then return orig(err, result, ctx, config) end
  end
end
silent_on("textDocument/publishDiagnostics", -32603)
silent_on("textDocument/diagnostic", -32603)
silent_on("codeAction/resolve")

-- Global defaults applied to every LSP
vim.lsp.config["*"] = vim.tbl_extend("force", vim.lsp.config["*"] or {}, {
  on_attach = on_attach.on_attach,
  capabilities = capabilities.default,
})

vim.lsp.config.vtsls = {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
  settings = {
    typescript = {
      tsserver = {
        maxTsServerMemory = 3072,
        logVerbosity = "off",
        useSyntaxServer = "never",
      },
      suggest = {
        autoImports = false,
        completeFunctionCalls = false,
      },
      format = { enable = false },
      inlayHints = {
        parameterNames = { enabled = false },
        parameterTypes = { enabled = false },
        variableTypes = { enabled = false },
      },
      implementationsCodeLens = { enabled = false },
      referencesCodeLens = { enabled = false },
    },
    javascript = {
      suggest = {
        autoImports = false,
        includeCompletionsForModuleExports = false,
      },
    },
    vtsls = { autoUseWorkspaceTsdk = true },
  },
}

vim.lsp.config.eslint = {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
  root_markers = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "package.json",
  },
  settings = {
    eslint = {
      quiet = true,
      validate = "probe",
      workingDirectory = { mode = "auto" },
      problems = { shortenToSingleLine = false },
      codeAction = {
        disableRuleComment = { enable = true, location = "separateLine" },
        showDocumentation = { enable = false },
      },
    },
  },
}

vim.lsp.config.tailwindcss = {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.cjs",
    "postcss.config.mjs",
    "postcss.config.ts",
    "package.json",
    "tailwind.config.lua",
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        typescript = "javascript",
        typescriptreact = "javascript",
      },
    },
  },
}

vim.lsp.config.html = {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
}

vim.lsp.config.cssls = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
}

vim.lsp.config.gopls = {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = false,
        unusedwrite = false,
        unusedresult = false,
        shadow = false,
        nilness = false,
        fieldalignment = false,
      },
      staticcheck = false,
      semanticTokens = false,
      matcher = "CaseInsensitive",
      hints = {
        assignVariableTypes = false,
        compositeLiteralFields = false,
        constantValues = false,
        functionTypeParameters = false,
        parameterNames = false,
        rangeOverFunction = false,
      },
      codelenses = {
        references = false,
        implementation = false,
      },
    },
  },
}

vim.lsp.config.clangd = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    "CMakeLists.txt",
    "Makefile",
    "meson.build",
    ".git",
  },
  flags = {
    debounce_text_changes = 200,
    allow_incremental_sync = true,
  },
  settings = {
    clangd = {
      fallbackFlags = { "-std=c17" },
      inlayHints = { Enable = false },
      headerInsertion = "iwyu",
    },
  },
}

vim.lsp.config.sqlls = {
  cmd = { "sql-language-server", "up", "--method", "stdio" },
  filetypes = { "sql", "mysql" },
}

-- NOTE: Kotlin LSP is handled by kotlin.nvim plugin (see plugins/kotlin.lua)

vim.lsp.enable { "vtsls", "eslint", "tailwindcss", "html", "cssls", "gopls", "clangd", "sqlls" }

-- Diagnostic config
vim.diagnostic.config {
  virtual_text = {
    prefix = "●",
    spacing = 4,
    source = "if_many",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
}
