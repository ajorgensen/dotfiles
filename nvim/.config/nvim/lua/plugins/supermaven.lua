return {
    "supermaven-inc/supermaven-nvim",
    config = function()
        require("supermaven-nvim").setup {
            disable_inline_completion = false,
        }
        vim.keymap.set("n", "<leader>sm", ":SupermavenToggle<CR>", { desc = "Supermaven Toggle" })
    end,
}
