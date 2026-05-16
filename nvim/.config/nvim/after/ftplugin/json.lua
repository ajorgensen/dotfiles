local setlocal = vim.opt_local

setlocal.foldmethod = "expr"
setlocal.foldexpr = "v:lua.vim.treesitter.foldexpr()"
setlocal.foldlevel = 99

setlocal.shiftwidth = 2
setlocal.expandtab = true
