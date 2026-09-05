-- Haskell: haskell-debug-adapter (Haskell DAP server).
-- Requiere: :MasonInstall haskell-debug-adapter
-- Nota: debuggear aplicaciones Haskell robustas suele requerir un
-- proyecto cabal/stack; la config usa the `program` (binario) del
-- buffer actual si fue compilado, o pide el .exe si no.

local M = {}

M.setup = function(dap)
  local bin = vim.fn.stdpath("data") .. "/mason/bin/haskell-debug-adapter"
  if vim.fn.filereadable(bin) == 0 then
    if vim.bo.filetype:match("haskell") then
      vim.notify(
        "haskell-debug-adapter no encontrado. Corre :MasonInstall haskell-debug-adapter",
        vim.log.levels.ERROR,
        { title = "nvim-dap: Haskell" }
      )
    end
    return
  end

  dap.adapters.haskell = {
    type = "executable",
    command = bin,
  }

  local function find_executable()
    local file = vim.fn.expand("%:p")
    local dir = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
    local candidates = {
      dir .. "/.stack-work/dist/**/*",
      dir .. "/dist-newstyle/build/**/*",
    }
    for _, pattern in ipairs(candidates) do
      local matches = vim.fn.glob(pattern, 0, 1)
      if type(matches) == "table" and #matches > 0 then
        -- Toma el binario mas reciente (orden de glob suele ser el sufijo)
        return matches[#matches]
      end
    end
    return vim.fn.input("Path to binary: ", dir .. "/", "file")
  end

  dap.configurations.haskell = {
    {
      type = "haskell",
      request = "launch",
      name = "Launch executable",
      program = find_executable,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
end

return M