require('gen').setup({
  opts = {
    model = "llama3",
    show_model = true,
    show_prompt = true,
    debug = false,
    display_mode = "split",
    no_auto_close = false
  },
})

vim.keymap.set({ 'n', 'v' }, '<leader>]', ':Gen<CR>')
