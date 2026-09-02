return {
  "saghen/blink.cmp",
  version = "1.*", -- Usa binarios precompilados
  lazy = true,
  dependencies = { "saghen/blink.compat" },
  opts = {
    enabled = function()
      -- Chat buffers (CopilotChat, Avante, CodeCompanion): sin completado ni
      -- snippets — "gh" ahí NO debe expandir el snippet de licencia Copyright.
      local ft = vim.bo.filetype
      if ft ~= "" and vim.tbl_contains({ "copilot-chat", "Avante", "AvanteInput", "AvanteAsk", "codecompanion" }, ft) then
        return false
      end
      return vim.b.blink_cmp_enabled ~= false
    end,
    sources = {
      default = { "avante_commands", "avante_mentions", "avante_files" },
      compat = {
        "avante_commands",
        "avante_mentions",
        "avante_files",
      },
      -- LSP score_offset is typically 60
      providers = {
        avante_commands = {
          name = "avante_commands",
          module = "blink.compat.source",
          score_offset = 90,
          opts = {},
        },
        avante_files = {
          name = "avante_files",
          module = "blink.compat.source",
          score_offset = 100,
          opts = {},
        },
        avante_mentions = {
          name = "avante_mentions",
          module = "blink.compat.source",
          score_offset = 1000,
          opts = {},
        },
      },
    },
  },
}
