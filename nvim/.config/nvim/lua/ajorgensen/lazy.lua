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

    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {
                icons = false,
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
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
    "github/copilot.vim",
    "folke/zen-mode.nvim",

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
    {
        'rose-pine/neovim',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme rose-pine-moon]])
        end,
    },


    -- LSP Support
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
    },
    "nvim-treesitter/playground",
    "theprimeagen/harpoon",
    "theprimeagen/refactoring.nvim",
    "mbbill/undotree",
    "tpope/vim-fugitive",
    "nvim-treesitter/nvim-treesitter-context",

    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    },
})
