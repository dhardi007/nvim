-- 🦈 <-- TRUCAZO DE OIL: --> ✨
-- Asi como existe :10 [line preview] tambien lo dispone OIL con:
-- {Navegar en directorio = -} + Ctrl + Q [puedes ver los archivos sin abrirlos]
-- 🦈 <-- TRUCAZO DE OIL. --> ✨

-- PARA Configurar IAS, revisa:
-- config/lazy.lua
-- plugins/disabled
-- OBVIAMENTE REVISA LOS KEYMAPS: config/keymaps.lua
--

-- KEYMAPS DE CHAT por IA FUNCIONAN AL SELECCIONAR TEXTO [v]

-- =============================
-- CONFIG BASICA [+GUIA ATAJOS]
-- =============================

## --💫 PARA OBTENER INFORMACION DE UN BUFFER Y SUS MAPEOS: UTILIZA:[2 puntos] :lua print(vim.inspect(vim.api.nvim_buf_get_keymap(0, "i")))

-- 🗣️ ATAJOS DE IA y OIL/snack_picker_list tree EXPLORER QUE DEBES SABER:
-- 🐐 1- ATAJO IMPORTANTE: - {minus -} [oil ~ requiere oil]-
-- te lleva al directorio en el que te encuentras [GOZZZZ]
-- 🐐 1.5 - ATAJO IMPORTANTE: Space E [mayus] \ o usa: Space + Shift + E [Abre oil flotante] ) \ AL SELECCIONAR TEXTO [v]-
-- 🐐 2- ATAJO IMPORTANTE: Space+e [minus] [snack ~ requiere: fd fd-find]
-- 🐐 3- ATAJO IMPORTANTE: Space+N [notifaciones - como :mes pero mejor para depurar codigo!! ]
-- 🐐 4- ATAJO IMPORTANTE: Space+M ejecutar el markdown render ej Space + M+R
-- 🐐 5- accept Copilot/Tabnine etc = "<Tab>", -- acepta sugerencia
-- dismisss Copilot/Tabnine = "<C-c> o con ESC", -- cancela sugerencia
-- 🐐 6- abrir menu IA panel {claude api} = Space + A -- tambien puedesc crear un new file
-- keymap = {
-- accept = "<C-Tab>", -- acepta sugerencia
-- next = "<C-]>",
-- prev = "<C-[>",
-- dismiss = "<C-",

-- 🗣️ ATAJOS OIL tree EXLORER:
-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
-- keymaps =
-- {
-- ["g?"] = "actions.show*help",
-- ["<CR>"] = "actions.select",
-- ["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
-- ["<C-v>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
-- ESTE NO LO RECOMIENDO, lo quite. -- ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open in new tab" },
-- ["<C-p>"] = "actions.preview",
-- ["<C-c>"] = "actions.close",
-- ["<C-r>"] = "actions.refresh",
-- ["-"] = "actions.parent",
-- ["*"] = "actions.open_cwd",
-- ["`"] = "actions.cd",
-- ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
-- ["gs"] = "actions.change_sort",
-- ["gx"] = "actions.open_external",
-- ["g."] = "actions.toggle_hidden",
-- ["g\\"] = "actions.toggle_trash",
-- -- Quick quit
-- ["q"] = "actions.close",
-- },
-- similar al EXPLORER snack_picker_list

-- # MUCHOS DE ESTOS COMANDOS EQUIVALEN A:
-- [ + b > cambiar pestaña prev {osea tabear}
-- ] + b > cambiar pestaña next {osea tabear}
-- space + b + b = la unica forma de ctrl tab
--

-- |
-- ╰─❯ CTrl + [] > cabra a buffer prev!!
-- [lomejor] Ctrl + ] > cambiar a buffer sigueinte [ctrl tab!! en buffer]

-- # y otros que NO MODIFIQUE COMO:
-- Ctrl + V > Grabar Tecla - Util para averiguar la tecla [Record key] {Similar a cat -v}
-- Ctrl + Shif + C > Copiar en Modo Insercion
-- Ctrl + Shif + V > Pegar en Modo Insercion
-- ╰❯ [Ctrl + W > Guia de Window]
-- ╰─❯ {recomiendo}
-- ╰─❯ Ctrl + W + W > cambiar ventana {osea tabear}
-- ╰─❯ Ctrl + W + J > Cambiar ventana {abajo}
-- ╰─❯ Ctrl + W + H > Cambiar ventana {izquierda,
-- ╰─❯ Ctrl + Space [lo mejor] > Cambiar entre TODAS las ventana [shift tab!!! en ventana]
--

-- |
-- ╰─❯ Ctrl + H [lo mejor] > Cambiar entre ventana [ctrl tab!!! en ventana],

-- Ctrl + W + O > cierra tod@s las ventanas divididas/o Explorer
-- Ctrl + W + > S > split dividir {mas lento que space}

-- Cambiar de tema con Telescope colorscheme = Space + C + T # ubicado en: ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/colorscheme.lua
-- Cambiar a Pywal color de fondo = Space + P # ubicado en: ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/pywal-nvim.lua
-- Cambiar a Pywal color de fondo = Space + P+W # ubicado en: ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/pywal-nvim.lua
-- Cambiar a Pywal color de fondo = Soace + C + T escribe Pywal, gruv o el tema que gustes. # ubicado en: ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/colorscheme.lua

-- 🧺   ELIMINE LOS SIGUIENTES plugins (~ [basura]/):⚠
-- Usar minty para generar colorschemes? idk activa Huefy = Space + M + H # ubicado: en ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/minty.luau
-- Usar minty para generar colorschemes? idk activa Shades = Space + M + S # ubicado: en ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/minty.luau
-- Usar minty para generar colorschemes? idk = Space + M + H # ubicado: en ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/minty.luau

-- CAMBIAR color con Teclado = C+P # ubicado en: ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins.lua
-- CAMBIAR color con Mouse + C+V # ubicado en: ~/dotfiles-dizzi/nvim/.config/nvim/lua/plugins/color-picker.lua
-- ABRIR KEYMAPS *otra forma con* = Space + S + K
-- =============================
-- OCULTAR/MOSTRAR BUFFERS
-- =============================

-- =============================
--  VENTANAS TRICKS
-- =============================
--

-- Para dividir la pantalla/buffers:
-- <space>+| > Split horizontal
-- <space>+-- > Split vertical
-- <space>+bh > Revertir DIVISION
-- <space>+wm > Maximizar ventana [FULLSCREEN]
-- Ctrl+<,>,up,down > POSICIONAR VENTANA
-- Ctrl+W > Acceder a modo ventanas
-- Ctrl+h,k,l,j > Navegación entre ventanas
--
