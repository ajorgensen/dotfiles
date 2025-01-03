require("supermaven-nvim").setup {
  condition = function()
    return true
  end,
}

vim.keymap.set("n", "<leader>sm", ":SupermavenToggle<CR>", { desc = "Supermaven Toggle" })
