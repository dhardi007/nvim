-- Extract from: keymaps.lua
-- Detectar plataforma
local is_wsl = vim.fn.has("wsl") == 1
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_wsl

vim.g.mapleader = " "

local keymap = vim.keymap

-- =============================
-- CERRAR BUFFERS INTELIGENTE
-- =============================
--🛑 🗿 Cerrar pestaña
keymap.set("n", "<C-q>", function()
  local buftype = vim.bo.buftype
  local filetype = vim.bo.filetype

  -- Lista de ventanas especiales que deben cerrarse con :close
  local special_filetypes = {
    "neo-tree",
    "NvimTree",
    "help",
    "qf",
    "quickfix",
    "terminal",
    "Avante",
    "AvanteInput",
    "copilot-chat",
  }

  -- Verificar si es una ventana especial
  local is_special = vim.tbl_contains(special_filetypes, filetype) or buftype ~= ""

  if is_special then
    -- Ventanas especiales: cierra la ventana
    pcall(vim.cmd, "close")
    return
  end

  -- Contar buffers normales listados
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local normal_buffers = vim.tbl_filter(function(buf)
    return vim.fn.getbufvar(buf.bufnr, "&buftype") == ""
  end, buffers)

  if #normal_buffers > 1 then
    -- Hay otros buffers: cierra este con bdelete!
    vim.cmd("bdelete!")
  else
    -- Es el último buffer normal: cierra Neovim
    vim.cmd("quit!")
  end
end, {
  noremap = true,
  silent = true,
  desc = "Cerrar buffer/ventana inteligente",
})
--
-- =============================
-- OCULTAR/MOSTRAR BUFFERS
-- =============================

-- Ocultar buffer actual (sin cerrarlo)
keymap.set("n", "<leader>bh", ":hide<CR>", {
  desc = "Ocultar buffer (mantener en memoria)",
})

-- Mostrar lista de buffers ocultos
keymap.set("n", "<leader>ba", ":ls!<CR>", {
  desc = "All - Listar todos los buffers (incluyendo ocultos)",
})

-- Cambiar a buffer específico (incluso si está oculto)
keymap.set("n", "<leader>bz", ":buffers<CR>:buffer<Space>", {
  desc = "Zxy - Cambiar a buffer por número",
})

-- Cerrar buffer ACTUAL pero mantener ventana (usando enew)
keymap.set("n", "<leader>bc", ":enew | bdelete #<CR>", {
  desc = "Cerrar buffer pero mantener ventana",
})
