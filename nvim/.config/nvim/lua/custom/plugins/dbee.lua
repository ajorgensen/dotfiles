return {
  {
    "kndndrj/nvim-dbee",
    enabled = true,
    dependencies = { "MunifTanjim/nui.nvim" },
    build = function()
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup {}
      require "custom.dbee"
    end,
  },
}
