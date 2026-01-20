-- v1.0.0 - Cargador de API Keys solo para Windows 🔐
-- Para Linux/WSL: usar .zshrc directamente
local M = {}

function M.setup()
  -- Detectar entorno
  local is_windows = vim.fn.has("win32") == 1

  -- 🚫 Si NO es Windows, no hacer nada (usar .zshrc)
  if not is_windows then
    return
  end

  -- ================================================
  -- SOLO WINDOWS: Cargar desde archivo .env
  -- ================================================
  local env_file = vim.fn.expand("$HOME/.api-keys.env")

  local function load_api_keys()
    if vim.fn.filereadable(env_file) == 0 then
      vim.notify("⚠️  Archivo .api-keys.env no encontrado en: " .. env_file, vim.log.levels.WARN)
      return false
    end

    -- Leer archivo línea por línea
    local lines = vim.fn.readfile(env_file)
    local loaded_count = 0

    for _, line in ipairs(lines) do
      -- Ignorar comentarios y líneas vacías
      if not line:match("^%s*#") and not line:match("^%s*$") then
        -- Parsear KEY=VALUE
        local key, value = line:match("^([^=]+)=(.+)$")
        if key and value then
          -- Remover espacios y comillas
          key = key:gsub("^%s*(.-)%s*$", "%1")
          value = value:gsub("^%s*(.-)%s*$", "%1"):gsub('^"(.-)"$', "%1"):gsub("^'(.-)'$", "%1")

          -- Setear en vim.env (afecta solo a Neovim)
          vim.env[key] = value
          loaded_count = loaded_count + 1
        end
      end
    end

    if loaded_count > 0 then
      vim.notify("✅ " .. loaded_count .. " API Keys cargadas en Neovim (Windows)", vim.log.levels.INFO)
    else
      vim.notify("⚠️  No se encontraron API Keys válidas", vim.log.levels.WARN)
    end

    return true
  end

  -- ================================================
  -- AUTORUN AL INICIO
  -- ================================================
  vim.defer_fn(function()
    load_api_keys()
  end, 500) -- 0.5 segundos

  -- ================================================
  -- COMANDOS Y KEYMAPS
  -- ================================================
  vim.keymap.set("n", "<leader>lk", load_api_keys, {
    desc = "🔑 Recargar API Keys (Windows)",
  })

  vim.api.nvim_create_user_command("ApiKeysReload", load_api_keys, {
    desc = "🔄 Recargar API Keys",
  })

  vim.api.nvim_create_user_command("ApiKeysEdit", function()
    vim.cmd("edit " .. env_file)
  end, { desc = "✏️  Editar .api-keys.env" })

  vim.api.nvim_create_user_command("ApiKeysTest", function()
    local keys = { "GEMINI_API_KEY", "ANTHROPIC_API_KEY", "DEEPSEEK_API_KEY", "AVANTE_GEMINI_API_KEY" }

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🔑 Estado de API Keys (Windows):")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    for _, key in ipairs(keys) do
      local value = vim.env[key]
      if value and value ~= "" then
        print(key .. ": ✅ Configurada (" .. #value .. " chars)")
      else
        print(key .. ": ❌ No configurada")
      end
    end

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📁 Archivo: " .. env_file)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  end, { desc = "🔍 Verificar API Keys" })
end

return M
