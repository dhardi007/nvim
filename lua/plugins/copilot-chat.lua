-- CopilotChat.nvim: el chat oficial de GitHub Copilot, companion ideal de NES.
-- Usa el MISMO copilot_ls que genera las líneas verdes predictivas (copilot.lua),
-- así que NES y el chat comparten sesión/quota del servidor.
-- Comandos: :CopilotChat, `:CopilotChatCommit`, prompts <leader>cc (LazyVim default)
-- Este archivo estaba en disabled/ durante la migración a Avante; se re-activó
-- como must-pull para aprovechar el ecosistema Copilot (NES + chat + diffs).

-- Define prompts for Copilot
-- This table contains various prompts that can be used to interact with Copilot.
local prompts = {
  Commit = "Por favor genera un mensaje de commit para el siguiente código. Escribe un mensaje de commit para el cambio, siguiendo la convención de Commitizen. Manténlo simple...", -- Solicitud para generar un mensaje de commit
  Explain = "Por favor explica cómo funciona el siguiente código.", -- Solicitud para explicar el código                                                                                                       -- Prompt to improve wording
  Review = "Por favor revisa el siguiente código y proporciona sugerencias para mejorarlo.", -- Solicitud para revisar el código
  Tests = "Por favor explica cómo funciona el código seleccionado y luego genera pruebas unitarias para él.", -- Solicitud para generar pruebas unitarias
  Refactor = "Por favor refactoriza el siguiente código para mejorar su claridad y legibilidad.", -- Solicitud para refactorizar el código
  FixCode = "Por favor corrige el siguiente código para que funcione como se espera.", -- Solicitud para corregir el código
  FixError = "Por favor explica el error en el siguiente texto y proporciona una solución.", -- Solicitud para corregir errores
  Optimize = "OPTIMIZA el siguiente código para mejorar claridad y legibilidad", -- Solicitud para optimizar el código
  BetterNamings = "Por favor proporciona mejores nombres para las siguientes variables y funciones.", -- Solicitud para sugerir mejores nombres
  Documentation = "Por favor proporciona documentación para el siguiente código.", -- Solicitud para generar documentación
  JsDocs = "Por favor proporciona JsDocs para el siguiente código.", -- Solicitud para generar JsDocs
  DocumentationForGithub = "Por favor proporciona documentación para el siguiente código lista para GitHub usando markdown.", -- Solicitud para generar documentación para GitHub
  CreateAPost = "Por favor proporciona documentación para el siguiente código para publicarlo en redes sociales, como Linkedin. Debe ser profunda, bien explicada y fácil de entender. Hazlo también de manera divertida y atractiva.", -- Solicitud para crear una publicación en redes sociales
  SwaggerApiDocs = "Por favor proporciona documentación para la siguiente API usando Swagger.", -- Solicitud para generar documentación Swagger
  SwaggerJsDocs = "Por favor escribe JSDoc para la siguiente API usando Swagger.", -- Solicitud para generar Swagger JsDocs
  Summarize = "Por favor resume el siguiente texto.", -- Solicitud para resumir texto
  Spelling = "Por favor corrige cualquier error gramatical y de ortografía en el siguiente texto.", -- Solicitud para corregir ortografía y gramática
  Wording = "Por favor mejora la gramática y redacción del siguiente texto.", -- Solicitud para mejorar redacción
  Concise = "Por favor, reescribe el siguiente texto para que sea más conciso.", -- Solicitud para hacer el texto más conciso                                                                                                                                 -- Solicitud para hacer el texto más conciso
}

-- Plugin configuration
-- This table contains the configuration for various plugins used in Neovim.
return {
  {
    -- Copilot Chat plugin configuration
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = "CopilotChat",
    opts = {
      prompts = prompts,
      system_prompt = "Este GPT es un clon del usuario, un arquitecto líder frontend especializado en Angular y React, con experiencia en arquitectura limpia, arquitectura hexagonal y separación de lógica en aplicaciones escalables. Tiene un enfoque técnico pero práctico, con explicaciones claras y aplicables, siempre con ejemplos útiles para desarrolladores con conocimientos intermedios y avanzados.\n\nHabla con un tono profesional pero cercano, relajado y con un toque de humor inteligente. Evita formalidades excesivas y usa un lenguaje directo, técnico cuando es necesario, pero accesible. Su estilo es argentino, sin caer en clichés, y utiliza expresiones como “buenas acá estamos” o “dale que va” según el contexto.\n\nSus principales áreas de conocimiento incluyen:\n- Desarrollo frontend con Angular, React y gestión de estado avanzada (Redux, Signals, State Managers propios como Gentleman State Manager y GPX-Store).\n- Arquitectura de software con enfoque en Clean Architecture, Hexagonal Architecure y Scream Architecture.\n- Implementación de buenas prácticas en TypeScript, testing unitario y end-to-end.\n- Loco por la modularización, atomic design y el patrón contenedor presentacional \n- Herramientas de productividad como LazyVim, Tmux, Zellij, OBS y Stream Deck.\n- Mentoría y enseñanza de conceptos avanzados de forma clara y efectiva.\n- Liderazgo de comunidades y creación de contenido en YouTube, Twitch y Discord.\n\nA la hora de explicar un concepto técnico:\n1. Explica el problema que el usuario enfrenta.\n2. Propone una solución clara y directa, con ejemplos si aplica.\n3. Menciona herramientas o recursos que pueden ayudar.\n\nSi el tema es complejo, usa analogías prácticas, especialmente relacionadas con construcción y arquitectura. Si menciona una herramienta o concepto, explica su utilidad y cómo aplicarlo sin redundancias.\n\nAdemás, tiene experiencia en charlas técnicas y generación de contenido. Puede hablar sobre la importancia de la introspección, cómo balancear liderazgo y comunidad, y cómo mantenerse actualizado en tecnología mientras se experimenta con nuevas herramientas. Su estilo de comunicación es directo, pragmático y sin rodeos, pero siempre accesible y ameno.\n\nEsta es una transcripción de uno de sus vídeos para que veas como habla:\n\nLe estaba contando la otra vez que tenía una condición Que es de adulto altamente calificado no sé si lo conocen pero no es bueno el oto lo está hablando con mi mujer y y a mí cuando yo era chico mi mamá me lo dijo en su momento que a mí me habían encontrado una condición Que ti un iq muy elevado cuando era muy chico eh pero muy elevado a nivel de que estaba 5 años o 6 años por delante de un niño",
      model = "claude-3.5-sonnet",
      answer_header = "󱗞  The Gentleman 󱗞  ",
      auto_insert_mode = true,
      window = {
        layout = "vertical", -- [opcional de dizzi] Cambiar a "horizontal" si prefieres la ventana horizontal
        position = "left", -- [opcional de dizzi] Agregar esta línea para que aparezca a la izquierda
        width = 0.4, -- [opcional de dizzi]
        border = "rounded", -- [opcional de dizzi]
        relative = "editor", -- [opcional de dizzi]
      },
      mappings = {
        complete = {
          insert = "<Tab>",
        },
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-l>",
          insert = "<C-l>",
        },
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        toggle_sticky = {
          normal = "grr",
        },
        clear_stickies = {
          normal = "grx",
        },
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        jump_to_diff = {
          normal = "gj",
        },
        quickfix_answers = {
          normal = "gqa",
        },
        quickfix_diffs = {
          normal = "gqd",
        },
        yank_diff = {
          normal = "gy",
          register = '"', -- Default register to use for yanking
        },
        show_diff = {
          normal = "gd",
          full_diff = false, -- Show full diff instead of unified diff when showing diff window
        },
        show_info = {
          normal = "gi",
        },
        show_context = {
          normal = "gc",
        },
        show_help = {
          normal = "gh",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },
  -- Blink integration
  {
    "saghen/blink.cmp",
    optional = true,
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        providers = {
          path = {
            -- Path sources triggered by "/" interfere with CopilotChat commands
            enabled = function()
              return vim.bo.filetype ~= "copilot-chat"
            end,
          },
        },
      },
    },
  },
}
