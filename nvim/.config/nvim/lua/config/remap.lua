vim.g.mapleader = " "
vim.g.maplocalleader = " " -- Set local leader key to space

vim.g["test#strategy"] = 'neovim' -- Use neovim terminal for test execution
vim.g["test#go#gotest#options"] = "-v" -- Enable verbose output for Go tests

vim.keymap.set('n', '-', ':Oil<CR>')

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>x', ':xit<CR>')

vim.keymap.set('n', '<leader>dag', ':lua vim.diagnostic.setqflist()<CR>')

vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition)
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>dh", vim.lsp.buf.document_highlight, { desc = "Highlight variable" })
vim.keymap.set("n", "<leader>dc", vim.lsp.buf.clear_references, { desc = "Clear highlight" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

--vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>") -- Test nearest test
--vim.keymap.set("n", "<leader>tf", ":TestFile<CR>")    -- Test file
--vim.keymap.set("n", "<leader>ts", ":TestSuite<CR>")   -- Test suite
--vim.keymap.set("n", "<leader>tl", ":TestLast<CR>")    -- Test last test run
--vim.keymap.set("n", "<leader>tv", ":TestVisit<CR>")   -- Test visit

vim.keymap.set("n", "<leader>aa", ":Alternate<CR>", { desc = "Switch to alternate file" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
