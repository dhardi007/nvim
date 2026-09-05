-- Lua: local-lua-debugger-vscode (LLDB-Mirror / local Lua debugger).
-- Requiere: :MasonInstall local-lua-debugger-vscode
-- Soporta Lua 5.x standalone y con luaexecutable propio (compatible
-- con la config Lua del propio nvim).

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/local-lua-debugger"
  if vim.fn.filereadable(bin) == 0 then
    if vim.bo.filetype:match("lua") then
      vim.notify(
        "local-lua-debugger no encontrado. Corre :MasonInstall local-lua-debugger-vscode",
        vim.log.levels.ERROR,
        { title = "nvim-dap: Lua" }
      )
    end
    return
  end

  dap.adapters["local-lua-debugger"] = {
    type = "executable",
    command = bin,
  }

  local function find_lua()
    local path = vim.fn.exepath("lua")
    if path ~= "" then
      return path
    end
    return "/usr/bin/lua"
  end

  dap.configurations.lua = {
    {
      type = "local-lua-debugger",
      request = "launch",
      name = "Launch file",
      program = function()
        return vim.fn.expand("%:p")
      end,
      cwd = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
      end,
      args = {},
      luaExecutable = find_lua,
      luaVersion = "Lua 5.4", -- verificar con lua -v
      console = "integratedTerminal",
      stopOnEntry = true,
    },
  }
end

return M