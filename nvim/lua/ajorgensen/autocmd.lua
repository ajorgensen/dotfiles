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

autocmd('LspAttach', {
    group = augroup,
    callback = function(e)
        local opts = { buffer = e.buffer, remap = false }

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "gt", function() vim.lsp.buf.type_definition() end, opts)
        vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
        vim.keymap.set("n", "gf", function()
            vim.lsp.buf.format()
            vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
        end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "<leader>vmt", function() vim.lsp.buf.format() end, opts)
    end,
})
