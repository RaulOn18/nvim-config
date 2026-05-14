require("nvchad.configs.lspconfig").defaults()

-- LSP Performance Optimizations
vim.lsp.log.set_level(vim.lsp.log.levels.OFF)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- vtsls with performance optimizations for Node.js/Next.js
vim.lsp.config("vtsls", {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
  settings = {
    typescript = {
      tsserver = {
        maxTsServerMemory = 6144,
        logVerbosity = 'off',
        watchOptions = {
          watchFile = "useFsEvents",
          watchDirectory = "useFsEvents",
          fallbackPolling = "dynamicPriority",
        },
      },
      suggest = {
        enabled = true,
        completeFunctionCalls = false,
        includeCompletionsForModuleExports = false,
        includeCompletionsForImportStatements = false,
        autoImports = false,
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
        includeCompletionsForImportStatements = false,
      },
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
  },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  single_file_support = false,
  on_attach = function(client, bufnr)
    -- Disable document formatting (serahkan ke formatter lain)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    -- Reduce capabilities for performance
    client.server_capabilities.codeLensProvider = false
  end,
})

-- ESLint configuration - FIX: better handling untuk project tanpa eslint config
vim.lsp.config("eslint", {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
    "svelte",
    "astro",
  },
  workspace_required = false,
  root_markers = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
    "eslint.config.js",
    "eslint.config.mjs",
    "package.json",
  },
  single_file_support = true,
  settings = {
    eslint = {
      -- FIX: Silent error kalau ga ada eslint config
      quiet = true,
      useESLintClass = false,
      experimental = {
        useFlatConfig = false,
      },
      rulesCustomizations = {},
      run = "onType",
      problems = {
        shortenToSingleLine = false,
      },
      nodePath = "",
      workingDirectory = { mode = "location" },
      codeAction = {
        disableRuleComment = {
          enable = true,
          location = "separateLine",
        },
        showDocumentation = {
          enable = true,
        },
      },
      -- FIX: Validate hanya kalau eslint config ada
      validate = "probe",
    },
  },
  on_attach = function(client, bufnr)
    -- FIX: Cek apakah ada eslint config sebelum attach
    local root_dir = client.config.root_dir
    if root_dir then
      local has_eslint_config = vim.fn.glob(root_dir .. "/.eslintrc*") ~= ""
          or vim.fn.glob(root_dir .. "/eslint.config.*") ~= ""
          or vim.fn.filereadable(root_dir .. "/package.json") == 1
      
      if not has_eslint_config then
        -- Detach ESLint kalau ga ada config
        vim.schedule(function()
          vim.lsp.buf_detach_client(bufnr, client.id)
        end)
        return
      end
    end
    
    client.server_capabilities.documentFormattingProvider = true
  end,
})

-- Tailwind CSS untuk Next.js projects
vim.lsp.config("tailwindcss", {
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          "tw`([^`]*)",
          "tw\\.[^`]+`([^`]*)`",
          "tw\\.\\([^)]*\\)`([^`]*)`",
        },
      },
      includeLanguages = {
        typescript = "javascript",
        typescriptreact = "javascript",
        javascript = "javascript",
        javascriptreact = "javascript",
      },
    },
  },
})

-- Dart LSP: DI-MANAGE SAMA flutter-tools, jangan define di sini
-- Config dartls dihapus untuk hindari konflik double LSP attach

-- SQL LSP Configuration
vim.lsp.config("sqlls", {
  cmd = { "sql-language-server", "up", "--method", "stdio" },
  filetypes = { "sql", "mysql" },
  root_markers = { ".git" },
  settings = {},
  single_file_support = true,
  on_attach = function(client, bufnr)
    -- Enable completion
    client.server_capabilities.completionProvider = {
      triggerCharacters = { ".", " ", "(" },
    }
  end,
})

local servers = {
  "html",
  "cssls",
  "vtsls",
  "tailwindcss",
  "eslint",
  "gopls",
  "sqlls",  -- SQL Language Server
  -- Dart LSP akan di-manage sama flutter-tools, jadi ga usah dimasukkin sini
  -- Kecuali lu ga pake flutter-tools, uncomment baris di bawah:
  -- "dartls",
}

vim.lsp.enable(servers)

-- Performance: debounce diagnostics dengan update interval
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


-- Reduce flicker and improve performance
-- FIX: Handler yang lebih robust untuk mencegah error spam
for _, method in ipairs { "textDocument/diagnostic", "workspace/diagnostic" } do
  local default_diagnostic_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, result, context, config)
    -- FIX: Silent untuk error "Could not find config file"
    if err ~= nil then
      if err.code == -32603 and err.message and err.message:match("Could not find config file") then
        -- Ignore eslint config not found errors
        return
      end
      return default_diagnostic_handler(err, result, context, config)
    end

    if result == nil then
      return
    end

    -- Add debounce to reduce CPU usage
    vim.defer_fn(function()
      default_diagnostic_handler(err, result, context, config)
    end, 100)
  end
end
