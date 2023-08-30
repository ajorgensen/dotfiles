local builtin = require('telescope.builtin')

vim.keymap.set('n', '<c-p>', function() builtin.find_files({hidden = true}) end, {})
vim.keymap.set('n', '<leader><leader>', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
