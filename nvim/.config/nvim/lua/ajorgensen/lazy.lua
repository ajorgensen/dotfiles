local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        dependencies = { { 'nvim-lua/plenary.nvim' } },
    },

    {
        'cbochs/grapple.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },

    'mbbill/undotree',
    'tpope/vim-eunuch',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'tpope/vim-surround',
    'tpope/vim-dispatch',
    'tpope/vim-projectionist',

    'hoob3rt/lualine.nvim',
    'ThePrimeagen/git-worktree.nvim',
    'vim-test/vim-test',
    'preservim/vimux',
    'gpanders/editorconfig.nvim',

    'NoahTheDuke/vim-just',

    {
      'christoomey/vim-tmux-navigator',
      lazy = false,
    },

    -- Language Support
    {
        'ray-x/go.nvim',
        dependencies = {
            'ray-x/guihua.lua',
            'neovim/nvim-lspconfig',
            'nvim-treesitter/nvim-treesitter',
        }
    },

    'rhysd/vim-grammarous',
    'jose-elias-alvarez/typescript.nvim',

    -- Colors
    'shaunsingh/nord.nvim',
    'folke/tokyonight.nvim',
    'ellisonleao/gruvbox.nvim',
    'joshdick/onedark.vim',

    -- LSP Support
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
    },
    'nvim-treesitter/playground',
    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { 'thomasfaingnaert/vim-lsp-ultisnips' },
            { 'jose-elias-alvarez/null-ls.nvim' },
            { 'jay-babu/mason-null-ls.nvim' },
            { 'lukas-reineke/lsp-format.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        },
    },
})
