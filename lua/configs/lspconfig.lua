-- LSP Configuration
-- Using vim.lsp.start() for Neovim 0.12+

local M = {}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

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

        -- Start LSP client
        local client_id = vim.lsp.start(config)
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
  settings = {
    eslint = {
      quiet = true,
      validate = "probe",
    },
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
  end,
})

-- Tailwind CSS
M.setup_lsp("tailwindcss", {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
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
