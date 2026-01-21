-- Extract from: keymaps.lua
local is_wsl = vim.fn.has("wsl") == 1
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_wsl

vim.g.mapleader = " "

local keymap = vim.keymap
-- =============================
-- ABRIR EXPLORER, EN macOS, wsl, Linux
-- =============================

-- Abrir el explorador de archivos o copiar la ruta del archivo actual
-- Tanto en Windows Explorer, Linux (Nautilus, Dolphin, Thunar) y macOS
-- Si, Dolphin es un explorer..

-- Abrir el explorador de archivos o copiar la ruta del archivo actual
local function open_file_manager(dir_path, file_path)
  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    -- Windows nativo
    local windows_path = file_path:gsub("/", "\\")
    os.execute('explorer /select,"' .. windows_path .. '"')
  elseif vim.fn.has("wsl") == 1 then
    -- WSL: Abrir Windows Explorer
    local windows_path = vim.fn.system("wslpath -w " .. vim.fn.shellescape(file_path)):gsub("\n", "")
    vim.fn.jobstart({ "explorer.exe", "/select,", windows_path }, { detach = true })
  elseif vim.fn.has("unix") == 1 then
    -- Linux nativo (no WSL)
    if vim.fn.executable("nautilus") == 1 then
      local command = string.format(
        "dbus-send --session --print-reply --dest=org.freedesktop.FileManager1 "
          .. "/org/freedesktop/FileManager1 org.freedesktop.FileManager1.ShowItems "
          .. 'array:string:"file://%s" string:""',
        file_path
      )
      os.execute(command .. " >/dev/null 2>&1 &")
    elseif vim.fn.executable("dolphin") == 1 then
      vim.fn.jobstart({ "dolphin", "--select", file_path }, { detach = true })
    elseif vim.fn.executable("thunar") == 1 then
      vim.fn.jobstart({ "thunar", dir_path }, { detach = true })
    elseif vim.fn.executable("nemo") == 1 then
      vim.fn.jobstart({ "nemo", file_path }, { detach = true })
    else
      vim.notify("❌ No se encontró gestor de archivos. Instala nautilus/dolphin/thunar", vim.log.levels.ERROR)
    end
  elseif vim.fn.has("mac") == 1 then
    -- macOS
    vim.fn.jobstart({ "open", "-R", file_path }, { detach = true })
  end
end

-- El resto del código permanece igual
local function copy_file_path()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    vim.notify("No hay un archivo activo", vim.log.levels.WARN)
    return
  end

  -- Obtener información del archivo
  local absolute_path = vim.fn.expand("%:p")
  local relative_path = vim.fn.expand("%")
  local filename = vim.fn.expand("%:t")
  local dir_path = vim.fn.fnamemodify(absolute_path, ":h")

  -- Verificar si el archivo existe en el disco
  local file_exists = vim.fn.filereadable(absolute_path) == 1

  -- Opciones de copiado
  local options = {
    "📋 Ruta absoluta: " .. absolute_path,
    "📁 Ruta relativa: " .. relative_path,
    "📄 Nombre del archivo: " .. filename,
  }

  if file_exists then
    -- Solo mostrar la opción de abrir en el explorador si el archivo existe
    table.insert(options, "🚀 Abrir en el explorador de archivos")
  end

  -- Mostrar selector de opciones
  vim.ui.select(options, {
    prompt = "Selecciona qué acción realizar:",
  }, function(choice, idx)
    if not choice then
      return
    end

    if choice:find("explorador") then
      -- Abrir en el explorador de archivos
      open_file_manager(dir_path, absolute_path)
      vim.notify("Explorador abierto: " .. filename, vim.log.levels.INFO)
    else
      -- Copiar al portapapeles
      local text_to_copy = choice:gsub("^[^:]+: ", "")
      vim.fn.setreg("+", text_to_copy)
      vim.fn.setreg('"', text_to_copy)
      vim.notify("Copiado: " .. text_to_copy, vim.log.levels.INFO)
    end
  end)
end

-- Mapeo para Ctrl+Alt+R (como VSCode)
vim.keymap.set("n", "<C-A-r>", copy_file_path, { desc = "🔎Copiar ruta del archivo (VSCode style)" })
-- Opción A: <leader>r (Ruta)
vim.keymap.set("n", "<leader>r", copy_file_path, { desc = "🔎Copiar ruta del archivo (VSCode style)" })

-- Comando personalizado
vim.api.nvim_create_user_command("CopyPath", copy_file_path, {})
