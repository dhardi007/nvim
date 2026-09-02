local opt = vim.opt

-- JAVA_HOME: jdtls (LSP/DAP de Java) necesita un JAVA_HOME bien formado para
-- resolver el ejecutable de Java. En NixOS el JDK vive en /nix/store/.../lib/
-- openjdk (layout no estándar) y JAVA_HOME suele estar vacío, lo que tira
-- "Could not resolve java executable: Index 1 out of bounds for length 1".
-- Se resuelve el home a partir de `java` (dir que contiene bin/java).
if vim.env.JAVA_HOME == nil or vim.env.JAVA_HOME == "" then
  local java_bin = vim.fn.exepath("java")
  if java_bin ~= "" then
    local resolved = vim.fn.resolve(java_bin)
    local home = vim.fn.fnamemodify(vim.fn.fnamemodify(resolved, ":h"), ":h")
    if vim.fn.isdirectory(home .. "/bin") == 1 then
      vim.env.JAVA_HOME = home
    end
  end
end

-- set termguicolors
opt.termguicolors = true

-- relative numbers
opt.relativenumber = true
opt.nu = true

-- search
opt.hlsearch = true -- highlight all matches on previous search pattern
opt.ignorecase = true -- ignore case in search patterns
opt.smartcase = true

-- tabs & identation
opt.smartindent = true -- make indenting smarter again
opt.autoindent = true
opt.cindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- clipboard
opt.clipboard:append("unnamedplus")

-- line wrapping
opt.wrap = true

-- backspace
opt.backspace = "indent,eol,start"

-- split windows
opt.splitright = true
opt.splitbelow = true

-- keywords
opt.iskeyword:append("-")

-- persist undo history
opt.undofile = true

-- ;; Modificado por diego ;;
--
-- Define un directorio para guardar los archivos de historial
-- Esto evita que se creen archivos .un~ en cada proyecto
-- local undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
-- opt.undodir = undodir
--
-- -- Crear el directorio si no existe
-- if vim.fn.isdirectory(undodir) == 0 then
--   vim.fn.mkdir(undodir, "p")
-- end

-- FIN ;; Modificado por diego ;;

-- Dont make backups
opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.signcolumn = "yes"
opt.conceallevel = 2
-- Permite cambiar de buffer sin guardar (oculta en lugar de cerrar)
vim.opt.hidden = true
vim.opt.timeoutlen = 300 -- Default es 1000ms, reduce a 300ms
