-- 👻 nextedit.nvim — Next Edit Suggestion (líneas verdes predictivas en NORMAL)
-- Sucesor natural de Copilot NES (cuota Free agotada): predicción de edits en
-- Normal/visual con ghost text tipo Cursor, vía OpenRouter (ya configurado).
-- Keymaps y colores replican el set de atajos NES de copilot.lua por consistencia.
-- Requiere: Rust/cargo (rustup en work.nix) para build del sidecar.
return {
  "zenodea/nextedit.nvim",
  event = "VeryLazy", -- Como copilot.lua: cargar antes para predecir en NORMAL
  build = "cd server && cargo build --release",
  config = function()
    require("nextedit").setup({
      -- OpenRouter (mismo proveedor que Avante). Modelo flash-lite gratuito.
      -- ⚠️ La variable del usuario es OPEN_ROUTER_API_KEY (con guion bajo);
      --    nextedit espera OPENROUTER_API_KEY (sin guion) → pasar la key explícita.
      provider = "openrouter",
      api_key = vim.env.OPEN_ROUTER_API_KEY,
      -- Set de atajos NES (referencia copilot.lua, SIN M-Space):
      --   <Tab> aceptar en NORMAL (built-in: si no hay predicción hace fall-through
      --         a tab literal → no roza a Supermaven, que solo vive en INSERT)
      --   <S-Tab> rechazar (built-in dismiss_key)
      --   <C-CR>/<M-CR> aceptar extra en NORMAL y VISUAL (manuales, abajo)
      --   <Esc> en NORMAL limpiar nextedit o nohlsearch (manual, abajo)
      accept_key = "<M-CR>",
      dismiss_key = "<S-Tab>",
      -- Predict al salir de insert (edits completos) y pausar con CursorHold.
      trigger = "boundary",
      debounce_ms = 150,
      jump_distance = 5, -- un segundo accept aplica predicciones multilinea lejanas
      sign_text = "»",
      multiline = true,
      -- No predecir en archivos sensibles (default seguro).
    })

    -- 👻 Aceptar nextedit en NORMAL y VISUAL (además del <Tab> built-in de NORMAL).
    -- Referencia: accept_nes() de copilot.lua (líneas 98-105).
    -- 🚫 Conflicta con Supermaven 🚫
    local function accept()
      local ok, ui = pcall(require, "nextedit.ui")
      if ok then
        ui.accept()
      end
    end

    -- Ctrl+Enter / Alt+Enter: aceptar nextedit (NORMAL y VISUAL).
    -- NO en INSERT: <C-CR> es accept_word de Supermaven; evita E565.
    for _, lhs in ipairs({ "<C-CR>", "<Tab>" }) do
      vim.keymap.set({ "n", "i", "v" }, lhs, accept, {
        noremap = true,
        silent = true,
        desc = "nextedit: Aceptar",
      })
    end

    -- Esc en NORMAL: limpiar nextedit o nohlsearch (ref copilot.lua líneas 114-121)
    vim.keymap.set("n", "<Esc>", function()
      local ok, ui = pcall(require, "nextedit.ui")
      if ok and ui.dismiss() then
        return
      end
      vim.cmd("nohlsearch")
    end, { noremap = true, desc = "nextedit: Limpiar o nohlsearch" })

    -- S-Tab en NORMAL y VISUAL: rechazar nextedit (el dismiss_key alone ya cubre
    -- NORMAL; esto añade VISUAL). Ref copilot.lua líneas 123-129.
    vim.keymap.set({ "n", "i", "v" }, "<S-Tab>", function()
      local ok, ui = pcall(require, "nextedit.ui")
      if ok then
        ui.reject()
      end
    end, { noremap = true, desc = "nextedit: Rechazar" })

    -- Verde clásico de GitHub (idéntico al set_nes_hl de copilot.lua)
    local function set_nextedit_hl()
      vim.api.nvim_set_hl(0, "NextEditNew", { fg = "#ffffff", bg = "#238636" })
      vim.api.nvim_set_hl(0, "NextEditOld", { fg = "#ffa198", bg = "#391a1a" })
      vim.api.nvim_set_hl(0, "NextEditSign", { fg = "#238636" })
    end
    set_nextedit_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_nextedit_hl })
  end,
}
