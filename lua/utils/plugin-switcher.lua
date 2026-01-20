-- lua/utils/plugin-switcher.lua
local M = {}

local PLUGINS_CONFIG = {
  -- 🤖 AI Assistants
  avante = {
    name = "Avante",
    icon = "",
    file = "avante-cursor.lua",
    category = "AI Assistant",
  },
  copilot_chat = {
    name = "CopilotChat",
    icon = "",
    file = "copilot-chat.lua",
    category = "AI Assistant",
  },

  -- 🔮 AI Autocompletion
  copilot = {
    name = "Copilot",
    icon = "",
    file = "copilot.lua",
    category = "AI Completion",
  },
  supermaven = {
    name = "Supermaven",
    icon = "",
    file = "supermaven.lua",
    category = "AI Completion",
  },
  tabnine = {
    name = "TabNine",
    icon = "󰓅",
    file = "tabnine.lua",
    category = "AI Completion",
  },
  codeium = {
    name = "Codeium-Windsurf",
    icon = "",
    file = "windsurf-codeium.lua",
    category = "AI Completion",
  },

  -- 🎮 OpenCode variants
  opencode_sudo = {
    name = "OpenCode (sudo-tee)",
    icon = "󰮮",
    file = "opencode.lua",
    category = "OpenCode",
  },
  opencode_nick = {
    name = "OpenCode (NickvanDyke)",
    icon = "󰮮",
    file = "opencode-chat.lua",
    category = "OpenCode",
  },
  codecompanion = {
    name = "CodeCompanion",
    icon = "",
    file = "codecompanion.lua",
    category = "AI Assistant",
  },

  -- 🌟 Claude variants
  claude_old = {
    name = "Claude Code (old)",
    icon = "",
    file = "claude-code-old.lua",
    category = "Claude",
  },
  claude_new = {
    name = "Claude Code (new)",
    icon = "",
    file = "claude-code.lua",
    category = "Claude",
  },

  -- 💬 Other AI
  gemini_cli = {
    name = "Gemini CLI",
    icon = "󰊭",
    file = "gemini-cli.lua",
    category = "AI Assistant",
  },

  -- 🎨 UI/UX
  bufferline = {
    name = "Bufferline",
    icon = "󰓩",
    file = "bufferline.lua",
    category = "UI",
  },
  snacks = {
    name = "Snacks",
    icon = "",
    file = "snacks.lua",
    category = "UI",
  },
  smear_cursor = {
    name = "Smear Cursor",
    icon = "󱄧",
    file = "smear-cursor.lua",
    category = "UI",
  },
  precognition = {
    name = "Precognition",
    icon = "󰗹",
    file = "precognition.lua",
    category = "UI",
  },

  -- 🎮 Discord
  presence = {
    name = "Discord Presence",
    icon = "󰙯",
    file = "presence.lua",
    category = "Discord",
  },
  cord = {
    name = "Cord (Discord)",
    icon = "󰙯",
    file = "cord.lua",
    category = "Discord",
  },

  -- 📝 Productivity
  obsidian = {
    name = "Obsidian",
    icon = "",
    file = "obsidian.lua",
    category = "Productivity",
  },
}

local function get_disabled_path()
  return vim.fn.stdpath("config") .. "/lua/plugins/disabled"
end

local function get_plugins_path()
  return vim.fn.stdpath("config") .. "/lua/plugins"
end

local function is_plugin_disabled(plugin_key)
  local config = PLUGINS_CONFIG[plugin_key]
  if not config then
    return false
  end

  local disabled_file = get_disabled_path() .. "/" .. config.file
  return vim.fn.filereadable(disabled_file) == 1
end

local function move_plugin(plugin_key, to_disabled)
  local config = PLUGINS_CONFIG[plugin_key]
  if not config then
    vim.notify("❌ Plugin desconocido: " .. plugin_key, vim.log.levels.ERROR)
    return false
  end

  local from_dir = to_disabled and get_plugins_path() or get_disabled_path()
  local to_dir = to_disabled and get_disabled_path() or get_plugins_path()

  local from_file = from_dir .. "/" .. config.file
  local to_file = to_dir .. "/" .. config.file

  -- Verificar que el archivo origen existe
  if vim.fn.filereadable(from_file) ~= 1 then
    vim.notify(
      "⚠️  " .. config.icon .. " " .. config.name .. " ya está " .. (to_disabled and "desactivado" or "activado"),
      vim.log.levels.WARN
    )
    return false
  end

  -- Crear directorio destino si no existe
  vim.fn.mkdir(to_dir, "p")

  -- Mover archivo
  local success = vim.fn.rename(from_file, to_file) == 0

  if success then
    local status = to_disabled and "❌ Desactivado" or "✅ Activado"
    vim.notify(
      status .. ": " .. config.icon .. " " .. config.name .. "\n\n🔄 Reinicia Neovim para aplicar cambios",
      vim.log.levels.WARN
    )
    return true
  else
    vim.notify("❌ Error moviendo " .. config.name, vim.log.levels.ERROR)
    return false
  end
end

function M.toggle_plugin(plugin_key)
  local is_disabled = is_plugin_disabled(plugin_key)
  move_plugin(plugin_key, not is_disabled)
end

function M.disable_plugin(plugin_key)
  if not is_plugin_disabled(plugin_key) then
    move_plugin(plugin_key, true)
  end
end

function M.enable_plugin(plugin_key)
  if is_plugin_disabled(plugin_key) then
    move_plugin(plugin_key, false)
  end
end

-- UI interactiva MEJORADA con categorías
function M.interactive_toggle()
  local choices = {}
  local categories = {}

  -- Agrupar por categoría
  for key, config in pairs(PLUGINS_CONFIG) do
    if not categories[config.category] then
      categories[config.category] = {}
    end
    table.insert(categories[config.category], {
      key = key,
      config = config,
      disabled = is_plugin_disabled(key),
    })
  end

  -- Ordenar categorías
  local category_order = {
    "AI Assistant",
    "AI Completion",
    "OpenCode",
    "Claude",
    "UI",
    "Discord",
    "Productivity",
  }

  -- Construir lista de opciones
  for _, cat_name in ipairs(category_order) do
    local plugins = categories[cat_name]
    if plugins then
      -- Header de categoría
      table.insert(choices, "─── " .. cat_name .. " ───")

      -- Plugins de la categoría
      table.sort(plugins, function(a, b)
        return a.config.name < b.config.name
      end)
      for _, item in ipairs(plugins) do
        local status = item.disabled and "❌" or "✅"
        table.insert(
          choices,
          "  " .. status .. " " .. item.config.icon .. " " .. item.config.name .. " (" .. item.key .. ")"
        )
      end
    end
  end

  table.insert(choices, "─────────────────")
  table.insert(choices, "🚫 Cancelar")

  vim.ui.select(choices, {
    prompt = "🔌 Toggle Plugin:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if not choice or choice:match("🚫") or choice:match("^───") then
      return
    end

    -- Extraer el key del plugin del texto entre paréntesis
    local plugin_key = choice:match("%((.-)%)")
    if plugin_key then
      M.toggle_plugin(plugin_key)
    end
  end)
end

-- UI para toggle por categoría
function M.toggle_by_category(category)
  local plugins = {}

  for key, config in pairs(PLUGINS_CONFIG) do
    if config.category == category then
      table.insert(plugins, {
        key = key,
        config = config,
        disabled = is_plugin_disabled(key),
      })
    end
  end

  if #plugins == 0 then
    vim.notify("⚠️  No hay plugins en la categoría: " .. category, vim.log.levels.WARN)
    return
  end

  local choices = {}
  table.sort(plugins, function(a, b)
    return a.config.name < b.config.name
  end)

  for _, item in ipairs(plugins) do
    local status = item.disabled and "❌" or "✅"
    table.insert(choices, status .. " " .. item.config.icon .. " " .. item.config.name .. " (" .. item.key .. ")")
  end

  table.insert(choices, "🚫 Cancelar")

  vim.ui.select(choices, {
    prompt = "🔌 " .. category .. ":",
  }, function(choice)
    if not choice or choice:match("🚫") then
      return
    end

    local plugin_key = choice:match("%((.-)%)")
    if plugin_key then
      M.toggle_plugin(plugin_key)
    end
  end)
end

-- Shortcuts para categorías comunes
function M.toggle_ai_completion()
  M.toggle_by_category("AI Completion")
end

function M.toggle_ai_assistant()
  M.toggle_by_category("AI Assistant")
end

function M.toggle_discord()
  M.toggle_by_category("Discord")
end

return M
