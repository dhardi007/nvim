-- Detección de Termux (Android): la mayoría de los DAPs nativos (Rust/C/C#/Go)
-- no publican build precompilado para aarch64/bionic, así que en Termux solo se
-- instalan los tools "portables" (LSPs/formatters) para no contaminar el log de
-- arranque con instalaciones que van a fallar en run_on_start.
local is_termux = vim.fn.isdirectory(vim.env.PREFIX or "") == 1
  and (vim.env.PREFIX or ""):match("com%.termux") ~= nil

local ensure_installed = {
  -- LSP (portables)
  "angular-language-server",
  "copilot-language-server", -- GitHub Copilot (npm: @github/copilot-language-server)
  "eslint-lsp",
  "json-lsp",
  "lua-language-server",
  "marksman",

  -- Formatter / Linter / otros (portables)
  "biome",
  "prettier",
  "shfmt",
  "stylua",
  "markdown-toc",
  "markdownlint-cli2",
  "tree-sitter-cli",
}

-- DAPs nativos: requieren build ARM/Android que Mason no publica para Termux.
if not is_termux then
  vim.list_extend(ensure_installed, {
    -- LSP
    "jdtls",
    "cpptools",

    -- DAP
    "js-debug-adapter", -- pwa-node/pwa-chrome (JS/TS)
    "codelldb", -- C/C++/Rust
    "delve", -- Go
    "netcoredbg", -- C#
    "php-debug-adapter", -- PHP (Xdebug)
    "java-debug-adapter",
    "java-test",
  })
end

return {
  { "mason-org/mason.nvim" },
  { "mason-org/mason-lspconfig.nvim" },

  -- mason-tool-installer: instala/actualiza en automático lo que ya tenés puesto
  -- a mano en Mason, sin depender de correr :MasonInstall X vos mismo. En Termux
  -- solo intenta los tools portables (lista de arriba filtrada por plataforma).
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = ensure_installed,
      -- Same criterion as checker=false in lazy.lua: no auto updates, solo instala lo que falta.
      auto_update = false,
      run_on_start = true, -- corre solo al abrir nvim, sin intervención
    },
  },
}
