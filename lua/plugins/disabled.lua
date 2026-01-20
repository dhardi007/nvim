-- /042 󰢱  disabled.lua
-- SOLO PUEDES USAR COPILOT || SUPERMAVEN || TABNINE || Para autocompletar TEXTO!!!
-- This file contains the configuration for disabling specific Neovim plugins.{desactivar plugins
-- lua/utils/plugin-switcher.lua
return {
  {
    -- Plugin: bufferline.nvim
    -- URL: https://github.com/akinsho/bufferline.nvim
    -- Description: A snazzy buffer line (with tabpage integration) for Neovim.
    "akinsho/bufferline.nvim",
    enabled = true, -- Disable this plugin
  },
  -- 󰨞  󰇀 Cursor,Antigravity & VSCODE = Avante AI Plugins for Neovim  .
  {
    -- Plugin para mejorar la experiencia de edición en Neovim
    -- URL: https://github.com/yetone/avante.nvim
    -- Description: Este plugin ofrece una serie de mejoras y herramientas para optimizar la edición de texto en Neovim.
    "yetone/avante.nvim",
    enabled = true,
  },
  --  Copilot AI Plugins for Neovim  ..
  {
    "CopilotC-Nvim/CopilotChat.nvim", -- no funciona "Thinking..."
    enabled = false,
  },
  -- Autocompletion AI Plugins for Neovim   Suggestions, Completions... 󰓅 .[pls add Tab]
  {
    "zbirenbaum/copilot.lua", -- Lo unico gratis de COPILOT  .
    enabled = false,
  },
  {
    "tris203/precognition.nvim",
    enabled = true,
  },
  { "supermaven-nvim", enabled = true },
  {
    "codota/tabnine-nvim", -- el autocompletado es mierda (no me funciona), y requiere app externa :/
    enabled = false,
  },
  --  󱝆 Codeium / Windsurf Plugins for Neovim  .
  {
    "Exafunction/windsurf.nvim",
    enabled = true,
  },
  -- 󰙯 Discord Presence plugin's for Neovim  .
  {
    "andweeb/presence.nvim",
    enabled = false,
  },
  {
    "vyfor/cord.nvim",
    enabled = true,
  },

  { "folke/snacks.nvim", enabled = true }, -- SI NEOVIM / LAZY / UI FALLA, DESACtIVA ESTO.
  -- 󰮮 Opencode AI Plugins for Neovim 
  -- SOLO PUEDES USAR UNO DE LOS 2, DEBES DE MOVER EL OPENCODE QUE NO QUIERES A ../../docs/~ [basura]+IA/
  {
    "sudo-tee/opencode.nvim", -- Integrado en el chat de NVIM rapido
    name = "opencode-sudo",
    enabled = true,
  },
  {
    "NickvanDyke/opencode.nvim", -- El Opencode-CLI mas comodo
    name = "opencode-nick",
    enabled = true,
  },
  {
    "olimorris/codecompanion.nvim",
    enabled = false,
  },
  --  Claude-code AI assistant for Neovim  .
  {
    -- OLD Claude-code
    -- Plugin: claude-code.nvim
    -- URL: https://github.com/greggh/claude-code.nvim
    -- Description: Neovim integration for Claude Code AI assistant
    "greggh/claude-code.nvim",
    enabled = false,
  },
  {
    -- [NEW] Plugin: mejor claude-code:
    "coder/claudecode.nvim",
    enabled = false,
  },
  {
    "jonroosevelt/gemini-cli.nvim",
    -- 󰊭 Prefiero usar mi config de Gemini-cli
    enabled = false, -- Util para actualizar gemini en auto?.
  },
  {
    "sphamba/smear-cursor.nvim",
    enabled = true,
  },
  { "obsidian-nvim/obsidian.nvim", enabled = true },
  -- { "nvim-lua/plenary.nvim", enabled = false }, -- ESTO ES VITAL! 💀
}
