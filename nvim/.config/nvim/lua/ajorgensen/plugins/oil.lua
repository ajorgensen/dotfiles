require('mini.icons').setup()
require('oil').setup({
  default_file_explorer = true,
})

vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Trigger Oil' })
