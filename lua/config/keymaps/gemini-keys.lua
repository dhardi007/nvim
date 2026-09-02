-- =============================================================
-- KEYMAPS ANTIGRAVITY AI 󰨞 (agy)  NO REQUIERE API
-- =============================================================
-- Integración con lua/plugins/antigravity.lua (NakLast/antigravity-cli.nvim)
-- Patrón tomado de opencode-chat.lua:
--   - agy_send(): detecta el buffer terminal PERSISTENTE del plugin y envía
--     texto por su canal. Si no existe, lo abre vía require("antigravity").
--     CERO ventanas nuevas: el plugin mantiene state.buf entre toggles.
--
--   Prefijo de acciones: <leader>ag (Space + a + g)
--     <leader>ag  menú prompts (revisar/explicar/debuggear/refactorizar/...)
--     <leader>agt toggle (no slash)   <leader>agp /plan
--     <leader>agg /goal               <leader>agr /resume (switch)
--     <leader>agn /clear (new)        <leader>agf /fork (branch)
--     <leader>agm /model              <leader>agx /exit (quit)
--     <leader>agd /diff               <leader>agc /context
--     <leader>agv /btw                <leader>age /grill-me
--     <leader>ags /skills             <leader>ago /open
--     <leader>agR /rename             <leader>agC /changelog
--     <leader>agI limpiar prompt + interrumpir (Enter+ESC, NO cierra)
--                (Ctrl+C en agy SÍ cierra el TUI; por eso agI usa ESC)
--
--   Envío de código con líneas exactas (estilo opencode @file, SIN contenido):
--     <leader>agb → buffer ACTUAL      (ref @ruta:1-N)
--     <leader>agB → TODOS los buffers  (refs @ruta:1-N por archivo)
--     visual <leader>ag → SELECCIÓN    (ref @ruta:start-end)
--
--   Slash commands reales de agy (verificados en el menú / del CLI):
--   /plan /goal /grill-me /btw /resume (switch) /rewind (undo)
--   /clear (new) /fork (branch) /diff /context /model /permissions
--   /agents /tasks /artifact /add-dir /codesearch /mcp /hooks
--   /keybindings /config (settings) /rename /copy /schedule /usage
--   /credits /feedback /learn /skills /open /title /statusline
--   /exit (quit) /logout /changelog /help
-- =============================================================

local is_wsl = vim.fn.has("wsl") == 1
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_wsl

vim.g.mapleader = " "

local keymap = vim.keymap

vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true })

-- ── Envío al buffer persistente de agy ───────────────────────
-- Busca un buffer terminal cuyo nombre matchee "agy" (el que abre
-- lua/plugins/antigravity.lua con `term agy`). Si el canal está vivo,
-- envía el texto y opcionalmente enfoca la ventana. Devuelve true/false.
local function agy_send(text, focus)
  if focus == nil then
    focus = true
  end
  local bufs = vim.api.nvim_list_bufs()
  for i = 1, #bufs do
    local buf = bufs[i]
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("agy") then
        local chan = vim.bo[buf].channel
        if chan and chan > 0 then
          vim.api.nvim_chan_send(chan, text)
          if focus then
            local win = vim.fn.bufwinid(buf)
            if win ~= -1 then
              vim.api.nvim_set_current_win(win)
              vim.cmd("startinsert")
            end
          end
          return true
        end
      end
    end
  end
  return false
end

-- Último recurso: si no hay plugin disponible, abre un terminal plano
-- en un vsplit y le escribe el texto pasados 1.2s (arranque de agy).
local function agy_fallback_open(text)
  vim.cmd("vsplit | vertical resize 50")
  vim.cmd("term agy")
  vim.defer_fn(function()
    local bufs = vim.api.nvim_list_bufs()
    for i = 1, #bufs do
      local buf = bufs[i]
      if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):match("agy") then
        local chan = vim.bo[buf].channel
        if chan and chan > 0 then
          vim.api.nvim_chan_send(chan, text)
        end
        break
      end
    end
  end, 1200)
  vim.cmd("startinsert")
end

-- Envía texto al agy. Reusa el buffer del plugin; si no existe lo abre
-- con require("antigravity").toggle() y reintenta tras el arranque.
local function agy_send_text(text)
  if agy_send(text) then
    return
  end
  local ok, ag = pcall(require, "antigravity")
  if ok and ag.toggle then
    ag.toggle()
    vim.defer_fn(function()
      if not agy_send(text) then
        agy_fallback_open(text)
      end
    end, 500)
  else
    agy_fallback_open(text)
  end
end

-- ── Envía un comando slash (ej. /resume) al agy ──────────────
local function agy_command(command)
  agy_send_text(command .. "\n")
end

-- ── Limpiar prompt + interrumpir generación ─────────────────
--   NOTA: en agy Ctrl+C CIERRA el TUI (tecla de salida, Bubble Tea).
--   Enviar texto con \n teniendo el prompt NO vacío puede concatenarse
--   (p. ej. '@ruta:1-17/exit' → cierre/panic). La forma robusta de
--   "limpiar": Enter (\r) acepta/descarta el draft en curso y luego
--   ESC (\027) interrumpe la generación sin cerrar el TUI.
local function agy_flush_interrupt()
  local bufs = vim.api.nvim_list_bufs()
  for i = 1, #bufs do
    local buf = bufs[i]
    if vim.bo[buf].buftype == "terminal" then
      local chan = vim.bo[buf].channel
      if chan and chan > 0 and vim.api.nvim_buf_get_name(buf):match("agy") then
        vim.api.nvim_chan_send(chan, "\r\027")
        return
      end
    end
  end
end

-- ── Referencia opencode-style @ruta:start-end (líneas exactas) ──
-- Devuelve "@<ruta absoluta>:<start>-<end>" si el buffer tiene nombre;
-- sin rango si start es nil. nil si el buffer es sin nombre.
local function file_ref(start_line, end_line)
  local path = vim.fn.expand("%:p")
  if path == "" then
    return nil
  end
  if start_line then
    return "@" .. path .. ":" .. start_line .. "-" .. end_line
  end
  return "@" .. path
end

-- ── Envía SOLO la referencia del buffer ACTUAL (sin contenido) ──
--   agy lee el archivo por sí mismo con @ruta:1-N → rápido.
local function send_buffer_to_agy()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local ref = file_ref(1, #lines)
  if ref then
    agy_send_text(ref .. "\n")
  end
end

-- ── Envía las referencias de TODOS los buffers con nombre ──
--   (estilo opencode @buffers). Solo refs @ruta:1-N, sin contenido.
local function send_all_buffers_to_agy()
  local refs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
      local path = vim.api.nvim_buf_get_name(buf)
      if path ~= "" and not path:match("^term://") then
        local count = vim.api.nvim_buf_line_count(buf)
        table.insert(refs, "@" .. path .. ":1-" .. count)
      end
    end
  end
  if #refs > 0 then
    agy_send_text(table.concat(refs, "\n") .. "\n")
  end
end

-- ── Acción: abre agy con el prompt + SOLO la referencia @ruta:start-end ──
local function open_gemini(prompt, start_line, end_line)
  local full = prompt
  local ref = start_line and file_ref(start_line, end_line) or nil
  if ref then
    full = full .. "\n" .. ref
  end
  agy_send_text(full .. "\n")
end

-- ── Menú de prompts (revisar/explicar/debuggear/refactorizar/...) ──
local function show_gemini_menu(start_line, end_line)
  local options = {
    "󰃕  󰨞 Revisar código",
    "󰃕  󰨞 Explicar código",
    "󰃕  󰨞 Debuggear error",
    "󰃕  󰨞 Refactorizar",
    "󰃕  󰨞 Optimizar",
    "󰃕  󰨞 Personalizado [Abrir agy]",
  }

  vim.ui.select(options, {
    prompt = " 󰨞 ~ Selecciona acción:",
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
          open_gemini(input, start_line, end_line)
        end
      end)
    else
      open_gemini(prompts[idx], start_line, end_line)
    end
  end)
end

-- ── Acción por prefijo (menú o comando slash directo) ────────
-- <leader>ag  → menú (mismo que antes de gemini).
-- <leader>agt → toggle del plugin (require antigravity).
-- <leader>agX → envía el slash command correspondiente.
keymap.set("n", "<leader>agP", function()
  show_gemini_menu()
end, { desc = "󰨞 Agy: menú de prompts" })

keymap.set("v", "<leader>ag", function()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  show_gemini_menu(start_line, end_line)
end, { desc = "󰨞 Agy: enviar selección a menú (solo @ruta:start-end)" })

keymap.set("n", "<leader>agt", function()
  local ok, ag = pcall(require, "antigravity")
  if ok and ag.toggle then
    ag.toggle()
  else
    agy_fallback_open("\n")
  end
end, { desc = "󰨞 Agy: toggle" })

keymap.set("n", "<leader>agr", function()
  agy_command("/resume")
end, { desc = "󰨞 Agy: /resume (switch)" })

keymap.set("n", "<leader>agp", function()
  agy_command("/plan")
end, { desc = "󰨞 Agy: /plan" })

keymap.set("n", "<leader>agg", function()
  agy_command("/goal")
end, { desc = "󰨞 Agy: /goal" })

keymap.set("n", "<leader>age", function()
  agy_command("/grill-me")
end, { desc = "󰨞 Agy: /grill-me" })

keymap.set("n", "<leader>agn", function()
  agy_command("/clear")
end, { desc = "󰨞 Agy: /clear (new)" })

keymap.set("n", "<leader>agf", function()
  agy_command("/fork")
end, { desc = "󰨞 Agy: /fork (branch)" })

keymap.set("n", "<leader>agm", function()
  agy_command("/model")
end, { desc = "󰨞 Agy: /model" })

keymap.set("n", "<leader>agx", function()
  agy_command("/exit")
end, { desc = "󰨞 Agy: /exit (quit)" })

keymap.set(
  "n",
  "<leader>agI",
  agy_flush_interrupt,
  { desc = "󰨞 Agy: limpiar prompt + interrumpir (Enter+ESC, no cierra)" }
)

keymap.set("n", "<leader>agd", function()
  agy_command("/diff")
end, { desc = "󰨞 Agy: /diff" })

keymap.set("n", "<leader>agc", function()
  agy_command("/context")
end, { desc = "󰨞 Agy: /context" })

keymap.set("n", "<leader>agb", function()
  send_buffer_to_agy()
end, { desc = "󰨞 Agy: enviar buffer actual (solo @ruta:1-N)" })

keymap.set("n", "<leader>agB", function()
  send_all_buffers_to_agy()
end, { desc = "󰨞 Agy: enviar TODOS los buffers (refs @ruta:1-N)" })

keymap.set("n", "<leader>agv", function()
  agy_command("/btw")
end, { desc = "󰨞 Agy: /btw" })

keymap.set("n", "<leader>ags", function()
  agy_command("/skills")
end, { desc = "󰨞 Agy: /skills" })

keymap.set("n", "<leader>ago", function()
  agy_command("/open")
end, { desc = "󰨞 Agy: /open" })

keymap.set("n", "<leader>agR", function()
  agy_command("/rename")
end, { desc = "󰨞 Agy: /rename" })

keymap.set("n", "<leader>agC", function()
  agy_command("/changelog")
end, { desc = "󰨞 Agy: /changelog" })

-- ── Plugin de chat gemini (si está instalado) ~[REQUIERE API] ──
local has_gemini, gemini_chat = pcall(require, "gemini.chat")
if has_gemini then
  keymap.set("n", "<leader>gg", function()
    gemini_chat.prompt_current()
  end, { desc = "󰊭 Gemini: prompt en buffer actual" })

  keymap.set("v", "<leader>g", function()
    gemini_chat.prompt_selected()
  end, { desc = "󰊭 Gemini: prompt con texto seleccionado" })

  keymap.set("n", "<leader>gl", function()
    gemini_chat.prompt_line()
  end, { desc = "󰊭 Gemini: prompt con línea actual" })
end
