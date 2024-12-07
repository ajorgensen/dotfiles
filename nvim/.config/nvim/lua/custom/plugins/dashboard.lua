return {
  {
    "nvimdev/dashboard-nvim",
    dependencies = { { "nvim-tree/nvim-web-devicons" } },

    event = "VimEnter",
    config = function()
      require "custom.dashboard"
    end,
  },
}
