-- LSP Configuration
-- Using vim.lsp.start() for Neovim 0.12+

local M = {}
local on_attach = require "configs.on_attach"

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Suppress ESLint -32603 errors globally (Windows path handling bug)
local orig_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  if err and err.code == -32603 then
    return
  end
  if orig_publish then
    return orig_publish(err, result, ctx, config)
  end
end

local orig_diagnostic = vim.lsp.handlers["textDocument/diagnostic"]
vim.lsp.handlers["textDocument/diagnostic"] = function(err, result, ctx, config)
  if err and err.code == -32603 then
    return
  end
  if orig_diagnostic then
    return orig_diagnostic(err, result, ctx, config)
  end
end

function M.setup_lsp(name, config)
  config.name = name
  config.capabilities = capabilities

  if not config.on_attach then
    config.on_attach = on_attach.on_attach
  end

  -- Store config for later use
  M.configs = M.configs or {}
  M.configs[name] = config

  -- Create autocmd to start LSP when file is opened
  if config.filetypes then
    local group = vim.api.nvim_create_augroup("LspStart_" .. name, { clear = true })

    -- Cache root_dir lookups per cwd to avoid repeated filesystem scans
    local root_cache = {}

    -- Pre-compute a set for O(1) filetype lookup instead of ipairs loop
    local ft_set = {}
    for _, f in ipairs(config.filetypes) do
      ft_set[f] = true
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = config.filetypes,
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        if ft == "" then
          vim.cmd("filetype detect")
          ft = vim.bo[buf].filetype
        end

        -- Fast guard: should always match since pattern=, but be safe
        if not ft_set[ft] then return end

        -- Check if client already exists for this buffer
        local clients = vim.lsp.get_clients({ name = name })
        for _, client in ipairs(clients) do
          if client.attached_buffers[buf] then
            return
          end
        end

        -- Get buffer path for root_dir calculation
        local fname = vim.api.nvim_buf_get_name(buf)
        if fname == "" then
          -- No file path yet (new buffer), skip LSP start
          return
        end

        -- Build config for this buffer (shallow copy — only root_dir/settings change)
        local lsp_config = {}
        for k, v in pairs(config) do
          lsp_config[k] = v
        end
        if type(lsp_config.root_dir) == "function" then
          local file_dir = vim.fn.fnamemodify(fname, ":h")
          local cache_key = file_dir .. "::" .. name
          
          if root_cache[cache_key] ~= nil then
            lsp_config.root_dir = root_cache[cache_key]
          else
            local root = lsp_config.root_dir(fname)
            if not root or root == "" then
              return
            end
            root_cache[cache_key] = root
            lsp_config.root_dir = root
          end
        end

        -- Ensure root_dir is a valid string path
        if lsp_config.root_dir and type(lsp_config.root_dir) == "string" then
          -- Convert to URI for vim.lsp.start()
          lsp_config.root_uri = vim.uri_from_fname(lsp_config.root_dir)
          lsp_config.workspace_folders = {
            {
              uri = lsp_config.root_uri,
              name = vim.fn.fnamemodify(lsp_config.root_dir, ":t"),
            },
          }
        end

        -- Start LSP client
        local client_id = vim.lsp.start(lsp_config)
        if client_id then
          vim.lsp.buf_attach_client(buf, client_id)
        end
      end,
      group = group,
    })
  end
end

-- vtsls for TypeScript/JavaScript
M.setup_lsp("vtsls", {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
  settings = {
    typescript = {
      tsserver = {
        maxTsServerMemory = 6144,
        logVerbosity = "off",
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
    vtsls = {
      autoUseWorkspaceTsdk = true,
    },
  },
  single_file_support = false,
  -- override handled via on_attach module
})

-- ESLint
M.setup_lsp("eslint", {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
  root_dir = function(fname)
    local util = require "lspconfig.util"
    return util.root_pattern(
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json",
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
      "package.json"
    )(fname)
  end,
  single_file_support = false,
  settings = {
    eslint = {
      quiet = true,
      validate = "probe",
      workingDirectory = { mode = "auto" },
      -- Disable problematic diagnostics that trigger path errors
      problems = { shortenToSingleLine = false },
      codeAction = {
        disableRuleComment = { enable = true, location = "separateLine" },
        showDocumentation = { enable = false },
      },
    },
  },
  handlers = {
    ["eslint/probeFailed"] = function() return nil end,
  },
  -- override handled via on_attach module
})

-- Tailwind CSS
M.setup_lsp("tailwindcss", {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(fname)
    local util = require "lspconfig.util"
    return util.root_pattern(
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.mjs",
      "tailwind.config.ts",
      "postcss.config.js",
      "postcss.config.cjs",
      "postcss.config.mjs",
      "postcss.config.ts",
      "package.json",
      "tailwind.config.lua"
    )(fname)
  end,
  single_file_support = false,
  settings = {
    tailwindCSS = {
      includeLanguages = {
        typescript = "javascript",
        typescriptreact = "javascript",
      },
    },
  },
})

-- HTML
M.setup_lsp("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
})

-- CSS
M.setup_lsp("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
})

-- Go
M.setup_lsp("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
})

-- SQL
M.setup_lsp("sqlls", {
  cmd = { "sql-language-server", "up", "--method", "stdio" },
  filetypes = { "sql", "mysql" },
  single_file_support = true,
  on_attach = function(client, bufnr)
    client.server_capabilities.completionProvider = {
      triggerCharacters = { ".", " ", "(" },
    }
  end,
})

-- Kotlin (Android/Compose)
M.setup_lsp("kotlin_language_server", {
  cmd = { "kotlin-language-server" },
  filetypes = { "kotlin" },
  root_dir = function(fname)
    local util = require "lspconfig.util"
    return util.root_pattern(
      "settings.gradle.kts",
      "settings.gradle",
      "build.gradle.kts",
      "build.gradle",
      "gradlew"
    )(fname)
  end,
  single_file_support = false,
  settings = {
    kotlin = {
      compiler = {
        jvm = {
          target = "17",
        },
      },
      codegen = {
        enabled = true,
      },
      completion = {
        snippets = {
          enabled = true,
        },
      },
      linting = {
        debounce = 250,
      },
    },
  },
  flags = {
    debounce_text_changes = 150,
  },
  init_options = {
    -- Enable storagePath for better performance
    storagePath = vim.fn.stdpath("data") .. "/kotlin-language-server",
  },
  -- Android specific settings
  android = {
    sdkPath = vim.env.ANDROID_HOME or vim.env.ANDROID_SDK_ROOT or "",
  },
})

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

return M
