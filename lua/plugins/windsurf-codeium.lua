-- 💸💳💰REQUIERE API. USA:Codeium Auth
return {
  "Exafunction/windsurf.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip", -- Recomendado para snippets
  },
  event = "InsertEnter",
  config = function()
    -- 1. Configuración principal de Codeium
    require("codeium").setup({
      enable_chat = true,
      enable_cmp_source = true,
      detect_proxy = true,

      virtual_text = {
        enabled = false,
        manual = false,
        idle_delay = 75,
        filetypes = {
          python = true,
          lua = true,
          javascript = true,
          typescript = true,
          java = true,
          go = true,
          rust = true,
          cpp = true,
          c = true,
          php = true,
          ruby = true,
        },
        default_filetype_enabled = true,
        key_bindings = {
          accept = "<Tab>",
          accept_word = "<M-w>",
          accept_line = "<M-l>",
          clear = "<C-e>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },

      workspace_root = {
        use_lsp = true,
        paths = {
          ".git",
          "package.json",
          "pyproject.toml",
          "Cargo.toml",
          "go.mod",
          "composer.json",
          "Gemfile",
          "requirements.txt",
        },
      },
    })

    -- 2. Configuración de nvim-cmp
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        -- Navegación básica
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),

        -- Confirmar selección
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }),

        -- Navegar entre items
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

        -- Atajos específicos para Codeium
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif require("codeium").is_enabled() then
            -- Esto activa el autocompletado de Codeium
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, true, true), "n")
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        -- Atajo para aceptar palabra de Codeium
        ["<C-w>"] = cmp.mapping(function(fallback)
          if require("codeium").is_enabled() then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-g><C-g>", true, true, true), "n")
          else
            fallback()
          end
        end, { "i" }),
      }),

      sources = cmp.config.sources({
        { name = "codeium", priority = 1000, max_item_count = 5 },
        { name = "nvim_lsp", priority = 900 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }),

      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local icons = {
            Codeium = "🤖",
            nvim_lsp = "🔧",
            luasnip = "✨",
            buffer = "📄",
            path = "📁",
          }

          vim_item.kind = string.format("%s", icons[entry.source.name] or "?")
          vim_item.menu = ({
            codeium = "[AI]",
            nvim_lsp = "[LSP]",
            luasnip = "[SNIP]",
            buffer = "[BUF]",
            path = "[PATH]",
          })[entry.source.name]

          return vim_item
        end,
      },

      window = {
        completion = cmp.config.window.bordered({
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }),
        documentation = cmp.config.window.bordered(),
      },

      experimental = {
        ghost_text = {
          hl_group = "Comment",
        },
      },

      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
    })

    -- 3. Atajos globales personalizados
    local keymap = vim.keymap.set

    -- Atajos en modo Insert
    keymap("i", "<C-l>", function()
      vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Cmd>Codeium Chat<CR>", true, true, true))
    end, { desc = "Abrir chat de Codeium" })

    -- Atajos en modo Normal
    keymap("n", "<leader>cL", "<Cmd>Codeium Auth<CR>", { desc = "Autenticar/Login Codeium" })
    keymap("n", "<leader>ct", "<Cmd>Codeium Toggle<CR>", { desc = "Toggle Codeium" })
    keymap("n", "<leader>cs", "<Cmd>Codeium Status<CR>", { desc = "Estado Codeium" })
    keymap("n", "<leader>cc", "<Cmd>Codeium Chat<CR>", { desc = "Chat Codeium" })
    keymap("n", "<leader>cd", "<Cmd>Codeium Disable<CR>", { desc = "Deshabilitar Codeium" })
    keymap("n", "<leader>ce", "<Cmd>Codeium Enable<CR>", { desc = "Habilitar Codeium" })

    -- Atajo para forzar autocompletado
    keymap("i", "<C-g>", function()
      if require("codeium").is_enabled() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-u>", true, true, true), "n")
      end
    end, { desc = "Forzar autocompletado Codeium" })

    -- Atajo para aceptar sugerencia rápidamente
    keymap("i", "<C-y>", function()
      if cmp.visible() then
        cmp.confirm({ select = true })
      elseif require("codeium").is_enabled() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, true, true), "n")
      end
    end, { desc = "Aceptar sugerencia rápido" })

    -- 4. Configuración de LuaSnip (opcional pero recomendado)
    require("luasnip.loaders.from_vscode").lazy_load()

    -- 5. Configuración de autocomandos útiles
    local augroup = vim.api.nvim_create_augroup("CodeiumConfig", { clear = true })

    vim.api.nvim_create_autocmd("BufEnter", {
      group = augroup,
      pattern = "*",
      callback = function()
        -- Habilitar Codeium por defecto en todos los buffers
        if require("codeium").is_enabled() == false then
          vim.schedule(function()
            require("codeium").enable()
          end)
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = { "markdown", "text", "gitcommit" },
      callback = function()
        -- Configuración específica para archivos de texto
        vim.b.codeium_enabled = true
      end,
    })

    -- 6. Mensaje de inicio útil
    vim.schedule(function()
      if vim.fn.has("nvim-0.8") == 1 then
        print("✅ Codeium configurado. Usa :Codeium Auth para empezar")
        print("📝 Atajos principales:")
        print("   <Tab> - Aceptar sugerencia")
        print("   <C-Space> - Mostrar todas las sugerencias")
        print("   <leader>ct - Activar/desactivar Codeium")
        print("   <C-l> - Abrir chat de Codeium")
      end
    end)
  end,
}
