vim.g.mapleader = ","

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.expandtab = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showmatch = true
vim.opt.syntax = "on"
vim.opt.number = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.cmd[[filetype plugin indent on"]]

-- Highlight the 120th column
vim.cmd[[highlight ColorColumn ctermbg=0 guibg=lightgrey]]
vim.opt.colorcolumn = "120"
