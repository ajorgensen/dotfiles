return {
    'stevenarc/conform.nvim',
    opts = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylelua" },
                go = { "gofmt" },
            }
        })
    end
}
