return {
  {
    lazy = false,
    priority = 1000,
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      vim.cmd.colorscheme "nightfox"
    end
  },

  { "catppuccin/nvim", name = "catppuccin" },
  'navarasu/onedark.nvim',
  'ellisonleao/gruvbox.nvim',
  'catppuccin/nvim',
  'projekt0n/github-nvim-theme',
  'kdheepak/monochrome.nvim',
  'EdenEast/nightfox.nvim',
  "folke/tokyonight.nvim",
}
