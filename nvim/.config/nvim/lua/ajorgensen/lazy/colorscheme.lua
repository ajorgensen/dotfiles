return {
    { 
        'catppuccin/nvim', 
        name = "catppuccin", 
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "catppuccin"
        end,
    },
    'ellisonleao/gruvbox.nvim',
    'folke/tokyonight.nvim',
    'projekt0n/github-nvim-theme',
    'shaunsingh/nord.nvim',
    'rose-pine/neovim',
    'joshdick/onedark.vim',
}
