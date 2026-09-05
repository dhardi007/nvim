-- Erlang: erlang-debugger (vsErlang / Erlang DAP server).
-- Requiere: :MasonInstall erlang-debugger
-- Adjunta a un nodo de Erlang condebugger; el programa debe correr con
-- `erl -syntax_tools auto_import` y el debugger activo (ej. correr desde
-- el shell con `erl` y cargar el módulo compilado con +debug_info).

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/erlang-debugger"
  if vim.fn.filereadable(bin) == 0 then
    if vim.bo.filetype:match("erlang") then
      vim.notify(
        "erlang-debugger no encontrado. Corre :MasonInstall erlang-debugger",
        vim.log.levels.ERROR,
        { title = "nvim-dap: Erlang" }
      )
    end
    return
  end

  dap.adapters.erlang = {
    type = "executable",
    command = bin,
  }

  dap.configurations.erlang = {
    {
      type = "erlang",
      request = "launch",
      name = "Attach to node",
      cwd = "${workspaceFolder}",
      nodeName = function()
        return vim.fn.input("Node name (ej. node@127.0.0.1): ", "node@127.0.0.1")
      end,
      cookie = function()
        return vim.fn.input("Cookie: ")
      end,
      debugServer = "127.0.0.1",
      debugServerPort = 9000,
    },
  }
end

return M