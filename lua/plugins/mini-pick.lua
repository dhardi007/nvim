-- ~/.config/nvim/lua/plugins/mini-pick.lua
return {
  "nvim-mini/mini.pick",  -- ✅ Nombre correcto
  keys = {
    { "<leader>mp", "<cmd>Pick files<cr>", desc = "Mini Files" },
  },
  config = function()
    require('mini.pick').setup()
  end,
}
