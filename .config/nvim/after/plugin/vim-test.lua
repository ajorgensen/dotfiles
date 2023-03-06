vim.g["test#strategy"] = 'dispatch'

vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>") -- Test nearest test
vim.keymap.set("n", "<leader>tf", ":TestFile<CR>") -- Test file
vim.keymap.set("n", "<leader>ts", ":TestSuite<CR>") -- Test suite
vim.keymap.set("n", "<leader>tl", ":TestLast<CR>") -- Test last test run
vim.keymap.set("n", "<leader>tv", ":TestVisit<CR>") -- Test visit
