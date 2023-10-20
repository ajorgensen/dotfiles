require('harpoon').setup({
    menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
    },
})

vim.keymap.set('n', '<leader>m', ":lua require('harpoon.mark').add_file()<CR>", { noremap = true })
vim.keymap.set('n', '<leader>ht', ":lua require('harpoon.ui').toggle_quick_menu()<CR>", { noremap = true })
