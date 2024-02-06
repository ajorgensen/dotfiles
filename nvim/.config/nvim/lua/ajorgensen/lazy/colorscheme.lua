return {
    'navarasu/onedark.nvim',
    'ellisonleao/gruvbox.nvim',
    'rose-pine/neovim',
    'catppuccin/nvim',
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        config = function() 
            vim.cmd([[colorscheme tokyonight]])
        end,
    }
}

