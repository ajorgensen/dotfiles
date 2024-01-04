return {
    {
        'ray-x/go.nvim',
        config = function()
            require('go').setup()
            vim.keymap.set("n", "<leader>gi", "<cmd> GoImport<CR>", {})
        end,
    }
}
