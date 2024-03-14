return {
    'tpope/vim-eunuch',
    'tpope/vim-rhubarb',
    'tpope/vim-surround',
    'tpope/vim-dispatch',
    'tpope/vim-projectionist',
    'tpope/vim-dadbod',
    {
        'tpope/vim-fugitive',
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        end
    },
}
