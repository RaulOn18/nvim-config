-- LSP configuration: Neovim 0.12+ native vim.lsp.enable

local on_attach = require "configs.on_attach"
local capabilities = require "configs.capabilities"

local eslint_ok_cache = {}

local function eslint_root(bufnr, on_dir)
  local root = vim.fs.root(bufnr, function(name, path)
    if name == ".eslintrc" or name:match "^%.eslintrc%." or name:match "^eslint%.config%." then return true end
    if name ~= "package.json" then return false end

    local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(path, name))
    if not ok then return false end

    local ok_json, pkg = pcall(vim.json.decode, table.concat(lines, "\n"))
    return ok_json and type(pkg) == "table" and pkg.eslintConfig ~= nil
  end)

  if not root then return end

  local eslint = vim.fs.joinpath(root, "node_modules", ".bin", "eslint")
  if vim.fn.executable(eslint) ~= 1 then return end

  if eslint_ok_cache[root] == nil then
    local result = vim.system({ eslint, "--print-config", vim.api.nvim_buf_get_name(bufnr) }, {
      cwd = root,
      text = true,
    }):wait(3000)
    eslint_ok_cache[root] = result.code == 0
  end

  if eslint_ok_cache[root] then on_dir(root) end
end

-- Global defaults applied to every LSP
vim.lsp.config["*"] = vim.tbl_extend("force", vim.lsp.config["*"] or {}, {
  on_attach = on_attach.on_attach,
  capabilities = capabilities.default,
})

vim.lsp.config.vtsls = {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  flags = { debounce_text_changes = 150, allow_incremental_sync = true },
  settings = {
    typescript = {
      tsserver = { maxTsServerMemory = 3072, logVerbosity = "off", useSyntaxServer = "never" },
      suggest = { autoImports = false, completeFunctionCalls = false },
      format = { enable = false },
      inlayHints = {
        parameterNames = { enabled = false },
        parameterTypes = { enabled = false },
        variableTypes = { enabled = false },
      },
      implementationsCodeLens = { enabled = false },
      referencesCodeLens = { enabled = false },
    },
    javascript = { suggest = { autoImports = false, includeCompletionsForModuleExports = false } },
    vtsls = { autoUseWorkspaceTsdk = true },
  },
}

vim.lsp.config.eslint = {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
  root_dir = eslint_root,
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
  root_markers = { "tailwind.config.*", "postcss.config.*", "package.json", "tailwind.config.lua" },
  settings = {
    tailwindCSS = {
      includeLanguages = { typescript = "javascript", typescriptreact = "javascript" },
    },
  },
}

vim.lsp.config.html = { cmd = { "vscode-html-language-server", "--stdio" }, filetypes = { "html" } }
vim.lsp.config.cssls = { cmd = { "vscode-css-language-server", "--stdio" }, filetypes = { "css", "scss", "less" } }

vim.lsp.config.gopls = {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = false, unusedwrite = false, unusedresult = false,
        shadow = false, nilness = false, fieldalignment = false,
      },
      staticcheck = false,
      semanticTokens = false,
      matcher = "CaseInsensitive",
      hints = {
        assignVariableTypes = false, compositeLiteralFields = false, constantValues = false,
        functionTypeParameters = false, parameterNames = false, rangeOverFunction = false,
      },
      codelenses = { references = false, implementation = false },
    },
  },
}

vim.lsp.config.clangd = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "CMakeLists.txt", "Makefile", "meson.build", ".git" },
  flags = { debounce_text_changes = 200, allow_incremental_sync = true },
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

vim.diagnostic.config {
  virtual_text = { prefix = "●", spacing = 4, source = "if_many" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
}
