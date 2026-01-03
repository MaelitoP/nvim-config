local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

capabilities.textDocument.semanticTokens.augmentsSyntaxTokens = false

capabilities.textDocument.completion.completionItem = {
  contextSupport = true,
  snippetSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
  labelDetailsSupport = true,
  documentationFormat = { "markdown", "plaintext" },
}

-- send actions with hover request
capabilities.experimental = {
  hoverActions = true,
  hoverRange = true,
  serverStatusNotification = true,
  -- snippetTextEdit = true, -- not supported yet
  codeActionGroup = true,
  ssr = true,
  commands = {
    "rust-analyzer.runSingle",
    "rust-analyzer.debugSingle",
    "rust-analyzer.showReferences",
    "rust-analyzer.gotoLocation",
    "editor.action.triggerParameterHints",
  },
}

vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git", vim.uv.cwd() },
  settings = {
    Lua = {
      telemetry = {
        enable = false,
      },
    },
  },
}

vim.lsp.config.nixd = {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', 'git' },
}

vim.lsp.config.nil_ls = {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
}

vim.lsp.config.tsserver = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
  -- Disable tsserver formatting when biome is available
  on_attach = function(client, bufnr)
    -- Check if biome is attached to this buffer
    local biome_active = false
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      if c.name == 'biome' then
        biome_active = true
        break
      end
    end
    -- Disable tsserver formatting if biome is active
    if biome_active then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end,
}

vim.lsp.config.biome = {
  cmd = { 'biome', 'lsp-proxy' },
  filetypes = { 'javascript', 'javascriptreact', 'json', 'jsonc', 'typescript', 'typescriptreact', 'astro', 'svelte', 'vue', 'css' },
  root_markers = { 'biome.json', 'biome.jsonc' },
  single_file_support = false,  -- Only enable in projects with biome config
}

vim.lsp.enable({
  'lua_ls',         -- Lua
  'rust_analyzer',  -- Rust
  'tsserver',       -- TypeScript & JavaScript
  'biome',          -- Biome (JS/TS/JSON/CSS)
  'intelephense',   -- PHP
  'pyright',        -- Python
  'ocamllsp',       -- OCaml
  'gopls',          -- Go
  'nixd',           -- Nix
  'nil_ls'
})

