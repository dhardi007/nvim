return {
  {
    "andweeb/presence.nvim",
    lazy = true,
    build = function(plugin)
      require("dizzi.presence_patch").patch_presence(plugin.dir)
    end,
    config = function()
      require("presence"):setup({
        auto_update = true,
        neovim_image_text = "Editando en Neovim",
        main_image = "neovim",
        client_id = "793271441293967371",
        buttons = true,
        enable_line_number = true,
        workspace_text = function(project_name, filename)
          local hour = tonumber(os.date('%H'))
          local status =
            hour >= 22 and 'Late night coding' or
            hour >= 18 and 'Evening session' or
            hour >= 12 and 'Afternoon coding' or
            hour >= 5 and 'Morning productivity' or
            'Midnight hacking'
          return project_name and ("Working on " .. project_name .. " • " .. status) or status
        end,
        editing_text = "Editing %s",
        reading_text = "Reading %s",
        file_explorer_text = "Browsing %s",
        plugin_manager_text = "Managing plugins",
        git_commit_text = "Committing changes",
        line_number_text = "Line %s out of %s",
      })
    end,
  },
}