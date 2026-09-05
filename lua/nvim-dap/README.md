# nvim-dap/extras — DAPs adicionales separados por lenguaje

Módulos de configuración de **nvim-dap** para lenguajes que **no están entre los
principales** (JS/TS, C/C++/Rust, Go, C#, Java, PHP, Python), los cuales viven
en `lua/plugins/nvim-dap.lua` y quedaron intactos.

> **Motivación / créditos:** la lista de lenguajes se basa en los **83 tracks
> oficiales de [Exercism](https://exercism.org/tracks)**. Exercism es libre de
> usar como referencia de cobertura; los adaptadores, configs y el template
> `codelldb` de este directorio son implementación propia sobre las tools que
> provee **Mason** (`mason.nvim`).

El agregador `extras.lua` es llamado desde el `config` de `nvim-dap.lua`:

```lua
local ok_extras, err_extras = pcall(require, "nvim-dap.extras")
if not ok_extras then
  vim.notify("nvim-dap/extras no cargó: " .. tostring(err_extras), vim.log.levels.ERROR, { title = "nvim-dap: extras" })
else
  ok_extras.setup(dap)
end
```

Cada modulo expone `setup(dap)`. Un fallo en un lenguaje NO rompe el resto
(pcall individual). Cada modulo verifica que el binario de Mason exista en
`stdpath("data")/mason/bin/<tool>` y notifica si falta.

## Lenguajes CON adapter DAP en Mason

| Módulo       | Adapter Mason                    | Binario                  | Requiere install          |
| ------------ | -------------------------------- | ------------------------ | ------------------------- |
| `bash.lua`   | bash-debug-adapter               | bash-debug-adapter       | `:MasonInstall bash-debug-adapter` |
| `dart.lua`   | dart-debug-adapter               | dart-debug-adapter       | `:MasonInstall dart-debug-adapter` |
| `kotlin.lua` | kotlin-debug-adapter             | kotlin-debug-adapter     | `:MasonInstall kotlin-debug-adapter` |
| `lua.lua`    | local-lua-debugger-vscode        | local-lua-debugger       | `:MasonInstall local-lua-debugger-vscode` |
| `perl.lua`   | perl-debug-adapter               | perl-debug-adapter       | `:MasonInstall perl-debug-adapter` |

### Adapters que se COMPILAN desde fuente (requieren toolchain de sistema)

No están en `ensure_installed` de Mason (si lo estuvieran, reintentarían y
fallarían en cada arranque). La config del módulo ya avisa si el binario falta.
Para usarlos: instalar la toolchain con Nix y luego `:MasonInstall <pkg>`.

| Módulo      | Adapter Mason         | Binario            | Toolchain Nix necesaria (ej. `nix shell`) |
| ----------- | --------------------- | ------------------ | ----------------------------------------- |
| `erlang.lua`| erlang-debugger       | erlang-debugger    | `nixpkgs#rebar3`                          |
| `haskell.lua`| haskell-debug-adapter| haskell-debug-adapter | `nixpkgs#cabal-install`                |
| `ocaml.lua` | ocamlearlybird        | ocamlearlybird     | `nixpkgs#opam`                            |
| `ruby.lua`  | rdbg                  | rdbg               | `nixpkgs#ruby`                            |

## Lenguajes SIN adapter DAP en Mason (nativos, via codelldb)

| Módulo       | Filetype   | Compilación de ejemplo              |
| ------------ | ---------- | ----------------------------------- |
| `cobol.lua`  | cobol      | `cobc -g -o main main.cob`          |
| `native.lua` | zig        | `zig build-exe main.zig -g`         |
| `native.lua` | nim        | `nim c -g -o main main.nim`         |
| `native.lua` | odin       | `odin build main.odin -debug`       |
| `native.lua` | d          | `ldc2 -g main.d -of main`           |
| `native.lua` | fortran    | `gfortran -g -o main main.f90`      |
| `native.lua` | v          | `v -g main.v`                       |
| `native.lua` | crystal    | `crystal build -o main --debug`     |
| `native.lua` | swift      | `swiftc -g -o main main.swift`      |
| `native.lua` | pascal     | `fpc -g -o main main.pas`           |

**Regla:** compilar SIEMPRE con `-g` (DWARF) y ejecutar con `codelldb` (ya
instalado en Mason). Busca el binario en el directorio del archivo por nombre
(candidatos + nombre sin extensión).

## Lenguajes de Exercism SIN tile en nvim-dap

Los siguientes tracks de Exercism NO tienen adapter DAP en Mason ni un
workflow realista de debug desde nvim (interpretados, o sin adapter):

`8th, ABAP, ARM64 Assembly, Arturo, AWK, Ballerina, Batch Script, Cairo,
CFML, Clojure, CoffeeScript, Common Lisp, Crystal(via native), Delphi Pascal,
Elm, Emacs Lisp, Euphoria, F#, Factor, Futhark, Gleam, Groovy, Idris, jq,
Julia, Lean, Lisp Flavoured Erlang, MIPS Assembly, MoonScript, Objective-C,
Pharo, PowerShell, Prolog, PureScript, Pyret, R, Racket, Raku, ReasonML, Red,
Roc, R, Scheme, SQLite, Standard ML, Tcl, Uiua, Unison, Vim script, Visual
Basic, WebAssembly, Wren, x86-64 Assembly, YAMLScript`

## Verificación

```sh
cd nvim/.config/nvim
for f in lua/nvim-dap/*.lua; do
  timeout 30 nvim --headless -u NONE -c "luafile $f" -c "q" && echo "OK $f"
done
```