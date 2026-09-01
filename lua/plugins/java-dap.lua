-- Java DAP defaults: hacer que la config "Launch Main Class" de jdtls sea la
-- unica (default) y que pause al inicio.
--
-- ⚠️ IMPORTANTE: este `opts` EXTENDEO los defaults del extra LazyVim
-- `lazyvim.plugins.extras.lang.java`. Si se reemplaza `opts` con un objeto que
-- solo trae `dap`/`dap_main`, se rompe TODO lo demas (cmd, full_cmd, root_dir,
-- settings...) y jdtls falla con "attempt to call field 'full_cmd' (a nil
-- value)". Por eso aqui se replica la estructura completa del `opts` del extra
-- y SOLO se ajustan `dap` (stopOnEntry) y `dap_main` (on_ready -> default Launch).

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function()
      local cmd = { vim.fn.exepath("jdtls") }
      if LazyVim.has("mason.nvim") then
        local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
        table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
      end
      return {
        root_dir = function(path)
          return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
        end,

        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,

        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
        end,

        cmd = cmd,
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(cmd, {
              "-configuration",
              opts.jdtls_config_dir(project_name),
              "-data",
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return cmd
        end,

        -- DAP: forzar setup_dap() con stopOnEntry=true (pause al inicio).
        -- config_overrides es una TABLA de campos JdtDapConfig que se funde
        -- (vim.tbl_extend 'force') sobre la config de launch -> stopOnEntry=true.
        dap = {
          hotcodereplace = "auto",
          config_overrides = { stopOnEntry = true },
        },

        -- Main class scan: al terminar, dejar SOLO las configs "Launch *: *MainClass"
        -- (quita la estatica "Debug (Attach) - Remote") -> la Launch es la unica
        -- config y <leader>dc la ejecuta directo (default).
        dap_main = {
          config_overrides = { stopOnEntry = true },
          on_ready = function()
            local dap = require("dap")
            local java_cfgs = dap.configurations.java or {}

            local launch, others = {}, {}
            for _, c in ipairs(java_cfgs) do
              if c.name and vim.startswith(c.name, "Launch") then
                table.insert(launch, c)
              else
                table.insert(others, c)
              end
            end

            local kept = {}
            for _, c in ipairs(others) do
              if not (c.name == "Debug (Attach) - Remote" and c.port == 5005) then
                table.insert(kept, c)
              end
            end

            dap.configurations.java = vim.list_extend(launch, kept)
          end,
        },

        test = true,
        settings = {
          java = {
            inlayHints = {
              parameterNames = {
                enabled = "all",
              },
            },
          },
        },
      }
    end,
  },
}
