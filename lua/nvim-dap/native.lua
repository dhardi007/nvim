-- Lenguajes nativos compilados (sin DAP adapter propio en Mason).
-- Se debugean con codelldb (ya instalado) sobre el binario compilado
-- con símbolos DWARF. Requisito: compilar antes con -g (ver `hint`).
--
-- Todos exponen `dap.configurations.<filetype>` y reusan el adapter
-- codelldb definido en nvim-dap.lua.

local M = {}

-- filetype → { name, hint (comando de compilación), binaries (candidatos) }
local native_langs = {
  zig = {
    name = "Zig",
    hint = "zig build-exe main.zig -g && ./main",
    binaries = { "main", "zig-out/bin/main" },
  },
  nim = {
    name = "Nim",
    hint = "nim c -g -o:main main.nim && ./main",
    binaries = { "main", "main_debug" },
  },
  odin = {
    name = "Odin",
    hint = "odin build main.odin -debug -out:main && ./main",
    binaries = { "main", "main_debug" },
  },
  d = {
    name = "D",
    hint = "ldc2 -g main.d -of main && ./main",
    binaries = { "main", "app" },
  },
  fortran = {
    name = "Fortran",
    hint = "gfortran -g -o main main.f90 && ./main",
    binaries = { "main", "a.out" },
  },
  v = {
    name = "V",
    hint = "v -g main.v && ./main",
    binaries = { "main", "main_debug" },
  },
  crystal = {
    name = "Crystal",
    hint = "crystal build -o main --debug main.cr && ./main",
    binaries = { "main", "main_debug" },
  },
  swift = {
    name = "Swift",
    hint = "swiftc -g -o main main.swift && ./main",
    binaries = { "main", "handler" },
  },
  pascal = {
    name = "Free Pascal",
    hint = "fpc -g -o main main.pas && ./main",
    binaries = { "main", "a.out" },
  },
}

local function find_binary(dir, fname, candidates)
  for _, name in ipairs(candidates) do
    local path = dir .. "/" .. name
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  -- fallback al nombre del archivo sin extensión
  local stem = vim.fn.fnamemodify(fname, ":t:r")
  local path = dir .. "/" .. stem
  if vim.fn.filereadable(path) == 1 then
    return path
  end
  return dir .. "/main"
end

M.get_hint = function(filetype)
  local lang = native_langs[filetype]
  if lang then
    return lang.hint
  end
  return nil
end

M.setup = function(dap)
  for filetype, lang in pairs(native_langs) do
    dap.configurations[filetype] = {
      {
        type = "codelldb",
        request = "launch",
        name = "Launch " .. lang.name .. " (compilado)",
        program = function()
          local file = vim.fn.expand("%:p")
          local dir = vim.fn.fnamemodify(file, ":h")
          return find_binary(dir, file, lang.binaries)
        end,
        cwd = function()
          return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
        end,
        args = {},
        stopOnEntry = false,
      },
    }
  end
end

return M