-- 👻 neocursor.nvim — Cursor Tab-Tab-Tab real en Neovim
-- Usa la sesión REAL de la app Cursor (instalada y firmada): nada de API keys,
-- no consume OpenRouter, calidad genuina de Cursor Tab (ghost text + saltos).
-- Requiere: app Cursor instalada + `uv` en PATH (ambos en work.nix).
-- Referencia de keymaps: copilot.lua (set de atajos NES) para consistencia.
return {
  -- 1. Apuntar a tu fork con los parches nativos
  "dizzi1222/neocursor.nvim",
  -- commit = "0d0aede7", -- Opcional: Lazy.nvim descargará siempre lo último de main.

  event = "VeryLazy", -- Cargar al arranque: NO InsertEnter (bloquea el disparo en normal)
  opts = {
    -- NO mapear <Tab> (lo gestionan Supermaven/blink en INSERT).
    -- Aceptar ghost text / saltos con el mismo set de atajos estilo NES.
    map_tab = false,
    -- Aceptar palabra a palabra (parcial) con <M-Right>.
    map_partial = "<M-Right>",
    debounce = 250,
    show_hints = true,
  },
  config = function(_, opts)
    -- 🤫 Interceptar y silenciar el mensaje de inicio de neocursor
    local original_notify = vim.notify
    vim.notify = function(msg, level, notify_opts)
      if msg and msg:find("neocursor ready") then
        return -- Bloquea este string específico y no muestra nada
      end
      return original_notify(msg, level, notify_opts)
    end

    require("neocursor").setup(opts)
    vim.notify = original_notify

    -- Aceptar o saltar al siguiente edit (flujo tab-tab-tab de Cursor).
    -- Estos binds replican el set de atajos NES de copilot.lua.
    -- <C-CR> y <Tab> solo en NORMAL/VISUAL (en INSERT los reservan Supermaven/cursortab).
    -- <M-CR> es el aliase libre que funciona en n/i/v.
    local function accept()
      if require("neocursor").accept() then
        return
      end
    end
    for _, lhs in ipairs({ "<C-CR>", "<Tab>" }) do
      vim.keymap.set({ "n", "v" }, lhs, accept, { noremap = true, silent = true, desc = "neocursor: accept/jump" })
    end
    vim.keymap.set(
      { "n", "i", "v" },
      "<M-CR>",
      accept,
      { noremap = true, silent = true, desc = "neocursor: accept/jump" }
    )

    -- 👻 Descartar ghost text / predicciones con <Esc> o <S-Tab> en NORMAL, INSERT y VISUAL
    -- Llama a dismiss() de Neocursor y limpia el estado de hlsearch.
    local function dismiss_esc()
      -- 1. Descarta la sugerencia de Neocursor
      require("neocursor").dismiss()

      -- 2. Limpia el resaltado de búsqueda (hlsearch) de Neovim
      vim.cmd("noh")

      -- 3. Si estás en modo Insertar o Visual, forzamos la salida al modo Normal de forma limpia
      local mode = vim.api.nvim_get_mode().mode
      if mode:match("^[vV]") or mode == "i" then
        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
        vim.api.nvim_feedkeys(esc, "n", false)
      end
    end

    -- Mapeamos tanto <S-Tab> como <Esc> para unificar el comportamiento.
    -- ⚠️ LazyVim registra su propio `<Esc>` expr en `User VeryLazy`
    -- (LazyVim/config/init.lua → keymaps.lua:52) DESPUÉS de cargar este plugin,
    -- y lo pisa. vim.schedule() aplaza el re-mapeo al final del tick, ganándole a
    -- la carrera: así el dismiss de neocursor vuelve a ganar en NORMAL/VISUAL.
    vim.schedule(function()
      vim.keymap.set(
        { "n", "i", "v" },
        "<S-Tab>",
        dismiss_esc,
        { noremap = true, silent = true, desc = "neocursor: dismiss and clear hlsearch" }
      )

      vim.keymap.set(
        { "n", "i", "v" },
        "<Esc>",
        dismiss_esc,
        { noremap = true, silent = true, desc = "neocursor: dismiss and clear hlsearch" }
      )
    end)

    -- 👻 Sugerencia predictiva en NORMAL: CursorHold pide la predicción (jump/ghost),
    -- replicando el disparo que Cursor hace al leer código. Evita conflictos con
    -- Supermaven/cursortab (que manejan INSERT) limitándonos a modo normal.
    vim.api.nvim_create_autocmd("CursorHold", {
      group = "neocursor",
      desc = "neocursor: sugerencia predictiva en normal",
      callback = function()
        if vim.api.nvim_get_mode().mode:match("^[nN]") then
          require("neocursor").suggest()
        end
      end,
    })
  end,
}
