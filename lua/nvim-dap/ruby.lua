-- Ruby: rdbg (ruby/debug) — adapter oficial de Ruby con soporte DAP.
-- Requiere: :MasonInstall rdbg
-- Forma de lanzar: rdbg --open --command --port <puerto> -- script.rb

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/rdbg"
  if vim.fn.filereadable(bin) == 0 then
    -- Avisa solo si el filetype del buffer actual ES este lenguaje; sin este
    -- gate, setup() notificaría ERROR en CADA arranque aunque estés en otro
    -- lenguaje (espam de "missing tool" en el mensaje de nvim).
    if vim.bo.filetype:match("ruby") then
      vim.notify(
        "rdbg no encontrado. Corre :MasonInstall rdbg",
        vim.log.levels.ERROR,
        { title = "nvim-dap: Ruby" }
      )
    end
    return
  end

  -- rdbg escucha en ${port}; nvim-dap crea el puerto y lo inyecta.
  dap.adapters.rdbg = {
    type = "server",
    port = "${port}",
    executable = {
      command = bin,
      args = { "--open", "--command", "--port", "${port}" },
    },
  }

  dap.configurations.ruby = {
    {
      type = "rdbg",
      request = "launch",
      name = "Launch file",
      -- `script` es lo que rdbg ejecuta tras abrir el puerto.
      script = function()
        return vim.fn.expand("%:p")
      end,
      cwd = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
      end,
      stopOnEntry = true,
    },
    {
      type = "rdbg",
      request = "launch",
      name = "Launch file (bundle exec)",
      script = function()
        return vim.fn.expand("%:p")
      end,
      cwd = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
      end,
      bundleExec = true,
      stopOnEntry = true,
    },
  }
end

return M