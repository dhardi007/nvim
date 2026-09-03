-- 🤖 tabtab.nvim — Cursor-style next-edit con OpenRouter (cloud, SIN llama.cpp)
-- Repo: gaelph/tabtab.nvim.
-- Asiste escribiendo y propone hunks aplicables (aceptar/jump con Alt+Tab).
-- Usamos provider "openai" pero apuntando a OpenRouter: la variable
-- OPEN_ROUTER_API_KEY (con guion bajo) ya está en el entorno → sin servidor local.
-- Modelo coder barato/accesible en OpenRouter (cualquiera OpenAI-compatible).
return {
  "gaelph/tabtab.nvim",
  event = "VeryLazy",
  config = function()
    require("tabtab").setup({
      client = {
        -- OpenAI-compatible → OpenRouter (hosted). NO es llama.cpp.
        --  🚫No scope found at cursor position in buffer 22 🚫
        provider = "openai",
        api_key = vim.env.OPEN_ROUTER_API_KEY,
        api_base = "https://openrouter.ai/api/v1",
        defaults = {
          -- Modelo coder: balance calidad/latencia. OpenRouter model name.
          model = "qwen/qwen-2.5-coder-32b-instruct",
          temperature = 0.3,
          max_tokens = 4096,
        },
      },

      cursor = {
        exclude_filetypes = {
          "TelescopePrompt",
          "neo-tree",
          "NvimTree",
          "lazy",
          "mason",
          "help",
          "quickfix",
          "terminal",
          "Avante",
          "AvanteInput",
          "AvanteSelectedFiles",
          "diffview",
          "NeogitStatus",
        },
        exclude_buftypes = { "terminal" },
      },

      -- Alt+Enter aceptar/saltar entre hunks; Esc rechaza.
      keymaps = {
        accept_or_jump = "<M-CR>",
        reject = "<S-Tab>",
      },

      history_size = 20,
    })

    -- TabTab acepta/rechaza via keymaps BUFFER-LOCALES internos (no expone API
    -- pública accept()), así que el set consistente de keymaps se cumple con
    -- <M-CR> (accept_or_jump) y <S-Tab> (reject) de arriba. <Tab>/<C-CR> extra
    -- no se pueden enlazar sin tocar el plugin; se dejan los nativos.
    --
    -- Colores del diff consistentes: TabTab usa los grupos estándar Comment
    -- (añadido) y DiffStrikeThrough (eliminado). Los enlazamos a DiffAdd/
    -- DiffDelete (que el colorscheme ya colorea como verde/rojo) sin pisar nada.
    local function set_tabtab_hl()
      vim.api.nvim_set_hl(0, "TabTabDiffAdd", { link = "DiffAdd", default = true })
      vim.api.nvim_set_hl(0, "TabTabDiffDelete", { link = "DiffDelete", default = true })
    end
    set_tabtab_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_tabtab_hl })
  end,
}
