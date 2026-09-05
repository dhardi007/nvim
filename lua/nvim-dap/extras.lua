-- Extras DAP: lenguajes adicionales con soporte en Mason.
-- Cada lenguaje vive en su propio modulo: lua/nvim-dap/<lenguaje>.lua
-- y expone `setup(dap)`. Quien los carga es nvim-dap.lua (config del
-- plugin) llamando require("nvim-dap.extras").setup(dap).
--
-- Los lenguajes "principales" (JS/TS, C/C++/Rust, Go, C#, Java, PHP,
-- Python) siguen configurados directamente en lua/plugins/nvim-dap.lua.

local languages = {
  "bash",
  "cobol",
  "dart",
  "erlang",
  "haskell",
  "kotlin",
  "lua",
  "native", -- Zig, Nim, Odin, D, Fortran, V, Crystal, Swift, Pascal (via codelldb)
  "ocaml",
  "perl",
  "ruby",
}

local M = {}

-- Registra adapters + configs de todos los lenguajes extras.
-- Fallo en un modulo NO rompe el resto (pcall individual).
M.setup = function(dap)
  for _, lang in ipairs(languages) do
    local ok, mod = pcall(require, "nvim-dap." .. lang)
    if ok and type(mod) == "table" and type(mod.setup) == "function" then
      local ok_setup, err = pcall(mod.setup, dap)
      if not ok_setup then
        vim.notify(
          "nvim-dap/" .. lang .. " falló: " .. tostring(err),
          vim.log.levels.ERROR,
          { title = "nvim-dap: extras" }
        )
      end
    else
      vim.notify(
        "nvim-dap/" .. lang .. " no existe o no expone setup()",
        vim.log.levels.WARN,
        { title = "nvim-dap: extras" }
      )
    end
  end
end

return M