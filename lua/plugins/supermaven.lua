-- 🐐🗣️🔥️✍️ NO REQUIERE API: es completamente gratis -- ✍️ Activar con:SupermavenUseFree | AUTOCOMPLETADO 󰄭 .
--
return {
  "supermaven-inc/supermaven-nvim", -- ¡IMPORTANTE! Nuevo repositorio
  enabled = function()
    -- Solo en Linux/WSL
    return vim.fn.has("wsl") == 1 or vim.fn.has("unix") == 1
  end,
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>", -- Supermaven maneja INSERT con <Tab>
        clear_suggestion = "<C-]>",
        -- NO mapear accept_word a <C-CR>: cursortab/sweep usan <C-CR> en n/i/v
        -- para next-edit. Un <C-CR> ambiguo en INSERT rompe ambos (patrón de copilot.lua).
        accept_word = "<C-CR>",
      },
      ignore_filetypes = { cpp = true },
      color = {
        suggestion_color = "#C3A1B2", -- Manteniendo tu color anterior -- #808080
        blend = 20, -- blend ya no aparece en el ejemplo de configuración, revisa si aún es soportado.
        cterm = 244,
      },
      log_level = "info",
      disable_inline_completion = false,
      disable_keymaps = false,
      -- Sin condition: usar el comportamiento por defecto (equivalente a copilot.lua,
      -- que funciona bien). NO definir `condition = () => false` — mata las sugerencias.
    })
  end,
}
