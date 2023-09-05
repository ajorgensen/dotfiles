require('telescope').setup({
    defaults = {
        file_ignore_patterns = { "^.git/", "^node_modules/", "^vendor/" },
    }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function() builtin.find_files({ hidden = true }) end, {})
vim.keymap.set('n', '<leader>fm', function() builtin.marks() end, {})
vim.keymap.set('n', '<leader>fb', function() builtin.buffers() end, {})
vim.keymap.set('n', 'C-p', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>pg', function() builtin.live_grep() end, {})
vim.keymap.set('n', '<leader>sm', ":Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })
