--vim.cmd [[autocmd BufRead,BufNewFile *.txt,*.md,*.tex,*.git/COMMIT_EDITMSG :setlocal spell]]
--vim.cmd [[autocmd BufRead,BufNewFile *.md setlocal textwidth=120]]
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

local augroup = vim.api.nvim_create_augroup("ajorgensen", {})
local autocmd = vim.api.nvim_create_autocmd

autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.txt,*.md,*.tex,*.git/COMMIT_EDITMSG',
  group = augroup,
  callback = function()
    vim.opt_local.spell = true
  end,
})

autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.md',
  group = augroup,
  callback = function()
    vim.opt_local.textwidth = 120
  end,
})

autocmd('BufWritePre', {
  group = augroup,
  callback = function()
    vim.lsp.buf.format()
  end,
})

autocmd('BufRead', {
  pattern = "*.templ",
  command = "set filetype=templ"

})

autocmd('BufNewFile', {
  pattern = "*.templ",
  command = "set filetype=templ"

})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
