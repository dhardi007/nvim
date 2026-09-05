-- bash/sh: bash-debug-adapter (vscode-bash-debug).
-- Requiere: :MasonInstall bash-debug-adapter

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/bash-debug-adapter"
  if vim.fn.filereadable(bin) == 0 then
    vim.notify(
      "bash-debug-adapter no encontrado. Corre :MasonInstall bash-debug-adapter",
      vim.log.levels.ERROR,
      { title = "nvim-dap: Bash" }
    )
    return
  end

  dap.adapters.bashdb = {
    type = "executable",
    command = bin,
    args = { "bash-debug-adapter" },
  }

  dap.configurations.sh = {
    {
      type = "bashdb",
      request = "launch",
      name = "Launch file",
      program = function()
        return vim.fn.expand("%:p")
      end,
      cwd = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
      end,
      pathBash = vim.fn.exepath("bash"),
      terminalKind = "external",
      console = "integratedTerminal",
    },
  }
  dap.configurations.bash = dap.configurations.sh
  dap.configurations.zsh = dap.configurations.sh
end

return M