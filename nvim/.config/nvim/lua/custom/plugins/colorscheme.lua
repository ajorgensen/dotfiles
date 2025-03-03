return {
  "RRethy/base16-nvim",
  "folke/tokyonight.nvim",
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd "colorscheme tokyonight-night"
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd "colorscheme base16-github"
      end,
    },
  },
}
