-- Kotlin: kotlin-debug-adapter (Kotlin Language Server DAP).
-- Requiere: :MasonInstall kotlin-debug-adapter
-- Nota: lanza la JVM con `-agentlib:jdwp`; conviene build/classes ya
-- compilado. El adapter espera el codigo fuente en `sourcePaths`.

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/kotlin-debug-adapter"
  if vim.fn.filereadable(bin) == 0 then
    vim.notify(
      "kotlin-debug-adapter no encontrado. Corre :MasonInstall kotlin-debug-adapter",
      vim.log.levels.ERROR,
      { title = "nvim-dap: Kotlin" }
    )
    return
  end

  dap.adapters.kotlin = {
    type = "executable",
    command = bin,
  }

  dap.configurations.kotlin = {
    {
      type = "kotlin",
      request = "launch",
      name = "Launch file (kt standalone)",
      program = function()
        return vim.fn.expand("%:p")
      end,
      cwd = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
      end,
      sourcePaths = { vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h") },
      mainClass = function()
        -- Define la clase main del archivo abierto (ej. MainKt)
        local fname = vim.fn.fnamemodify(vim.fn.expand("%:t"), ":r")
        return fname .. "Kt"
      end,
      classPaths = { "${workspaceFolder}/build/classes/kotlin/main" },
      console = "integratedTerminal",
      stopOnEntry = true,
    },
  }
end

return M