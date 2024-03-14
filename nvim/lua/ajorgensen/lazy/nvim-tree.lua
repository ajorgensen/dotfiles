return {
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            -- disable netrw at the very start of your init.lua
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            -- optionally enable 24-bit colour
            vim.opt.termguicolors = true

            vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "NvimTree Toggle" })
            vim.keymap.set("n", "<leader>nr", "<cmd>NvimTreeRefresh<CR>", { desc = "NvimTree Refresh" })
            vim.keymap.set("n", "<leader>nc", "<cmd>NvimTreeCollapse<CR>", { desc = "NvimTree Collapse" })

            require("nvim-tree").setup({ 
                sync_root_with_cwd = true,
            })
        end,
    }
}
