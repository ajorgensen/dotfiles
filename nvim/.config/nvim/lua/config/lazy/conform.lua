return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup {
      format_on_save = {
        timeout_ms = 5000,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
      },
      formatters = {},
    }

    vim.keymap.set("n", "<leader>cf", function()
      require("conform").format { bufnr = 0 }
    end)
  end,
}
