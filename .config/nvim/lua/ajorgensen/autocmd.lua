vim.cmd [[autocmd BufRead,BufNewFile *.txt,*.md,*.tex,*.git/COMMIT_EDITMSG :setlocal spell]]
vim.cmd [[autocmd BufRead,BufNewFile *.md setlocal textwidth=120]]
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
