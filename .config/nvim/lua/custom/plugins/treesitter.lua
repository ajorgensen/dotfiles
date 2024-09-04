return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("custom.treesitter").setup()
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context" },
}
