-- 👻 sweep.nvim — Cursor-style FIM completions + next-edit (líneas verdes) [LOCAL-ONLY]
-- Repo: c0r73x/sweep.nvim. Proxy Python (llama-cpp-python) en socket unix; sin Go.
--
-- ⚠️ Este plugin es LOCAL por diseño: carga el modelo Sweep Next-Edit con
--    llama-cpp-python. NO tiene opción cloud. Por eso NO lo enlazamos a
--    llama-server: dejamos `provider.auto_start = false` y `model_path = nil`,
--    así NO arranca ni asume ningún servidor. Para usarlo:
--    (1) Runtime Nix Only ya disponible: llama-cpp-python/fastapi/uvicorn
--        instalados vía work.nix (python3.withPackages) — NO usar pip.
--    (2) Descargar un GGUF en proxy/models/ (p.ej. sweep-next-edit-1.5b.q8_0.v2.gguf).
--    (3) Setear model_path y auto_start = true. Hasta entonces permanece inactivo.
return {
  "c0r73x/sweep.nvim",
  cmd = { "SweepStatus", "SweepToggle", "SweepEdit", "SweepHide" }, -- lazy: solo al usarse
  config = function()
    require("sweep").setup({
      -- Keymaps coherentes con el set NES (M-CR principal, ESC siempre rechaza):
      -- <Tab> por defecto lo captura Supermaven en INSERT → usamos M-CR.
      keymaps = {
        accept = "<M-CR>", -- accept FIM completion
        sweep = "<M-CR>", -- accept edit prediction
        partial_accept = false,
        reject = false, -- ESC siempre rechaza
        trigger = false, -- auto only
      },

      behavior = {
        idle_completion_delay = 50,
        text_change_debounce = 50,
        edit_prediction_delay = 1000, -- predicción en NORMAL
        enabled_modes = { "i", "n" },
        ignore_gitignored = false,
        hide_on_cursor_move = true,
      },

      -- NO AUTO-START: no levantamos ningún servidor local.
      provider = {
        url = "http://127.0.0.1:5555",
        mode = "auto",
        max_tokens = 512,
        temperature = 0.0,
        completion_timeout = 5000,
        auto_start = false, -- require un entorno manual (modelo + llama-cpp-python)
        proxy_script = vim.fn.stdpath("data") .. "/lazy/sweep.nvim/proxy/sweep_proxy.py",
        model_path = nil, -- sin path → no arranca
      },

      context = {
        window_radius = 10,
        max_edit_history = 6,
        max_context_files = 3,
      },
    })

    -- ── Highlights NES consistentes con copilot.lua (verde #238636 / rojo #391a1a) ──
    local function set_sweep_hl()
      vim.api.nvim_set_hl(0, "SweepAddition", { fg = "#ffffff", bg = "#238636" })
      vim.api.nvim_set_hl(0, "SweepDeletion", { fg = "#ffa198", bg = "#391a1a" })
      vim.api.nvim_set_hl(0, "SweepModification", { fg = "#ffffff", bg = "#238636" })
    end
    set_sweep_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_sweep_hl })

    -- ── Keymaps NES extra (set consistente con copilot.lua) ──
    local function sweep_accept()
      local sw = _G.sweep
      if sw and sw.ghost_text and sw.ghost_text:has_completion() then
        sw:accept()
        return true
      end
      return false
    end

    local function sweep_reject()
      local sw = _G.sweep
      if sw and sw.ghost_text and sw.ghost_text:has_completion() then
        sw:reject()
      end
    end

    -- <Tab> en NORMAL/VISUAL: aceptar predicción o fallback a C-i
    vim.keymap.set({ "n", "v" }, "<Tab>", function()
      if sweep_accept() then
        return nil
      end
      return "<C-i>"
    end, { expr = true, noremap = true, desc = "sweep: Aceptar o C-i" })

    -- <C-CR> en N/I/V: aceptar (alias extra, coherente con copilot.lua)
    vim.keymap.set({ "n", "i", "v" }, "<C-CR>", function()
      sweep_accept()
    end, { noremap = true, silent = true, desc = "sweep: Aceptar (C-CR)" })

    -- <S-Tab> en N/I/V: rechazar (set NES consistente)
    vim.keymap.set({ "n", "i", "v" }, "<S-Tab>", sweep_reject, {
      noremap = true,
      silent = true,
      desc = "sweep: Rechazar (S-Tab)",
    })
  end,
}
