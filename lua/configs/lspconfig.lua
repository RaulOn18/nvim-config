-- LSP Configuration
-- Using vim.lsp.start() for Neovim 0.12+

local M = {}

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
    config.on_attach = function(client, bufnr)
      -- Default: disable formatting (use conform.nvim)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end

  -- Store config for later use
  M.configs = M.configs or {}
  M.configs[name] = config

  -- Create autocmd to start LSP when file is opened
  if config.filetypes then
    local group = vim.api.nvim_create_augroup("LspStart_" .. name, { clear = true })

    -- Trigger on FileType
    vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile", "FileType"}, {
      pattern = "*",
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        -- If no filetype set, try to detect
        if ft == "" then
          vim.cmd("filetype detect")
          ft = vim.bo[buf].filetype
        end

        -- Check if filetype matches
        local match = false
        for _, f in ipairs(config.filetypes) do
          if ft == f then
            match = true
            break
          end
        end
        if not match then return end

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

        -- Resolve root_dir if it's a function
        local lsp_config = vim.deepcopy(config)
        if type(lsp_config.root_dir) == "function" then
          local root = lsp_config.root_dir(fname)
          if not root or root == "" then
            -- No root found, skip to avoid undefined path errors
            return
          end
          lsp_config.root_dir = root
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
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.codeLensProvider = false
  end,
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
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
  end,
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
