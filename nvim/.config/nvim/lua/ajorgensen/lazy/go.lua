return {
    {
        'ray-x/go.nvim',
        dependencies = {
            'ray-x/guihua.lua',
        },
        config = function()
            require('go').setup()
            vim.keymap.set("n", "<leader>gi", "<cmd> GoImport<CR>", {})
        end,
    }
}
