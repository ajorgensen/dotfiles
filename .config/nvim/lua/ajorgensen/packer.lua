return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'arcticicestudio/nord-vim'

  use { "junegunn/fzf", run = ":call fzf#install()" }
  use "junegunn/fzf.vim"

  use "kyoh86/vim-ripgrep"

  -- language support
  use 'ray-x/go.nvim'
  use 'ray-x/guihua.lua' -- recommanded if need floating window support

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  use 'neovim/nvim-lspconfig'

  -- tpope
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'tpope/vim-projectionist'
  use 'tpope/vim-rhubarb'
  use 'tpope/vim-dispatch'
end)
