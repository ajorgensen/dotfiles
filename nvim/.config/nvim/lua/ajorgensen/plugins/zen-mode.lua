require('zen-mode').setup({
  window = {
    backdrop = 1,
    width = 100,
    options = {
      number = false,
      relativenumber = false,
      signcolumn = 'no',
      foldcolumn = '0',
      list = false,
      wrap = true,
      linebreak = true,
    },
  },
  on_open = function()
    vim.api.nvim_set_hl(0, 'ZenBg', { link = 'Normal' })
  end,
})
