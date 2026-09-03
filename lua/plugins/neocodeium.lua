-- ⚡ neocodeium — Autocompletado IA gratis potenciado por Windsurf (antes Codeium)
-- Repo: monkoose/neocodeium. NO requiere API key manual: solo `:NeoCodeium auth`
-- (abre navegador para autenticarte con cuenta gratuita de Windsurf/Codeium).
-- Diferencias clave vs windsurf.vim: sin flickering, y `accept` es repetible con `.`.
-- Keymaps con Alt (no <Tab>, que lo gestionan Supermaven/blink en INSERT).
return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  config = function()
    require("neocodeium").setup({
      enabled = true, -- server Windsurf activo desde el arranque
      manual = false, -- autosugerencias automáticas en Insert

      -- No pisar <Tab> ni <C-CR> (los usan Supermaven/blink).
      -- Aceptar sugerencias con Alt (compatible con el set NES).
      max_lines = 10000,
      disable_in_special_buftypes = true, -- no sugerir en terminal/help/diff
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        [".env"] = false,
      },
      single_line = { enabled = false }, -- mostrar la sugerencia completa multilinea
    })

    local neocodeium = require("neocodeium")

    -- Alt + f -> aceptar sugerencia (el principal, "aceptar todo")
    vim.keymap.set("i", "<A-f>", function()
      neocodeium.accept()
    end, { desc = "neocodeium: Aceptar sugerencia" })

    -- Alt + w -> aceptar solo la siguiente palabra
    vim.keymap.set("i", "<A-w>", function()
      neocodeium.accept_word()
    end, { desc = "neocodeium: Aceptar palabra" })

    -- Alt + a -> aceptar solo la siguiente línea
    vim.keymap.set("i", "<A-a>", function()
      neocodeium.accept_line()
    end, { desc = "neocodeium: Aceptar línea" })

    -- Alt + e / Alt + r -> ciclar sugerencias (siguiente / anterior)
    vim.keymap.set("i", "<A-e>", function()
      neocodeium.cycle_or_complete(1)
    end, { desc = "neocodeium: Siguiente sugerencia" })
    vim.keymap.set("i", "<A-r>", function()
      neocodeium.cycle_or_complete(-1)
    end, { desc = "neocodeium: Anterior sugerencia" })

    -- Alt + c -> borrar/ocultar la sugerencia actual
    vim.keymap.set("i", "<A-c>", function()
      neocodeium.clear()
    end, { desc = "neocodeium: Limpiar sugerencia" })
  end,
}
