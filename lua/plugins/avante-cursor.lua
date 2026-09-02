-- 💸💳💰REQUIERE API. USA : AvanteSwitchProvider ollama | consigue tu key en https://www.avantelabs.ai (MEJOR QUE CURSOR)
--  Puedes hacer el trucazo de usar OLLAMA local cloud con API gratuita.🐐 Talke asi [Lineas: 35]:
return {
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") == 1 and "powershell -ExecutionPolicy Bypass -File Build.ps1" or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = function(_, opts)
      -- Track avante's internal state during resize
      local in_resize = false
      local original_cursor_win = nil
      local avante_filetypes = { "Avante", "AvanteInput", "AvanteAsk", "AvanteSelectedFiles" }

      -- Check if current window is avante
      local function is_in_avante_window()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")

        for _, avante_ft in ipairs(avante_filetypes) do
          if ft == avante_ft then
            return true, win, ft
          end
        end
        return false
      end

      -- feature n1: Auto-switch a Ollama (provider gratuito por defecto)
      -- 🎮 Usa :AvanteSwitchProvider <provider>
      -- Providers: claude, ollama, gemini, deepseek, openrouter, copilot
      -- vim.defer_fn(function()
      --   pcall(vim.cmd, "silent! AvanteSwitchProvider claude")
      -- end, 500)

      -- Temporarily move cursor away from avante during resize
      local function temporarily_leave_avante()
        local is_avante, avante_win, avante_ft = is_in_avante_window()
        if is_avante and not in_resize then
          in_resize = true
          original_cursor_win = avante_win

          -- Find a non-avante window to switch to
          local target_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")

            local is_avante_ft = false
            for _, aft in ipairs(avante_filetypes) do
              if ft == aft then
                is_avante_ft = true
                break
              end
            end

            if not is_avante_ft and vim.api.nvim_win_is_valid(win) then
              target_win = win
              break
            end
          end

          -- Switch to non-avante window if found
          if target_win then
            vim.api.nvim_set_current_win(target_win)
            return true
          end
        end
        return false
      end

      -- Restore cursor to original avante window
      local function restore_cursor_to_avante()
        if in_resize and original_cursor_win and vim.api.nvim_win_is_valid(original_cursor_win) then
          -- Small delay to ensure resize is complete
          vim.defer_fn(function()
            pcall(vim.api.nvim_set_current_win, original_cursor_win)
            in_resize = false
            original_cursor_win = nil
          end, 50)
        end
      end

      -- Prevent duplicate windows cleanup
      local function cleanup_duplicate_avante_windows()
        local seen_filetypes = {}
        local windows_to_close = {}

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_buf_get_option(buf, "filetype")

          -- Special handling for Ask and Select Files panels
          if ft == "AvanteAsk" or ft == "AvanteSelectedFiles" then
            if seen_filetypes[ft] then
              -- Found duplicate, mark for closing
              table.insert(windows_to_close, win)
            else
              seen_filetypes[ft] = win
            end
          end
        end

        -- Close duplicate windows
        for _, win in ipairs(windows_to_close) do
          if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end

      -- 🖥️ Detección de OS simplificada y eficaz
      local is_wsl = vim.fn.has("wsl") == 1
      local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
      local is_linux = vim.fn.has("unix") == 1 and not is_wsl
      local is_termux = vim.fn.isdirectory("/data/data/com.termux") == 1

      -- feature n2: Verificar avante_templates compilados (Makefile los pone en lua/ no build/)
      local lib_ext = is_windows and ".dll" or ".so"
      local templates_lib = vim.fn.stdpath("data") .. "/lazy/avante.nvim/lua/avante_templates" .. lib_ext
      if vim.fn.filereadable(templates_lib) == 0 then
        vim.notify("Avante templates no encontrados. Compilando...", vim.log.levels.WARN)
        vim.defer_fn(function()
          vim.cmd("Lazy build avante.nvim")
        end, 1000)
      end

      -- Create autocmd group for resize fix
      vim.api.nvim_create_augroup("AvanteResizeFix", { clear = true })

      -- Main resize handler for Resize
      vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = "AvanteResizeFix",
        callback = function()
          -- Move cursor away from avante before resize processing
          local moved = temporarily_leave_avante()

          if moved then
            -- Let resize happen, then restore cursor
            vim.defer_fn(function()
              restore_cursor_to_avante()
              -- Force a clean redraw
              vim.cmd("redraw!")
            end, 100)
          end

          -- Cleanup duplicates after resize completes
          vim.defer_fn(cleanup_duplicate_avante_windows, 150)
        end,
      })

      -- Prevent avante from responding to scroll/resize events during resize
      vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized" }, {
        group = "AvanteResizeFix",
        pattern = "*",
        callback = function(args)
          local buf = args.buf
          if buf and vim.api.nvim_buf_is_valid(buf) then
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")

            for _, avante_ft in ipairs(avante_filetypes) do
              if ft == avante_ft then
                -- Prevent event propagation for avante buffers during resize
                if in_resize then
                  return true -- This should stop the event
                end
                break
              end
            end
          end
        end,
      })

      -- Additional cleanup on focus events
      vim.api.nvim_create_autocmd("FocusGained", {
        group = "AvanteResizeFix",
        callback = function()
          -- Reset resize state on focus gain
          in_resize = false
          original_cursor_win = nil
          -- Clean up any duplicate windows
          vim.defer_fn(cleanup_duplicate_avante_windows, 100)
        end,
      })

      return {
        -- 🎯 CONFIGURACIÓN BÁSICA
        --   ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
        ---@type Provider
        provider = "openrouter", -- /o ollama -- Provider por defecto (Claude roto) | Ollma era god hasta que la nacion de Openrouter llego a tumbar su suscripcion. | Openrouter 👑
        ---@alias Mode "agentic" | "legacy"
        ---@type Mode
        mode = "legacy", -- o/ agentic -- 󰄭 GEMINI, Claude, 󰄬 etc SOPORTAN agentic, OLLAMA NO 󰂭 -- The default mode for interaction. "agentic" uses tools to automatically generate code, "legacy" uses the old planning method to generate code.
        -- 🔕 SILENCIAR NOTIFICACIONES, etiquetas XLS?
        hints = {
          enabled = true, -- Desactiva hints que pueden mostrar XML
        },

        -- 📝 Archivo de instrucciones del proyecto
        instructions_file = "avante.md",

        -- 🤖 CONFIGURACIÓN DE PROVIDERS (SIN DEPRECATED WARNINGS)
        providers = {
          --   OLLAMA - Local y gratuito 󰎣
          ollama = {
            priority = 1,
            endpoint = "127.0.0.1:11434", -- Sin /v1
            model = "phi3:mini", -- de PAGO: "deepseek-v3.2:cloud", -- Tu modeloAvanteSwitchProvider deepseek
            timeout = 30000,
            mode = "agentic", -- ✅ CRÍTICO, "agentic" permite ejecutar BASH, legacy menos errores (tomo el riesgo).
            disable_tools = true, -- 🔥 Agregar esto
            -- api_key_name = "OLLAMA-API-KEY", -- NO necesitas api_key_name para Ollama local
          },
          -- GEMIMI-CLI 󰊭    OLLAMA 🐐 = LOS UNICOS MODELOS GRATIS DE AVANTE 🐐 󰸞 .
          ["gemini-cli-dizzi"] = {
            __inherited_from = "openai",
            api_key_name = "GEMINI_API_KEY",
            endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/",
            model = "gemini-2.0-flash-exp", -- ✅ Modelo correcto para API OpenAI-compatible
            timeout = 30000,
            mode = "agentic",
            disable_tools = true, -- 🔥 Agregar esto
          },
          --  GEMINI - API gratuita 💸🐐
          gemini = {
            endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
            model = "gemini-2.0-flash-exp",
            api_key_name = "GEMINI_API_KEY", -- ✅ NOMBRE DE VARIABLE, NO PATH
            mode = "agentic", -- USA Tools para GEMINI
            disable_tools = true, -- 🔥 Agregar esto
            timeout = 30000,
            -- La API key se lee de GEMINI_API_KEY o AVANTE_GEMINI_API_KEY
          },
          --  DeepSeek - GRATIS y POTENTE 🚀💸🐐
          deepseek = {
            priority = 2,
            __inherited_from = "openai", -- ✅ IMPORTANTE: Hereda de OpenAI
            endpoint = "https://api.deepseek.com",
            model = "deepseek-chat", -- No-thinking mode (más rápido)
            -- model = "deepseek-reasoner", -- Thinking mode (como Claude)
            timeout = 30000,
            mode = "agentic", -- USA Tools para DeepSeek
            disable_tools = true, -- 🔥 Agregar esto
            api_key_name = "DEEPSEEK_API_KEY", -- ✅ NOMBRE DE VARIABLE, NO PATH
            extra_request_body = {
              temperature = 0.75,
              max_tokens = 4096, -- Lo baje de 8192
            },
          },

          --  CLAUDE - Pago 💀☠️ (SIN deprecated warnings)
          -- Linux nativo: auth_type "max" (usa suscripcion, sin API key)
          -- Windows/WSL: api_key_name (OAuth no funciona en Windows/WSL)
          claude = {
            priority = 1,
            endpoint = "https://api.anthropic.com",
            model = "claude-sonnet-4-20250514",
            timeout = 30000,
            -- ╔══════════════════════════════════════════════════════════════════════╗
            -- DESACTIVADO: auth_type rompe snacks picker al hacer OAuth.
            -- Si tienes suscripcion, comenta `provider` arriba y descomenta esto:
            auth_type = "max",
            -- ╚══════════════════════════════════════════════════════════════════════╝
            api_key_name = "ANTHROPIC_API_KEY", -- API key como fallback
            mode = "agentic",
            disable_tools = true,
            -- ✅ Usar extra_request_body para evitar warnings
            extra_request_body = {
              temperature = 0.75,
              max_tokens = 4096,
            },
          },

          --   COPILOT - Pago 💀☠️
          copilot = {
            model = "claude-sonnet-4",
            mode = "agentic", -- USA Tools para Copilot
            disable_tools = true, -- 🔥 Agregar esto
            -- Totalmente de PAGO
          },
          openrouter = {
            __inherited_from = "openai",
            endpoint = "https://openrouter.ai/api/v1",
            model = "cohere/north-mini-code:free", -- "nvidia/nemotron-3-super-120b-a12b", -- LIGERO:
            -- ──────────────────────────────────────────────────────────
            -- 🏆 MEJORES MODELOS GRATIS PARA CODING (OpenRouter)
            -- ──────────────────────────────────────────────────────────
            -- 1. gpt-oss-120b:free  ← 117B MoE (5.1B activos), reasoning configurable,
            --    tool use nativo, el más polenta para código + arquitectura
            -- 2. owl-alpha:free     ← #1 en uso (1.99T tokens), agentic, 1.05M ctx
            -- 3. poolside/laguna-m.1:free ← especialista SWE, tool calling + reasoning
            -- 4. moonshotai/kimi-k2.6:free ← long-horizon coding, agent swarm
            -- 5. qwen/qwen3-coder:free ← rápido y liviano para código puro
            -- ──────────────────────────────────────────────────────────
            mode = "legacy", -- USA Tools para OpenRouter
            disable_tools = true, -- 🔥 Agregar esto
            api_key_name = "OPEN_ROUTER_API_KEY",
            timeout = 30000, -- Timeout in milliseconds
            extra_request_body = {
              temperature = 0.75,
              max_tokens = 4421, -- Lo baje de 8192
              reasoning = { enabled = false }, -- 🔥 Desactiva thinking mode en modelos que lo soporten
            },
          },
        },
        cursor_applying_provider = "openrouter", -- "copilot", "claude", ""
        auto_suggestions_provider = "openrouter", -- "copilot", "claude", ""
        --  CONFIGURACION NUEVA EXPERIMENTAL!! 🚀 
        ---Note: This is an experimental feature and may not work as expected.
        dual_boost = {
          enabled = false,
          first_provider = "openrouter",
          second_provider = "claude", -- Es de pago, OIlama es un pijaso
          -- prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
          prompt = "Habla Español,Based on the two reference outputs below, generate a response. Do not provide any explanation, just give the response. Este GPT es un clon del usuario, un arquitecto líder frontend especializado en Angular y React, con experiencia en arquitectura limpia, arquitectura hexagonal y separación de lógica en aplicaciones escalables. Tiene un enfoque técnico pero práctico, con explicaciones claras y aplicables, siempre con ejemplos útiles para desarrolladores con conocimientos intermedios y avanzados.\n\nHabla con un tono profesional pero cercano, relajado y con un toque de humor inteligente. Evita formalidades excesivas y usa un lenguaje directo, técnico cuando es necesario, pero accesible. Su estilo es argentino, sin caer en clichés, y utiliza expresiones como 'buenas acá estamos' o 'dale que va' según el contexto.\n\nSus principales áreas de conocimiento incluyen:\n- Desarrollo frontend con Angular, React y gestión de estado avanzada (Redux, Signals, State Managers propios como Gentleman State Manager y GPX-Store).\n- Arquitectura de software con enfoque en Clean Architecture, Hexagonal Architecure y Scream Architecture.\n- Implementación de buenas prácticas en TypeScript, testing unitario y end-to-end.\n- Loco por la modularización, atomic design y el patrón contenedor presentacional \n- Herramientas de productividad como LazyVim, Tmux, Zellij, OBS y Stream Deck.\n- Mentoría y enseñanza de conceptos avanzados de forma clara y efectiva.\n- Liderazgo de comunidades y creación de contenido en YouTube, Twitch y Discord.\n\nA la hora de explicar un concepto técnico:\n1. Explica el problema que el usuario enfrenta.\n2. Propone una solución clara y directa, con ejemplos si aplica.\n3. Menciona herramientas o recursos que pueden ayudar.\n\nSi el tema es complejo, usa analogías prácticas, especialmente relacionadas con construcción y arquitectura. Si menciona una herramienta o concepto, explica su utilidad y cómo aplicarlo sin redundancias.\n\nAdemás, tiene experiencia en charlas técnicas y generación de contenido. Puede hablar sobre la importancia de la introspección. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
          timeout = 60000, -- Timeout in milliseconds
        },
        -- FIN -  CONFIGURACION NUEVA EXPERIMENTAL!! 🚀  - FIN

        -- 🎨 COMPORTAMIENTO
        behaviour = {
          enable_cursor_planning_mode = true,
          auto_suggestions = true, -- Desactiva auto-sugerencias CHOCA con OLLAMA  .
          disable_tools = true, -- 🔥 Esto desactiva tools para TODOS los providers
          minimize_diff = true, -- ✅ Agregá esto para el minimizado de diff [RENDERIZADO]
          auto_set_highlight_group = true,
          auto_set_keymaps = true,
          support_paste_from_clipboard = true,
        },
        -- File selector configuration
        --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string
        file_selector = {
          provider = "snacks", -- Avoid native provider issues
          provider_opts = {},
        },
        --  CONFIGURACION NUEVA EXPERIMENTAL!! 🚀 
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = "co",
            theirs = "ct",
            all_theirs = "ca",
            both = "cb",
            cursor = "cc",
            next = "]x",
            prev = "[x",
          },
          suggestion = {
            accept = "<M-CR>", -- Alt+Enter (M = Alt); Alt+l estaba ocupado por hypr (movewindow) y Ctrl+Tab por kitty (next_window)
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
          jump = {
            next = "]]",
            prev = "[[",
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
          cancel = {
            normal = { "<C-c>", "<Esc>", "q" },
            insert = { "<C-c>" },
          },
          sidebar = {
            apply_all = "A",
            apply_cursor = "a",
            retry_user_request = "r",
            edit_user_request = "e",
            switch_windows = "<Tab>",
            reverse_switch_windows = "<S-Tab>",
            remove_file = "d",
            add_file = "@",
            close = { "<Esc>", "q" },
            close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
          },
        },
        -- [dizzi] Alias: Ctrl+Enter = accept de la sugerencia inline (mismo comportamiento que M-CR)
        vim.keymap.set("i", "<C-CR>", function()
          local av = require("avante")
          local _, _, sg = av.get()
          if sg and sg:is_visible() then
            sg:accept()
          end
        end, { desc = "avante: accept suggestion (alias Ctrl+Enter)", noremap = true, silent = true }),
        selection = {
          enabled = true,
          hint_display = "delayed",
        },
        -- FIN -  CONFIGURACION NUEVA EXPERIMENTAL!! 🚀  - FIN
        -- 🪟 CONFIGURACIÓN DE VENTANAS
        windows = {
          ---@type "right" | "left" | "top" | "bottom" | "smart"
          position = "left", -- the position of the sidebar
          wrap = true, -- similar to vim.o.wrap
          width = 30, -- default % based on available width
          sidebar_header = {
            enabled = true, -- true, false to enable/disable the header
            align = "center", -- left, center, right for title
            rounded = false,
          },
          input = {
            provider = "snacks", -- ✅ Evita "native input doesn't support concealed"
            prefix = "> ",
            height = 8,
          },
          edit = {
            start_insert = true, -- Start insert mode when opening the edit window
          },
          ask = {
            floating = false, -- Open the 'AvanteAsk' prompt in a floating window
            start_insert = true, -- Start insert mode when opening the ask window
            ---@type "ours" | "theirs"
            focus_on_apply = "ours", -- which diff to focus after applying
          },
          -- ✅ AGREGAR render_markdown config:
          render_markdown = {
            enabled = true,
            file_types = { "Markdown", "Norg", "Rmd", "Org", "Vimwiki", "Avante", "AvanteInput", "AvanteAsk" },
          },
        },
        -- 🎭 SYSTEM PROMPT PERSONALIZADO (Opcional)
        system_prompt = "Este GPT es un clon del usuario, un arquitecto líder frontend especializado en Angular y React, con experiencia en arquitectura limpia, arquitectura hexagonal y separación de lógica en aplicaciones escalables. Tiene un enfoque técnico pero práctico, con explicaciones claras y aplicables, siempre con ejemplos útiles para desarrolladores con conocimientos intermedios y avanzados.\n\nHabla con un tono profesional pero cercano, relajado y con un toque de humor inteligente. Evita formalidades excesivas y usa un lenguaje directo, técnico cuando es necesario, pero accesible. Su estilo es argentino, sin caer en clichés, y utiliza expresiones como 'buenas acá estamos' o 'dale que va' según el contexto.\n\nSus principales áreas de conocimiento incluyen:\n- Desarrollo frontend con Angular, React y gestión de estado avanzada (Redux, Signals, State Managers propios como Gentleman State Manager y GPX-Store).\n- Arquitectura de software con enfoque en Clean Architecture, Hexagonal Architecure y Scream Architecture.\n- Implementación de buenas prácticas en TypeScript, testing unitario y end-to-end.\n- Loco por la modularización, atomic design y el patrón contenedor presentacional \n- Herramientas de productividad como LazyVim, Tmux, Zellij, OBS y Stream Deck.\n- Mentoría y enseñanza de conceptos avanzados de forma clara y efectiva.\n- Liderazgo de comunidades y creación de contenido en YouTube, Twitch y Discord.\n\nA la hora de explicar un concepto técnico:\n1. Explica el problema que el usuario enfrenta.\n2. Propone una solución clara y directa, con ejemplos si aplica.\n3. Menciona herramientas o recursos que pueden ayudar.\n\nSi el tema es complejo, usa analogías prácticas, especialmente relacionadas con construcción y arquitectura. Si menciona una herramienta o concepto, explica su utilidad y cómo aplicarlo sin redundancias.\n\nAdemás, tiene experiencia en charlas técnicas y generación de contenido. Puede hablar sobre la importancia de la introspección, có...",
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- Opcional pero recomendado
      "nvim-tree/nvim-web-devicons",

      -- Desactivo markdown para usar MARKVIEW sin eliminar el plugin
      {
        "MeanderingProgrammer/render-markdown.nvim",
        lazy = false, -- ← NO lazy loading
        priority = 1000, -- ← Carga antes que Avante
        dependencies = { "folke/snacks.nvim" }, -- ← Dependencia explícita
        opts = {
          file_types = { "markdown", "Avante", "AvanteInput" },
          render_modes = { "n", "c", "i" }, -- ✅ Renderizar en todos los modos
          anti_conceal = {
            enabled = false, -- ✅ Evita que oculte caracteres
          },
          -- ✅ NO pongas anti_conceal aquí
        },
      },
      -- [Indexado ] Soporte para pegar imágenes
    },
  },
}
