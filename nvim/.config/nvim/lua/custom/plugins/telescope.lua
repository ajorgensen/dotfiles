return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require "custom.telescope"
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}
