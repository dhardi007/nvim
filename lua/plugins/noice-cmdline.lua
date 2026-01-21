-- Configuración de Noice.nvim centrada y personalizada
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup", -- Usa el popup centrado
      opts = {}, -- Opciones globales para el cmdline
      format = {
        -- Formatos de comandos con iconos personalizados
        cmdline = { pattern = "^:", icon = "~ 󰣇 ", lang = "vim" }, -- 
        -- search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
        -- search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
        -- filter = { pattern = "^:%s*!", icon = "󱪣 ", lang = "bash" },
        --   cmdline = { icon = "󰣇 " }, --  ,  ,  ,  , 󱆃 .
        --   search_down = { icon = " " },
        --   search_up = { icon = " " },
        --   filter = { icon = "󱪣 " },
        --   lua = { icon = " " },
        --   help = { icon = " " },
        lua = {
          pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
          icon = " ",
          lang = "lua",
        },
        help = { pattern = "^:%s*he?l?p?%s+", icon = " " },
        input = { view = "cmdline_input", icon = "󰥻 " },
      },
    },

    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = "virtualtext",
    },

    popupmenu = {
      enabled = true,
      backend = "nui",
    },

    -- 🎨 VISTAS PERSONALIZADAS (AQUÍ SE CENTRA TODO)
    views = {
      -- Cmdline popup centrado
      cmdline_popup = {
        position = {
          row = "50%", -- Centrado verticalmente
          col = "50%", -- Centrado horizontalmente
        },
        size = {
          width = 60,
          height = "auto",
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = {
            Normal = "Normal",
            FloatBorder = "DiagnosticInfo",
          },
        },
      },

      -- Popupmenu (autocompletado) un poco más abajo
      popupmenu = {
        relative = "editor",
        position = {
          row = "60%",
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = {
            Normal = "Normal",
            FloatBorder = "DiagnosticInfo",
          },
        },
      },

      -- Confirmaciones centradas
      confirm = {
        position = {
          row = "50%",
          col = "50%",
        },
        size = {
          width = "auto",
          height = "auto",
        },
        border = {
          style = "rounded",
        },
      },

      -- Notificaciones en esquina superior derecha
      notify = {
        position = {
          row = 2,
          col = "100%",
        },
        size = {
          width = "auto",
          height = "auto",
        },
      },
    },

    -- 🎨 FORMATO DE MENSAJES
    format = {
      level = {
        icons = {
          error = "✖",
          warn = "▼",
          info = "●",
        },
      },
    },

    -- LSP
    lsp = {
      progress = {
        enabled = true,
        format = "lsp_progress",
        format_done = "lsp_progress_done",
        throttle = 1000 / 30,
        view = "mini",
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = {
        enabled = true,
        silent = false,
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
          luasnip = true,
          throttle = 50,
        },
      },
      message = {
        enabled = true,
        view = "notify",
      },
    },

    -- 🎨 PRESETS
    presets = {
      bottom_search = true, -- Cambiar a false para usar el popup centrado de Busqueda
      command_palette = true,
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = false,
    },

    -- 🎨 RUTAS PERSONALIZADAS (opcional)
    routes = {
      -- Filtrar mensajes molestos
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
    },
  },

  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },

  keys = {
    {
      "<leader>nl",
      function()
        require("noice").cmd("last")
      end,
      desc = "Noice Last Message",
    },
    {
      "<leader>nh",
      function()
        require("noice").cmd("history")
      end,
      desc = "Noice History",
    },
    {
      "<leader>na",
      function()
        require("noice").cmd("all")
      end,
      desc = "Noice All",
    },
    {
      "<leader>nd",
      function()
        require("noice").cmd("dismiss")
      end,
      desc = "Dismiss All",
    },
    {
      "<leader>nt",
      function()
        require("noice").cmd("pick")
      end,
      desc = "Noice Picker (Telescope/FzfLua)",
    },
  },
}
