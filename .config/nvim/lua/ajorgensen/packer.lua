return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use { "junegunn/fzf", run = ":call fzf#install()" }
  use "junegunn/fzf.vim"

  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use 'BurntSushi/ripgrep'

  -- language support
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }
  use 'neovim/nvim-lspconfig'
  -- use { 'neoclide/coc.nvim', branch = 'release' }
  use { 
    'ms-jpq/coq_nvim', 
    branch = 'coq',
    requires = {
      { 'ms-jpq/coq.artifacts', branch = 'artifacts' },
      {
        'ms-jpq/coq.thirdparty',
        branch = '3p',
        config = function()
          require 'coq_3p' { { src = 'copilot', short_name = 'COP', accept_key = '<c-f>' } }
        end,
      },
    },
  }

  -- languages
  use 'ray-x/go.nvim' use 'ray-x/guihua.lua'
  use 'udalov/kotlin-vim'
  use 'zchee/vim-flatbuffers'
  use 'uarun/vim-protobuf'
  use 'SirVer/ultisnips'
  use 'tree-sitter/tree-sitter-go'

  -- tpope
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'tpope/vim-projectionist'
  use 'tpope/vim-rhubarb'
  use 'tpope/vim-dispatch'

  -- aesthetics
  use 'nvim-lualine/lualine.nvim'
  use 'arcticicestudio/nord-vim'
  use "EdenEast/nightfox.nvim"
  use 'scrooloose/nerdtree'
end)
