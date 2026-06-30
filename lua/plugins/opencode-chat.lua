-- 🐐🗣️🔥️✍️ NO REQUIERE API: Opencode (NickvanDyke)
--  <leader>ao → Toggle  |  <C-a> → Ask @this  |  <C-x> → Select
--  <leader>ag → Menú de prompts  |  go/goo → operadores
--  @buffer, @this, @diagnostics nativos
--
-- TUI fallback para comandos que el server no expone (/fork, /share, Ctrl+X)
local function tui_send(text, focus)
  if focus == nil then
    focus = true
  end
  local bufs = vim.api.nvim_list_bufs()
  for i = 1, #bufs do
    local buf = bufs[i]
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("opencode") then
        local chan = vim.bo[buf].channel
        if chan and chan > 0 then
          vim.api.nvim_chan_send(chan, text)
          if focus then
            local win = vim.fn.bufwinid(buf)
            if win ~= -1 then
              vim.api.nvim_set_current_win(win)
              vim.cmd("startinsert")
            end
          end
          return true
        end
      end
    end
  end
  return false
end

return {
  "NickvanDyke/opencode.nvim",
  name = "opencode-nick",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  keys = {
    -- ── Toggle ───────────────────────────────────────────────
    {
      "<leader>ao",
      function()
        require("opencode").toggle()
      end,
      mode = { "n" },
      desc = " 󰮮 Toggle OpenCode",
    },

    -- ── Ask / Prompts ─────────────────────────────────────────
    {
      "<leader>al",
      function()
        local as_group = vim.api.nvim_create_augroup("opencode_as_focus", { clear = true })
        vim.api.nvim_create_autocmd("User", {
          pattern = "OpencodeEvent:*",
          group = as_group,
          once = true,
          callback = function()
            vim.defer_fn(function()
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):match("opencode") then
                  local win = vim.fn.bufwinid(buf)
                  if win ~= -1 then
                    vim.api.nvim_set_current_win(win)
                    vim.cmd("startinsert")
                  end
                  break
                end
              end
            end, 100)
          end,
        })
        require("opencode").ask("@this: ", { submit = false })
      end,
      mode = { "n", "x" },
      desc = "󰮮 OpenCode - Send / Ask a Opencode [Input]",
    },
    {
      "<leader>as",
      function()
        require("opencode").prompt("@this: ")
        vim.defer_fn(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):match("opencode") then
              local win = vim.fn.bufwinid(buf)
              if win ~= -1 then
                vim.api.nvim_set_current_win(win)
                vim.cmd("startinsert")
              end
              break
            end
          end
        end, 200)
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode - Send / Enviar a Opencode TUI",
    },

    -- ── Buffers como contexto (no submit, solo referencia) ─────
    {
      "<leader>ab",
      function()
        require("opencode").ask("@buffer: ", { submit = false })
      end,
      mode = { "n" },
      desc = " 󰮮 Agregar @buffer a contexto (sin enviar)",
    },
    {
      "<leader>aB",
      function()
        require("opencode").ask("@buffers: ", { submit = false })
      end,
      mode = { "n" },
      desc = " 󰮮 Agregar @buffers (todos) a contexto",
    },

    -- ── Prompts built-in ──────────────────────────────────────
    {
      "<leader>ap",
      function()
        require("opencode").prompt("@this", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode prompt",
    },
    {
      "<leader>ape",
      function()
        require("opencode").prompt("explain", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode explain",
    },
    {
      "<leader>apf",
      function()
        require("opencode").prompt("fix", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode fix",
    },
    {
      "<leader>apd",
      function()
        require("opencode").prompt("diagnose", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode diagnose",
    },
    {
      "<leader>apr",
      function()
        require("opencode").prompt("review", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode review",
    },
    {
      "<leader>apt",
      function()
        require("opencode").prompt("test", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode test",
    },
    {
      "<leader>apo",
      function()
        require("opencode").prompt("optimize", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode optimize",
    },

    -- ── Session management ────────────────────────────────────
    {
      "<leader>an",
      function()
        require("opencode").command("session.new")
      end,
      desc = " 󰮮 New Session",
    },
    {
      "<leader>al",
      function()
        tui_send("\x18l")
      end,
      desc = " 󰮮 Select Session (Ctrl+X L)",
    },
    {
      "<leader>au",
      function()
        require("opencode").command("session.undo")
      end,
      desc = " 󰮮 Undo último mensaje",
    },
    {
      "<leader>ar",
      function()
        require("opencode").command("session.redo")
      end,
      desc = " 󰮮 Redo acción",
    },
    {
      "<leader>ax",
      function()
        require("opencode").command("session.interrupt")
      end,
      desc = " 󰮮 Interrupt / Detener opencode",
    },
    {
      "<leader>ak",
      function()
        require("opencode").command("session.compact")
      end,
      desc = " 󰮮 Compact / Reducir contexto",
    },
    {
      "<leader>ac",
      function()
        tui_send("/share\n")
      end,
      mode = { "n", "x" },
      desc = " 󰮮 Share session (link)",
    },
    {
      "<leader>aF",
      function()
        tui_send("/fork\n")
      end,
      mode = { "n", "x" },
      desc = " 󰮮 Fork session (desde este punto)",
    },

    -- ── Focus TUI terminal ───────────────────────────────────
    {
      "<leader>af",
      function()
        local bufs = vim.api.nvim_list_bufs()
        for i = 1, #bufs do
          if vim.bo[bufs[i]].buftype == "terminal" then
            local name = vim.api.nvim_buf_get_name(bufs[i])
            if name:match("opencode") then
              local win = vim.fn.bufwinid(bufs[i])
              if win ~= -1 then
                vim.api.nvim_set_current_win(win)
                vim.cmd("startinsert")
                return
              end
            end
          end
        end
        require("opencode").toggle()
      end,
      desc = " 󰮮 Focus TUI terminal Opencode",
    },

    -- ── Model / Provider selector ────────────────────────────
    {
      "<leader>am",
      function()
        tui_send("\x18m")
      end,
      desc = " 󰮮 Select Model (Ctrl+X M)",
    },

    -- ── Menú de prompts (desde gemini-keys) ───────────────────
    {
      "<leader>ag",
      function()
        local options = {
          "   Revisar código",
          "  󱜨 Explicar código",
          "   Debuggear error",
          "  󰈏 Refactorizar",
          "  󰓅 Optimizar",
          "   󱋑 Personalizado",
        }
        local prompts = {
          "Revisa este código y sugiere mejoras:",
          "Explica este código paso a paso:",
          "Debuggea este error:",
          "Refactoriza este código:",
          "Optimiza este código:",
        }
        vim.ui.select(options, {
          prompt = " 󰊭 ~ Acción Opencode:",
        }, function(choice, idx)
          if not choice then
            return
          end
          if idx == 6 then
            vim.ui.input({ prompt = "Tu prompt: " }, function(input)
              if input and input ~= "" then
                require("opencode").ask("@this: " .. input, { submit = true })
              end
            end)
          else
            require("opencode").ask("@this: " .. prompts[idx], { submit = true })
          end
        end)
      end,
      mode = { "n", "x" },
      desc = " 󰮮 Menú de prompts Opencode",
    },
  },

  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      providers = {
        anthropic = {
          api_key_cmd = "echo $ANTHROPIC_API_KEY",
          model = "claude-sonnet-4-20250514",
        },
        gemini = {
          auth_type = "oauth",
          model = "gemini-2.5-pro",
          models = {
            ["gemini-2.5-pro"] = {
              options = {
                thinkingConfig = {
                  thinkingBudget = 8192,
                  includeThoughts = true,
                },
              },
            },
          },
        },
      },
      default_provider = "anthropic",
    }

    vim.o.autoread = true

    -- ── Inputs flotantes: limpios, sin autocompletado ──
    local function clean_input()
      vim.b.cmp_enabled = false
      vim.b.blink_cmp_enabled = false
      vim.keymap.set("i", "<Esc>", "<Esc>", { buffer = true, desc = "Exit insert mode" })
      vim.keymap.set("i", "<C-BS>", "<C-W>", { buffer = true, desc = "Delete prev word" })
    end
    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft == "opencode_ask" or ft == "AvanteAsk" or ft == "AvanteInput" then
          clean_input()
        end
      end,
    })

    -- ── Keymaps globales ──────────────────────────────────────
    vim.keymap.set({ "n", "x" }, "<C-a>", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = " 󰮮 Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function()
      require("opencode").select()
    end, { desc = " 󰮮 Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-.>", function()
      require("opencode").toggle()
    end, { desc = " 󰮮 Toggle opencode" })

    -- <leader>ft: OpenCode en root del proyecto (git root o cwd)
    vim.keymap.set("n", "<leader>ft", function()
      local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      if root == "" then root = vim.fn.getcwd() end
      require("opencode").toggle({ cwd = root })
    end, { desc = " 󰮮 OpenCode en project root" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = " 󰮮 Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = " 󰮮 Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = " 󰮮 Scroll opencode up" })
    vim.keymap.set("n", "<S-C-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = " 󰮮 Scroll opencode down" })
  end,
}
