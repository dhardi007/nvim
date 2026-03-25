-- 💸💳💰REQUIERE API. USA:claude auth o Logeate con Claude-code: /login auth
-- PARA QUE FUNCIONE DEBES DE ELIMINAR CMP.lua
local function send_to_claude(text)
  local bufnr = require("claudecode").get_active_bufnr and require("claudecode").get_active_bufnr()
  if not bufnr then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].buftype == "terminal" then
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match("claude") then
          bufnr = buf
          break
        end
      end
    end
  end
  if bufnr then
    local chan = vim.bo[bufnr].channel
    if chan and chan > 0 then
      vim.api.nvim_chan_send(chan, text .. "\n")
      local winid = vim.fn.bufwinid(bufnr)
      if winid ~= -1 then
        vim.api.nvim_set_current_win(winid)
        vim.cmd("startinsert")
      end
    end
  end
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal = {
      split_side = "left",
      split_width_percentage = 0.30,
      provider = "snacks",
    },
  },
  keys = {
    { "<leader>a", nil, desc = " AI / IA Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = " Toggle / Alternar Claude" },
    -- { "<leader>aF", "<cmd>ClaudeCodeFocus<cr>", desc = " Focus / Enfocar Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = " Resume / Reanudar Claude History" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = " Continue / Continuar Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = " Select model / Seleccionar modelo" },
    { "<leader>av", "<cmd>ClaudeCodeAdd %<cr>", desc = " Add buffer / Agregar buffer actual" }, -- antes con ab
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = " Send / Enviar a Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = " Add file / Agregar archivo",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = " Accept / Aceptar cambios" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = " Deny / Rechazar cambios" },
    -- Slash commands automáticos al terminal de Claude
    {
      "<leader>aW",
      function()
        send_to_claude("/rewind")
      end,
      desc = " /rewind - Deshacer último mensaje",
    },
    {
      "<leader>aN",
      function()
        send_to_claude("/rename ")
      end,
      desc = " /rename - Renombrar conversación",
    },
    {
      "<leader>af",
      function()
        send_to_claude("/fork")
      end,
      desc = " /fork - Clonar / Bifurcar conversación",
    },
  },
}
