return {
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function() 
            vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianBacklinks<CR>", { desc = "Obsidian Backlinks" })
            vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Obsidian New Note" })
            vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { desc = "Obsidian Today" })
            vim.keymap.set("n", "<leader>oy", "<cmd>ObsidianYesterday<CR>", { desc = "Obsidian Yesterday" })
            vim.keymap.set("n", "<leader>or", "<cmd>ObsidianTomorrow<CR>", { desc = "Obsidian Tomorrow" })

            require("obsidian").setup({ 
                workspaces = {
                    {
                        name = "personal",
                        path = "~/vaults/tardis",
                    }
                }
            })
        end
    }
}
