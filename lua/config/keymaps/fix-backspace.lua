-- Extract from: keymaps.lua
local is_wsl = vim.fn.has("wsl") == 1
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_wsl

vim.g.mapleader = " "

local keymap = vim.keymap
-- =============================
-- FIX DEL CONTROL Backspace
-- =============================

-- Activar backspace+Control - MODO INSERCION COMO EN VSCODE!!! = Ctrl W
-- WINDOWS USA C-BS
vim.api.nvim_set_keymap("i", "<C-BS>", "<C-W>", { noremap = true, silent = true })
-- LINUX USA C-H
vim.api.nvim_set_keymap("i", "<C-H>", "<C-W>", { noremap = true, silent = true })

-- 🚨📌🗿🔥Mapeo para Ctrl + backspace a Ctrl + W en el modo de línea de comandos (la : )🚨📌🗿🔥
-- Mapeo que usa una función para asegurar que funciona en la línea de comandos

if is_wsl or is_windows then
  vim.keymap.set("c", "<C-H>", function()
    -- Cierra cualquier ventana de completado y luego ejecuta el comando Ctrl-W
    -- El comando \b borra una palabra hacia atrás
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-W>", true, true, true), "n", true)
  end, { noremap = true, silent = true })
else
  vim.keymap.set("c", "<C-BS>", function()
    -- Cierra cualquier ventana de completado y luego ejecuta el comando Ctrl-W
    -- El comando \b borra una palabra hacia atrás
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-W>", true, true, true), "n", true)
  end, { noremap = true, silent = true })
end
-- ---------------------------------------------------|-
--👹📌🗿🔥Mismo mapeo pero para el modo de inserción en buffers normales👹📌🗿🔥
-- Función mejorada para borrar palabras en buffers de snacks [Tanto en Linux como Windows/wsl]
local function delete_previous_word()
  -- Obtener posición actual
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1], pos[2]
  local line = vim.api.nvim_get_current_line()

  -- Encontrar el inicio de la palabra anterior
  local word_start = col
  while word_start > 0 and line:sub(word_start, word_start):match("%s") do
    word_start = word_start - 1
  end

  while word_start > 0 and not line:sub(word_start, word_start):match("%s") do
    word_start = word_start - 1
  end

  -- Ajustar índices (Lua es 1-indexed, Neovim API es 0-indexed)
  word_start = word_start + 1

  -- Borrar la palabra
  if word_start <= col then
    vim.api.nvim_buf_set_text(0, row - 1, word_start - 1, row - 1, col, { "" })
    vim.api.nvim_win_set_cursor(0, { row, word_start - 1 })
  end
end

-- Aplicar a TODOS los tipos de buffers de snacks
local snack_filetypes = {
  "snacks_picker_input",
  "snacks_picker_list",
  "snacks_picker_recent",
  "snacks_picker_files",
  "snacks_picker_smart",
}

for _, ft in ipairs(snack_filetypes) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    callback = function()
      -- Habilitar modifiable temporalmente
      vim.bo.modifiable = true

      -- Mapear Ctrl+Backspace y Ctrl+H
      vim.keymap.set("i", "<C-BS>", delete_previous_word, {
        buffer = true,
        noremap = true,
        silent = true,
        desc = "Borrar palabra anterior",
      })

      vim.keymap.set("i", "<C-H>", delete_previous_word, {
        buffer = true,
        noremap = true,
        silent = true,
        desc = "Borrar palabra anterior",
      })
    end,
  })
end
