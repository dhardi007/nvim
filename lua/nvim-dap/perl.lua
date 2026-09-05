-- Perl: perl-debug-adapter.
-- Requiere: :MasonInstall perl-debug-adapter
-- Soporta archivos .pl/.pm. Requiere Perl con el módulo Devel::StackTrace
-- disponible (viene por defecto con perl).

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/perl-debug-adapter"
  if vim.fn.filereadable(bin) == 0 then
    vim.notify(
      "perl-debug-adapter no encontrado. Corre :MasonInstall perl-debug-adapter",
      vim.log.levels.ERROR,
      { title = "nvim-dap: Perl" }
    )
    return
  end

  dap.adapters.perl = {
    type = "executable",
    command = bin,
    args = { "--type=perl" },
  }

  dap.configurations.perl = {
    {
      type = "perl",
      request = "launch",
      name = "Launch file",
      program = function()
        return vim.fn.expand("%:p")
      end,
      cwd = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
      end,
      stopOnEntry = true,
    },
  }
end

return M