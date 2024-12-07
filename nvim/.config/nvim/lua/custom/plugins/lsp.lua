return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "folke/neodev.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      { "j-hui/fidget.nvim", options = {} },

      -- Autoformatting
      "stevearc/conform.nvim",

      -- Schema Information
      "b0o/SchemaStore.nvim",
    },
    config = function()
      require("custom.lsp")
    end,
  },
}
