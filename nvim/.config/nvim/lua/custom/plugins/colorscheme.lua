return {
  {
    lazy = false,
    priority = 1000,
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require "custom.colorscheme"
    end,
  },

  { "catppuccin/nvim", name = "catppuccin" },
  "navarasu/onedark.nvim",
  "ellisonleao/gruvbox.nvim",
  "catppuccin/nvim",
  "projekt0n/github-nvim-theme",
  "kdheepak/monochrome.nvim",
  "EdenEast/nightfox.nvim",
  "folke/tokyonight.nvim",
  "Mofiqul/dracula.nvim",
  "Mofiqul/vscode.nvim",
  "RRethy/base16-nvim",
}
