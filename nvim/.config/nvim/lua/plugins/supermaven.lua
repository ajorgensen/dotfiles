return {
    "supermaven-inc/supermaven-nvim",
    config = function()
        require("supermaven-nvim").setup {}
        vim.keymap.set("n", "<leader>sm", ":SupermavenToggle<CR>", { desc = "Supermaven Toggle" })
    end,
}
