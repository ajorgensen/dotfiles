local keymaps = {
  { '<leader>tn', '<cmd>TestNearest<CR>', 'Test nearest' },
  { '<leader>tf', '<cmd>TestFile<CR>', 'Test file' },
  { '<leader>ts', '<cmd>TestSuite<CR>', 'Test suite' },
  { '<leader>tl', '<cmd>TestLast<CR>', 'Test last' },
  { '<leader>tv', '<cmd>TestVisit<CR>', 'Visit test' },
}

for _, keymap in ipairs(keymaps) do
  vim.keymap.set('n', keymap[1], keymap[2], { desc = keymap[3] })
end
