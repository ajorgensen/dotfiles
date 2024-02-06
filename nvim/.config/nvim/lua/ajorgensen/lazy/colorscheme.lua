return {
    {
        'navarasu/onedark.nvim',
        priority = 1000
    },
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000
    },
    {
        'rose-pine/neovim',
        priority = 1000
    },
    {
        'catppuccin/nvim',
        priority = 1000,
        config = function()
            vim.cmd('colorscheme catppuccin-frappe')
        end,
    }
}
