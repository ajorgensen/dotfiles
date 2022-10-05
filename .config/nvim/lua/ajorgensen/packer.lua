return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'arcticicestudio/nord-vim'

  use { "junegunn/fzf", run = ":call fzf#install()" }
  use "junegunn/fzf.vim"

  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use 'BurntSushi/ripgrep'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  use 'neovim/nvim-lspconfig'

  use 'scrooloose/nerdtree'

  -- languages
  use 'ray-x/go.nvim'
  use 'ray-x/guihua.lua'
  use 'udalov/kotlin-vim'
  use 'zchee/vim-flatbuffers'
  use 'uarun/vim-protobuf'
  use { 'neoclide/coc.nvim', branch = 'release' }
  use 'SirVer/ultisnips'

  -- tpope
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'tpope/vim-projectionist'
  use 'tpope/vim-rhubarb'
  use 'tpope/vim-dispatch'
end)
