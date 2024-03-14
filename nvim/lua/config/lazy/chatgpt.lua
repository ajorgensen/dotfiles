return {
    {
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telegram/telescope.nvim",
        },
        config = function()
            require("chatgpt").setup({ })
        end,
    }
}
