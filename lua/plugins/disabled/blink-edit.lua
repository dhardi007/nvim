-- 👻 blink-edit.nvim — Cursor-style next-edit (ghost text) [LOCAL-ONLY]
-- Repo: BlinkResearchLabs/blink-edit.nvim. Puro Lua (sin sidecar).
--
-- ⚠️ Este plugin es LOCAL por diseño: proveedores "sweep" y "zeta"; conecta a un
--    backend OpenAI-compatible u Ollama. NO tiene opción cloud.
--
-- ❗ IMPORTANTE (valida): NO lo actives con tu Qwen3.5-0.8B base.
--    Los providers "sweep"/"zeta" construyen prompts con formatos propietarios
--    (marcadores <|file_sep|> o "### Goal:") que requieren un modelo FINe-TUNEado
--    en ese formato (sweep-next-edit, zed-industries/zeta), NO un modelo base.
--    Conectar Qwen base al :8000 SÍ conectaría (OpenAI-compatible) pero las
--    predicciones serían malas. Para aprovechar tu llama-server Qwen usa
--    cursortab con provider `inline` (diseñado para modelos base).
--    Si aun así lo activas, sirve un GGUF de la familia sweep en :8000.
return {
  "BlinkResearchLabs/blink-edit.nvim",
  cmd = { "BlinkEditStatus", "BlinkEditToggle" }, -- lazy: solo carga al usarse
  config = function()
    require("blink-edit").setup({
      llm = {
        backend = "openai",
        provider = "sweep", -- "sweep" | "zeta" (ambos exigen GGUF fine-tuneado)
        url = "http://localhost:8000", -- expects un servidor ya corriendo
        model = "sweepai/sweep-next-edit-0.5B", -- GGUF sweep a servir vía llama-server -hf
        temperature = 0.0,
        max_tokens = 512,
        timeout_ms = 5000,
      },

      normal_mode = {
        enabled = false, -- predecir solo al editar (insert), no en NORMAL
        debounce_ms = 200,
      },

      context = {
        enabled = true,
        max_tokens = 512,
        lsp = {
          enabled = true,
          max_definitions = 2,
          max_references = 2,
          timeout_ms = 100,
        },
        same_file = { enabled = true, max_lines_before = 20, max_lines_after = 20 },
      },

      ui = {
        progress = true,
        suppress_lsp_floats = true, -- no solapar floats LSP
      },

      -- Colores NES consistentes con copilot.lua/nextedit.lua (verde #238636 / rojo #391a1a)
      highlight = {
        addition = { bg = "#238636", fg = "#ffffff" }, -- texto añadido
        deletion = { bg = "#391a1a", fg = "#ffa198" }, -- texto eliminado
        preview = { fg = "#80899c", italic = true }, -- ghost text (mantiene default)
        jump = { fg = "#5c6370", bg = "#2d3343", bold = true }, -- indicador TAB
      },

      debounce_ms = 100,

      keymaps = {
        insert = {
          accept = "<M-CR>", -- coherente con nextedit/neocursor (M-CR principal)
          accept_line = "<C-j>",
          clear = "<C-]>",
          reject = "<S-Tab>",
        },
        normal = {
          accept = nil, -- normal_mode desactivado
          accept_line = nil,
        },
      },
    })

    -- ── Keymaps NES extra (set consistente con copilot.lua) ──
    local nextedit_api = function(mod, fn)
      local ok, plugin = pcall(require, mod)
      if ok and plugin and plugin[fn] then
        plugin[fn]()
        return true
      end
      return false
    end

    -- <Tab> en NORMAL/VISUAL: aceptar o fallback a C-i
    vim.keymap.set({ "n", "v" }, "<Tab>", function()
      if nextedit_api("blink-edit", "accept") then
        return nil
      end
      return "<C-i>"
    end, { expr = true, noremap = true, desc = "blink-edit: Aceptar o C-i" })

    -- <C-CR> en N/I/V: aceptar (alias extra, coherente con copilot.lua)
    vim.keymap.set({ "n", "i", "v" }, "<C-CR>", function()
      nextedit_api("blink-edit", "accept")
    end, { noremap = true, silent = true, desc = "blink-edit: Aceptar (C-CR)" })

    -- <S-Tab> en N/I/V: rechazar (set NES consistente). El plugin ya lo usa en
    -- insert (keymaps.insert.reject); esto añade cobertura en NORMAL/VISUAL.
    vim.keymap.set({ "n", "i", "v" }, "<S-Tab>", function()
      nextedit_api("blink-edit", "reject")
    end, { noremap = true, silent = true, desc = "blink-edit: Rechazar (S-Tab)" })
  end,
}
