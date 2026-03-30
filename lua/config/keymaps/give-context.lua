
-- Extract from: keymaps.lua
-- ===================================================================================
-- Utilidades para Claude v2.1.6] ~ [by dizzi1222] - Yanked proyecto, copiar Proyecto
-- ===================================================================================
local is_wsl = vim.fn.has("wsl") == 1
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_wsl

vim.g.mapleader = " "

local keymap = vim.keymap

-- Función helper para obtener información del repositorio Git
local function get_repo_context()
  local cwd = vim.fn.getcwd()
  local git_root = vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")

  if vim.v.shell_error == 0 then
    git_root = git_root:gsub("\n", "")
    local repo_name = vim.fn.fnamemodify(git_root, ":t")
    local branch = vim.fn
      .system("git -C " .. vim.fn.shellescape(git_root) .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
      :gsub("\n", "")

    return {
      is_git = true,
      root = git_root,
      name = repo_name,
      branch = branch,
      relative_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:."),
    }
  end

  return {
    is_git = false,
    root = cwd,
    name = vim.fn.fnamemodify(cwd, ":t"),
    relative_path = vim.fn.expand("%:t"),
  }
end

-- Función para construir contexto rico para Claude
local function build_claude_context(selected_text, custom_instruction)
  local repo = get_repo_context()
  local file_type = vim.bo.filetype
  local line_num = vim.fn.line(".")
  local abs_path = vim.fn.expand("%:p") -- ruta absoluta real
  local rel_path = repo.relative_path -- relativa al root del repo/cwd

  local context = "📁 Proyecto: " .. repo.name .. "\n"
  if repo.is_git then
    context = context .. "🌿 Branch: " .. repo.branch .. "\n"
  end
  context = context .. "📄 Archivo: " .. rel_path .. "\n"
  context = context .. "📂 Ruta: " .. abs_path .. "\n"
  context = context .. "🔤 Tipo: " .. (file_type ~= "" and file_type or "text") .. "\n"
  context = context .. "📍 Línea: " .. line_num .. "\n"
  context = context .. "💻 Sistema: " .. (vim.fn.has("wsl") == 1 and "WSL" or vim.loop.os_uname().sysname) .. "\n\n"

  if custom_instruction then
    context = context .. "📝 Instrucción: " .. custom_instruction .. "\n\n"
  end

  if selected_text and selected_text ~= "" then
    context = context .. "```" .. file_type .. "\n" .. selected_text .. "\n```\n"
  end

  return context
end
-- =============================
-- KEYMAPS PARA CLAUDE AI
-- =============================
-- Atajo rápido: Copiar TODO el contexto actual al portapapeles
vim.keymap.set("n", "<leader>ay", function()
  local repo = get_repo_context()
  local full_file = vim.fn.join(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local context = build_claude_context(full_file, "Aquí está el archivo completo:")

  vim.fn.setreg("+", context)
  vim.notify("📋 Archivo completo + contexto copiado\n📁 " .. repo.name, vim.log.levels.INFO)
end, { desc = "   Copiar archivo completo con contexto" })

-- Atajo ultra-rápido: Solo copiar código seleccionado (sin abrir navegador)
vim.keymap.set("v", "<leader>ay", function()
  vim.cmd('normal! "+y')
  local selected_text = vim.fn.getreg('"')
  local context = build_claude_context(selected_text, nil)

  vim.fn.setreg("+", context)
  vim.notify("✅ Código + contexto copiado al portapapeles", vim.log.levels.INFO)
end, { desc = "   Copiar selección con contexto (sin abrir)" })

-- Comando para ver información del repositorio actual
vim.api.nvim_create_user_command("ClaudeInfo", function()
  local repo = get_repo_context()
  local info = "📊 INFORMACIÓN DEL PROYECTO\n\n"
  info = info .. "📁 Nombre: " .. repo.name .. "\n"
  info = info .. "📂 Root: " .. repo.root .. "\n"

  if repo.is_git then
    info = info .. "🌿 Branch: " .. repo.branch .. "\n"
    info = info .. "✅ Git: Sí\n"
  else
    info = info .. "❌ Git: No\n"
  end

  info = info .. "📄 Archivo: " .. repo.relative_path .. "\n"
  info = info .. "💻 Sistema: " .. (vim.fn.has("wsl") == 1 and "WSL" or vim.loop.os_uname().sysname)

  vim.notify(info, vim.log.levels.INFO)
end, { desc = "Ver info del proyecto para Claude" })
