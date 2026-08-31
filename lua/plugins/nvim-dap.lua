-- This file contains the configuration for the nvim-dap plugin in Neovim.

return {
  {
    -- Plugin: nvim-dap
    -- URL: https://github.com/mfussenegger/nvim-dap
    -- Description: Debug Adapter Protocol client implementation for Neovim.
    "mfussenegger/nvim-dap",
    recommended = true, -- Recommended plugin
    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

    dependencies = {
      -- Plugin: nvim-dap-ui
      -- URL: https://github.com/rcarriga/nvim-dap-ui
      -- Description: A UI for nvim-dap.
      "rcarriga/nvim-dap-ui",

      -- Plugin: nvim-dap-virtual-text
      -- URL: https://github.com/theHamsta/nvim-dap-virtual-text
      -- Description: Virtual text for the debugger.
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {}, -- Default options
      },
    },

    -- Keybindings for nvim-dap
    keys = {
      { "<leader>d", "", desc = "+debug", mode = { "n", "v" } }, -- Group for debug commands
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>da",
        function()
          require("dap").continue({ before = get_args })
        end,
        desc = "Run with Args",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to Line (No Execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
    },

    config = function()
      local dap = require("dap")

      -- Load mason-nvim-dap if available
      if LazyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      -- Set highlight for DapStoppedLine
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- Define signs for DAP
      for name, sign in pairs(LazyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- Setup DAP configuration using VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      -- Function to load environment variables
      local function load_env_variables()
        local variables = {}
        for k, v in pairs(vim.fn.environ()) do
          variables[k] = v
        end

        -- Load variables from .env file manually
        local env_file_path = vim.fn.getcwd() .. "/.env"
        local env_file = io.open(env_file_path, "r")
        if env_file then
          for line in env_file:lines() do
            for key, value in string.gmatch(line, "([%w_]+)=([%w_]+)") do
              variables[key] = value
            end
          end
          env_file:close()
        else
          print("Error: .env file not found in " .. env_file_path)
        end
        return variables
      end

      -- Add the env property to each existing Go configuration
      for _, config in pairs(dap.configurations.go or {}) do
        config.env = load_env_variables
      end

      -- JS/TS launch configurations (adapter pwa-node con puerto fijo)
      for _, language in ipairs({ "typescriptreact", "typescript", "javascript", "javascriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            -- Ruta ABSOLUTA del buffer actual. Usar "${file}" relativiza a
            -- ../../tmp/... y el breakpoint no casa (sesión "running" que nunca
            -- pausa). Con program = función que devuelve expand("%:p") node
            -- ejecuta EXACTAMENTE el archivo donde está el breakpoint.
            program = function()
              return vim.fn.expand("%:p")
            end,
            cwd = function()
              return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
            end,
            sourceMaps = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome (React/Dev)",
            url = "http://localhost:5173",
            webRoot = "${workspaceFolder}",
            runtimeExecutable = "/home/diego/.nix-profile/bin/chromium",
            sourceMaps = true,
          },
          {
            type = "pwa-chrome",
            request = "attach",
            name = "Attach to Chrome",
            port = 9222,
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
          },
        }
      end

      -- Adapters pwa-* para vscode-js-debug.
      -- vsDebugServer.js NO habla por stdio: escucha en un puerto TCP y lo imprime
      -- en stdout (ej. "53397"). Leer ese stdout (como hace nvim-dap-vscode-js) es
      -- frágil: si el puerto llega con texto extra, nvim-dap lo rechaza con
      -- "adapter.port is required for server adapter". Solución robusta: el binario
      -- ACEPTA el puerto como ARGUMENTO POSICIONAL (`node vsDebugServer.js 53700`
      -- -> "Listening at :::53700"), así que lo arrancamos como job con puerto FIJO
      -- y registramos los adapters como `server` con ese port => `adapter.port`
      -- siempre es un número y nunca falla.
      local port = 53700
      local debugger_bin = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug/out/src/vsDebugServer.js"
      vim.fn.jobstart({ "node", debugger_bin, tostring(port) }, { detach = true })

      dap.adapters["pwa-node"] = { type = "server", host = "127.0.0.1", port = port }
      dap.adapters["pwa-chrome"] = dap.adapters["pwa-node"]
      dap.adapters["pwa-msedge"] = dap.adapters["pwa-node"]
      dap.adapters["node-terminal"] = dap.adapters["pwa-node"]
    end,
  },

  -- vscode-js-debug: official JS/TS debugger
  {
    "microsoft/vscode-js-debug",
    lazy = true,
    -- --ignore-scripts evita el postinstall de Playwright (necesita apt-get, no disponible).
    -- El adapter pwa-node (depuración de Node) no requiere el navegador Chromium.
    build = "npm install --legacy-peer-deps --ignore-scripts && npx gulp vsDebugServerBundle && mv dist out",
    version = "1.x",
  },
}
