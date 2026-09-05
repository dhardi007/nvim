-- OCaml: ocamlearlybird (OCaml DAP over ocamldebug).
-- Requiere: :MasonInstall ocamlearlybird
-- El binario compilado (con -g) se lanza con el adapter; ocamlearlybird
-- hace de puente a ocamldebug.

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/ocamlearlybird"
  if vim.fn.filereadable(bin) == 0 then
    if vim.bo.filetype:match("ocaml") then
      vim.notify(
        "ocamlearlybird no encontrado. Corre :MasonInstall ocamlearlybird",
        vim.log.levels.ERROR,
        { title = "nvim-dap: OCaml" }
      )
    end
    return
  end

  dap.adapters.ocaml = {
    type = "executable",
    command = bin,
    args = { "--syslog", "-", "--ocamlearlybird" },
  }

  dap.configurations.ocaml = {
    {
      type = "ocaml",
      request = "launch",
      name = "Launch file",
      program = function()
        return vim.fn.input("Binary path: ", vim.fn.getcwd() .. "/main", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = true,
    },
  }
end

return M