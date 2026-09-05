-- COBOL: NO tiene DAP adapter en Mason (cobol_ls es solo LSP).
-- La config es un "bridge" honesto: GnuCOBOL compila a binario nativo,
-- que codelldb (ya instalado y configurado en nvim-dap.lua) puede
-- debugear. Requiere compilar primero: cobc -g -o main main.cob

local M = {}

M.setup = function(dap)
  dap.configurations.cobol = {
    {
      type = "codelldb",
      request = "launch",
      name = "Launch compiled COBOL",
      -- Busca el binario compilado por GnuCOBOL en el dir del archivo.
      program = function()
        local file = vim.fn.expand("%:p")
        local dir = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
        local candidates = { dir .. "/main", dir .. "/out/" .. dir:match("([^/]+)$"), dir .. "/" .. vim.fn.fnamemodify(file, ":t:r") }
        for _, path in ipairs(candidates) do
          if vim.fn.filereadable(path) == 1 and vim.fn.isdirectory(path) == 0 then
            return path
          end
        end
        return dir .. "/main"
      end,
      cwd = "${workspaceFolder}",
      stopAtEntry = false,
    },
  }

  -- Hint unificado: el keymap global <leader>dx/F8 en nvim-dap.lua llama a
  -- este get_hint() (via get_build_hint). No se redefine <leader>dx aqui.
  M.get_hint = function(filetype)
    if filetype ~= vim.bo.filetype and filetype ~= "cobol" then
      return nil
    end
    local src = vim.fn.fnamemodify(vim.fn.expand("%:t"), ":t")
    local name = vim.fn.fnamemodify(src, ":t:r")
    if name == "" then
      name = "main"
    end
    return {
      "cobc -g -o " .. name .. " " .. src,
      "COBOL no trae adapter DAP en Mason; codelldb debugea el binario compilado con GnuCOBOL.",
    }
  end
end

return M