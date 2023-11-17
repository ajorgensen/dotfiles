-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use 'LinArcX/telescope-command-palette.nvim'

    use 'tpope/vim-eunuch'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-rhubarb'
    use 'tpope/vim-surround'
    use 'tpope/vim-dispatch'
    use 'tpope/vim-projectionist'
    use 'tpope/vim-dadbod'

    use "folke/trouble.nvim"
    use "theprimeagen/harpoon"
    use "mbbill/undotree"
    use "nvim-treesitter/nvim-treesitter-context"
    use "folke/zen-mode.nvim"
    use "github/copilot.vim"
    use 'jremmen/vim-ripgrep'
    use 'vim-test/vim-test'
    use 'David-Kunz/gen.nvim'

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons' }
    }

    use {
        'rcarriga/nvim-dap-ui',
        requires = {
            'mfussenegger/nvim-dap',
            'theHamsta/nvim-dap-virtual-text',
            'leoluz/nvim-dap-go',
        }
    }

    -- LSP
    use 'ray-x/go.nvim'
    use 'ray-x/guihua.lua'

    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

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
        }
    }

    -- Colors
    use 'RRethy/nvim-base16'
    use 'ellisonleao/gruvbox.nvim'
    use 'folke/tokyonight.nvim'
    use 'catppuccin/nvim'
    use 'projekt0n/github-nvim-theme'
    use 'shaunsingh/nord.nvim'
    use 'rose-pine/neovim'
    use 'joshdick/onedark.vim'
end)
