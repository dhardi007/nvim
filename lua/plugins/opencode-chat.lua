-- 🐐🗣️🔥️✍️ NO REQUIERE API: -- -- ✍️ Activar con: <leader>ao
--  Ctrl+X+M → Cambiar Model  |  Ctrl+X+A → Cambiar Provider  |  Ctrl+X+L → Switch Session
--  ~ (MEJOR QUE ANTIGRAVITY\CHAT Nativo)
--
-- ────────────────────────────────────────────────────────────
-- Utilities [by dizzi1222] — contexto rico para opencode
-- ────────────────────────────────────────────────────────────
local function get_repo_context()
  local cwd = vim.fn.getcwd()
  local git_root = vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")

  if vim.v.shell_error == 0 then
    git_root = git_root:gsub("\n", "")
    local repo_name = vim.fn.fnamemodify(git_root, ":t")
    local branch = vim.fn
      .system("git -C " .. vim.fn.shellescape(git_root) .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
      :gsub("\n", "")
    return {
      is_git = true,
      root = git_root,
      name = repo_name,
      branch = branch,
      relative_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:."),
    }
  end

  return {
    is_git = false,
    root = cwd,
    name = vim.fn.fnamemodify(cwd, ":t"),
    relative_path = vim.fn.expand("%:t"),
  }
end

local function build_claude_context(selected_text, custom_instruction)
  local repo = get_repo_context()
  local file_type = vim.bo.filetype
  local line_num = vim.fn.line(".")
  local abs_path = vim.fn.expand("%:p") -- ruta absoluta real
  local rel_path = repo.relative_path -- relativa al root del repo/cwd

  local context = "📁 Proyecto: " .. repo.name .. "\n"
  if repo.is_git then
    context = context .. "🌿 Branch: " .. repo.branch .. "\n"
  end
  context = context .. "📄 Archivo: " .. rel_path .. "\n"
  context = context .. "📂 Ruta: " .. abs_path .. "\n"
  context = context .. "🔤 Tipo: " .. (file_type ~= "" and file_type or "text") .. "\n"
  context = context .. "📍 Línea: " .. line_num .. "\n"
  context = context .. "💻 Sistema: " .. vim.loop.os_uname().sysname .. "\n\n"

  if custom_instruction then
    context = context .. "📝 Instrucción: " .. custom_instruction .. "\n\n"
  end

  if selected_text and selected_text ~= "" then
    context = context .. "```" .. file_type .. "\n" .. selected_text .. "\n```\n"
  end

  return context
end

-- ────────────────────────────────────────────────────────────
-- Helper: enviar texto/slash commands al TUI de opencode
-- ────────────────────────────────────────────────────────────
local function send_to_opencode(text)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("opencode") then
        local chan = vim.bo[buf].channel
        if chan and chan > 0 then
          vim.api.nvim_chan_send(chan, text .. "\n")
          local winid = vim.fn.bufwinid(buf)
          if winid ~= -1 then
            vim.api.nvim_set_current_win(winid)
            vim.cmd("startinsert")
          end
        end
        return
      end
    end
  end
end

-- Helper: enviar secuencias de teclas de control al TUI (Ctrl+X combos)
-- Enfoca el terminal igual que send_to_opencode para que el combo llegue bien
local function send_keys_to_opencode(keys)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("opencode") then
        local chan = vim.bo[buf].channel
        if chan and chan > 0 then
          local winid = vim.fn.bufwinid(buf)
          if winid ~= -1 then
            vim.api.nvim_set_current_win(winid)
            vim.cmd("startinsert")
          end
          vim.defer_fn(function()
            vim.api.nvim_chan_send(chan, keys)
          end, 50)
        end
        return
      end
    end
  end
end

return {
  "NickvanDyke/opencode.nvim",
  name = "opencode-nick", -- ← IMPORTANTE: nombre único
  dependencies = {
    --  Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
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
      desc = " 󰮮 Toggle OpenCode [Cli]",
    },

    -- ── Ask / Prompts ─────────────────────────────────────────
    {
      "<leader>ai",
      function()
        require("opencode").ask("", { submit = false })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode ask (input libre)",
    },
    {
      "<leader>aI",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = " 󰮮 OpenCode ask with context (@this)",
    },

    -- ── Buffer / Archivos ─────────────────────────────────────
    -- Envía el buffer actual con contexto rico (repo, branch, filetype, línea)
    {
      "<leader>ab",
      function()
        local full_file = vim.fn.join(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
        local context = build_claude_context(full_file, "Aquí está el archivo completo:")
        local repo = get_repo_context()
        send_to_opencode(context)
        vim.notify("󰮮 Buffer enviado a OpenCode\n📁 " .. repo.name, vim.log.levels.INFO)
      end,
      mode = { "n" },
      desc = " 󰮮 Send buffer actual con contexto",
    },
    -- Envía todos los buffers abiertos con contexto rico
    {
      "<leader>av",
      function()
        local full_file = vim.fn.join(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
        local context = build_claude_context(full_file, "Aquí está el archivo completo:")
        local repo = get_repo_context()
        send_to_opencode(context)
        vim.notify("󰮮 Buffer enviado a OpenCode\n📁 " .. repo.name, vim.log.levels.INFO)
      end,
      mode = { "n" },
      desc = " 󰮮 Send buffer completo con contexto",
    },

    -- ── Send selección (como ClaudeCodeSend) ──────────────────
    -- Envía el texto seleccionado con contexto rico (repo, branch, filetype, línea)
    {
      "<leader>as",
      function()
        -- Salir de visual para fijar la selección en registro "v"
        vim.cmd('normal! "vy')
        local selected_text = vim.fn.getreg("v")
        local context = build_claude_context(selected_text, "Código seleccionado:")
        send_to_opencode(context)
        vim.notify("󰮮 Selección enviada a OpenCode", vim.log.levels.INFO)
      end,
      mode = { "v" },
      desc = " 󰮮 Send selección con contexto a OpenCode",
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

    -- ── Session via command() API / Ctrl+X combos ─────────────
    {
      "<leader>aL",
      function()
        send_keys_to_opencode("\x18l") -- Ctrl+X L → Switch Session
      end,
      desc = " 󰮮 Switch Session / Historial  (Ctrl+X L)",
    },
    {
      "<leader>an",
      function()
        require("opencode").command("session.new")
      end,
      desc = " 󰮮 New Session",
    },
    {
      "<leader>au",
      function()
        send_keys_to_opencode("\x18u") -- Ctrl+X U → undo
        --     require("opencode").command("session.undo")
      end,
      desc = " 󰮮 Undo último mensaje  (Ctrl+X U)",
    },
    {
      "<leader>aW",
      function()
        send_keys_to_opencode("\x18u") -- alias de au
      end,
      desc = " 󰮮 Undo último mensaje  (alias)",
    },
    {
      "<leader>ar",
      function()
        send_keys_to_opencode("\x18r") -- Ctrl+X R → redo
        --     require("opencode").command("session.redo")
      end,
      desc = " 󰮮 Redo acción  (Ctrl+X R)",
    },
    {
      "<leader>ax",
      function()
        send_keys_to_opencode("\x03") -- Ctrl+C → interrupt real al proceso
      end,
      desc = " 󰮮 Interrupt / Detener opencode  (Ctrl+C)",
    },
    {
      "<leader>ak",
      function()
        require("opencode").command("session.compact")
      end,
      desc = " 󰮮 Compact / Reducir contexto",
    },
    -- NO LO NECESITO
    -- {
    --   "<leader>ash",
    --   function()
    --     require("opencode").command("session.share")
    --   end,
    --   desc = " 󰮮 Share session",
    -- },

    -- ── Model / Provider / Theme vía secuencias Ctrl+X ────────
    -- \x18 = Ctrl+X  |  ver shortcuts en el TUI con Ctrl+X solo
    {
      "<leader>am",
      function()
        send_keys_to_opencode("\x18m") -- Ctrl+X M → Switch Model
      end,
      desc = " 󰮮 Switch Model  (Ctrl+X M)",
    },
    {
      "<leader>aa",
      function()
        send_keys_to_opencode("\x18a") -- Ctrl+X A → Switch Provider
      end,
      desc = " 󰮮 Switch Provider  (Ctrl+X A)",
    },
    {
      "<leader>aA",
      function()
        send_keys_to_opencode("\x18a") -- Ctrl+X A → Plan/Coding mode (mismo binding)
      end,
      desc = " 󰮮 Switch Plan/Coding mode  (Ctrl+X A)",
    },
    {
      "<leader>at",
      function()
        send_keys_to_opencode("\x18t") -- Ctrl+X T → Switch colorscheme/theme
      end,
      desc = " 󰮮 Switch Theme / Colorscheme  (Ctrl+X T)",
    },

    -- ── Abrir menú Commands del TUI ───────────────────────────
    -- \x18 solo (sin letra) abre el picker de comandos
    {
      "<leader>aC",
      function()
        send_keys_to_opencode("\x18") -- Ctrl+X solo → Commands menu
      end,
      desc = " 󰮮 Abrir Commands menu  (Ctrl+X)",
    },

    -- ── Copiar conversación ───────────────────────────────────
    {
      "<leader>ac",
      function()
        send_to_opencode("/copy")
      end,
      desc = " 󰮮 /copy - Copiar conversación",
    },

    -- ── Slash commands directos al TUI ────────────────────────
    {
      "<leader>af",
      function()
        send_to_opencode("/fork")
      end,
      desc = " 󰮮 /fork - Bifurcar sesión",
    },
    {
      "<leader>aN",
      function()
        vim.ui.input({ prompt = "  Rename session: " }, function(name)
          if name and name ~= "" then
            send_to_opencode("/rename " .. name)
          end
        end)
      end,
      desc = " 󰮮 /rename - Renombrar sesión",
    },
  },

  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
      providers = {
        anthropic = {
          -- auth_type = "max",  --   Opencode SOLO  funciona con API KEYS
          api_key_cmd = "echo $ANTHROPIC_API_KEY", -- 🔥 Cambiar ESTO
          model = "claude-sonnet-4-20250514",
        },
      },
      default_provider = "anthropic",
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- ── Keymaps globales ──────────────────────────────────────
    vim.keymap.set({ "n", "x" }, "<C-a>", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = " 󰮮 Ask opencode… " })
    vim.keymap.set({ "n", "x" }, "<C-x>", function()
      require("opencode").select()
    end, { desc = " 󰮮 Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-.>", function()
      require("opencode").toggle()
    end, { desc = " 󰮮 Toggle opencode" })

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

    -- Preservar comportamiento nativo de +/- en normal mode
    vim.keymap.set("n", "+", "<C-a>", { desc = " 󰮮 Increment under cursor", noremap = true })
    vim.keymap.set("n", "-", "<C-x>", { desc = " 󰮮 Decrement under cursor", noremap = true })
  end,
}
