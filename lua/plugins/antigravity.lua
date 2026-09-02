return {
  "NakLast/antigravity-cli.nvim",
  enabled = true,
  config = function()
    require("antigravity").setup({
      cmd = "agy",
      width_ratio = 0.2,
      height_ratio = 0.8,
      border = "rounded",
    })
  end,
  keys = {
    { "<Space>aG", "<cmd>Antigravity<CR>", mode = "n", desc = "󰨞 Toggle Antigravity AI" },
    { "<Space>G", "<cmd>Antigravity<CR>", mode = "n", desc = "󰨞 Toggle Antigravity AI" },
    -- Mas atajos en: @config.keymaps.gemini-keys /home/diego/dotfiles-dizzi/nvim/.config/nvim/lua/config/keymaps/gemini-keys.lua
  },
}
