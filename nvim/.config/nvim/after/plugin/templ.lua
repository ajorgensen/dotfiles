local autocmd = vim.api.nvim_create_autocmd

autocmd('BufRead', {
    pattern = "*.templ",
    command = "set filetype=templ"

})

autocmd('BufNewFile', {
    pattern = "*.templ",
    command = "set filetype=templ"

})
