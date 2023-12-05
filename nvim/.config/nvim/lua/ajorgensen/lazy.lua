require("lazy").setup({
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { { 'nvim-lua/plenary.nvim' } }
    },
    'LinArcX/telescope-command-palette.nvim',

    'tpope/vim-eunuch',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'tpope/vim-surround',
    'tpope/vim-dispatch',
    'tpope/vim-projectionist',
    'tpope/vim-dadbod',

    "folke/trouble.nvim",
    "theprimeagen/harpoon",
    "mbbill/undotree",
    "nvim-treesitter/nvim-treesitter-context",
    "folke/zen-mode.nvim",
    "github/copilot.vim",
    'jremmen/vim-ripgrep',
    'vim-test/vim-test',
    'David-Kunz/gen.nvim',

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },

    {
        'rcarriga/nvim-dap-ui',
        dependencies = {
            'mfussenegger/nvim-dap',
            'theHamsta/nvim-dap-virtual-text',
            'leoluz/nvim-dap-go',
        }
    },

    -- LSP
    'ray-x/go.nvim',
    'ray-x/guihua.lua',

    { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
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
            { 'rafamadriz/friendly-snippets' },
        }
    },

    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
    },

    -- Colors
    'RRethy/nvim-base16',
    'ellisonleao/gruvbox.nvim',
    'folke/tokyonight.nvim',
    'catppuccin/nvim',
    'projekt0n/github-nvim-theme',
    'shaunsingh/nord.nvim',
    'rose-pine/neovim',
    'joshdick/onedark.vim',
})
