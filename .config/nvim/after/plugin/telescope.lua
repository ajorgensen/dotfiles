require('telescope').setup({
    defaults = {
        file_ignore_patterns = { "^.git/", "^node_modules/", "^vendor/" },
    }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function() builtin.find_files({hidden = true}) end, {})
vim.keymap.set('n', 'C-p', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)