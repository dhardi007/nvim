-- Dart: dart-debug-adapter (soporta .dart standalone y Flutter).
-- Requiere: :MasonInstall dart-debug-adapter

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter"
  if vim.fn.filereadable(bin) == 0 then
    vim.notify(
      "dart-debug-adapter no encontrado. Corre :MasonInstall dart-debug-adapter",
      vim.log.levels.ERROR,
      { title = "nvim-dap: Dart" }
    )
    return
  end

  dap.adapters.dart = {
    type = "executable",
    command = bin,
  }

  dap.configurations.dart = {
    {
      type = "dart",
      request = "launch",
      name = "Launch file",
      program = function()
        return vim.fn.expand("%:p")
      end,
      cwd = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
      end,
      console = "integratedTerminal",
      stopOnEntry = true,
    },
  }
end

return M