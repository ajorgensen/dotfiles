-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")

    use({
        "nvim-telescope/telescope.nvim",
        tag = "0.1.0",
        requires = { { "nvim-lua/plenary.nvim" } },
    })

    use {
        "cbochs/grapple.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    }

    use("mbbill/undotree")

    use("tpope/vim-eunuch")
    use("tpope/vim-fugitive")
    use("tpope/vim-rhubarb")
    use("tpope/vim-surround")
    use("tpope/vim-dispatch")
    use("tpope/vim-projectionist")

    use('hoob3rt/lualine.nvim')
    use('ThePrimeagen/git-worktree.nvim')
    use('vim-test/vim-test')
    use('preservim/vimux')
    use('gpanders/editorconfig.nvim')

    use("NoahTheDuke/vim-just")

    -- Language Support
    use({
        "ray-x/go.nvim",
        requires = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        }
    })

    use('rhysd/vim-grammarous')
    use("jose-elias-alvarez/typescript.nvim")

    -- Colors
    use({ "shaunsingh/nord.nvim", })
    use({ "folke/tokyonight.nvim", })

    -- LSP Support
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    })
    use("nvim-treesitter/playground")
    use({
        "VonHeikemen/lsp-zero.nvim",
        requires = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            { "thomasfaingnaert/vim-lsp-ultisnips" },
            { "jose-elias-alvarez/null-ls.nvim" },
            { "jay-babu/mason-null-ls.nvim" },
            { "lukas-reineke/lsp-format.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
        },
    })
end)
