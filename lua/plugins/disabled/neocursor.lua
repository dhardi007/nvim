-- 👻 neocursor.nvim — Cursor Tab-Tab-Tab real en Neovim
-- Usa la sesión REAL de la app Cursor (instalada y firmada): nada de API keys,
-- no consume OpenRouter, calidad genuina de Cursor Tab (ghost text + saltos).
-- Requiere: app Cursor instalada + `uv` en PATH (ambos en work.nix).
-- Referencia de keymaps: copilot.lua (set de atajos NES) para consistencia.
return {
  "teocns/neocursor.nvim",
  event = "InsertEnter",
  -- [dizzi patch] build = precalienta deps del sidecar + re-aplica el parche que
  -- mueve el ghost text/los diff sugeridos DEBAJO de la línea (por defecto un
  -- insert puro los pinta ARRIBA, molesto). Lazy re-ejecuta build tras cada update.
  build = function()
    vim.cmd('!uv run --with "httpx[http2]" python -c "import httpx"')
    -- [dizzi patch] Forzar ghost text/diff DEBAJO de la línea (idempotente).
    local path = vim.fn.stdpath("data") .. "/lazy/neocursor.nvim/lua/neocursor/preview.lua"
    local ok, content = pcall(vim.fn.readfile, path)
    if not ok then
      return
    end
    local joined = vim.fn.join(content, "\n")
    local patched = joined:gsub(
      "anchor, above = start0, true %-%- pure insert before region start",
      "anchor, above = start0, false -- [dizzi patch] below, not above"
    ):gsub(
      'virt_lines_above = above,',
      'virt_lines_above = false,'
    )
    if patched ~= joined then
      vim.fn.writefile(vim.fn.split(patched, "\n"), path)
    end
  end,
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
    require("neocursor").setup(opts)

    -- Aceptar o saltar al siguiente edit (flujo tab-tab-tab de Cursor).
    -- Estos binds replican el set de atajos NES de copilot.lua.
    local function accept()
      if require("neocursor").accept() then
        return
      end
    end
    for _, lhs in ipairs({ "<C-CR>", "<M-CR>", "<Tab>" }) do
      vim.keymap.set({ "n", "i", "v" }, lhs, accept, { noremap = true, silent = true, desc = "neocursor: accept/jump" })
    end
  end,
}
