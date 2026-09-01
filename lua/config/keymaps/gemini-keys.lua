-- Extract from: keymaps.lua
-- =============================
-- KEYMAPS GEMINI AI 🐐🗣️🔥️✍️ NO REQUIERE API
-- =============================
-- Aqui veras:
-- Gemini-cli que abre al lado en vertical [Gemini > Copilot, ofrece mas prompts GRATIS]
-- Funcion que selecciona y copia el texto para enviarlo a Gemini
-- Mapeo para salir del terminal con ESC
-- La función open_gemini modificada para usar comillas dobles
-- Detectar plataforma
local is_wsl = vim.fn.has("wsl") == 1
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_wsl

vim.g.mapleader = " "

local keymap = vim.keymap

vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true })

local function open_gemini(prompt, input_text)
  local root = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
  vim.cmd("vsplit | vertical resize 50")
  local cmd = 'agy --prompt-interactive "' .. prompt .. '" --add-dir "' .. root .. '"'
  vim.cmd("term " .. cmd)
  if input_text and input_text ~= "" then
    vim.defer_fn(function()
      vim.api.nvim_chan_send(vim.b.terminal_job_id, input_text .. "\n")
    end, 500)
  end
  vim.cmd("startinsert")
end

local function show_gemini_menu(selected_text)
  local options = {
    "   Revisar código",
    "  󱜨 Explicar código",
    "   Debuggear error",
    "  󰈏 Refactorizar",
    "  󰓅 Optimizar",
    "   󱋑 Personalizado [Abrir gemini]",
  }

  vim.ui.select(options, {
    prompt = " 󰊭 ~ Selecciona acción:",
  }, function(choice, idx)
    if not choice then
      return
    end

    local prompts = {
      "Revisa este código y sugiere mejoras:",
      "Explica este código paso a paso:",
      "Debuggea este error:",
      "Refactoriza este código:",
      "Optimiza este código:",
      "", -- Personalizado
    }

    if idx == 6 then -- Opción personalizada
      vim.ui.input({
        prompt = "Tu prompt: ",
      }, function(input)
        if input and input ~= "" then
          open_gemini(input, selected_text)
        end
      end)
    else
      open_gemini(prompts[idx], selected_text)
    end
  end)
end

-- Mapeo para modo normal
keymap.set("n", "<leader>ag", function()
  show_gemini_menu(nil)
end, {
  desc = " 󰊭 ~ Abrir Gemini con menú",
})

-- Mapeo para modo visual
keymap.set("v", "<leader>ag", function()
  -- Copiar texto seleccionado al portapapeles del sistema
  vim.cmd('normal! "+y')
  local selected_text = vim.fn.getreg('"')
  show_gemini_menu(selected_text)
end, {
  desc = " 󰊭 ~ Enviar selección a Gemini",
})
-- Mapeos para el plugin de Geminia.lua gentleman (si está instalado) ~[💸💳💰REQUIERE API:]
local has_gemini, gemini_chat = pcall(require, "gemini.chat")
if has_gemini then
  keymap.set("n", "<leader>gg", function()
    gemini_chat.prompt_current()
  end, { desc = " 󰊭 Gemini: prompt en buffer actual" })

  keymap.set("v", "<leader>g", function()
    gemini_chat.prompt_selected()
  end, { desc = " 󰊭 Gemini: prompt con texto seleccionado" })

  keymap.set("n", "<leader>gl", function()
    gemini_chat.prompt_line()
  end, { desc = " 󰊭 Gemini: prompt con línea actual" })
end
