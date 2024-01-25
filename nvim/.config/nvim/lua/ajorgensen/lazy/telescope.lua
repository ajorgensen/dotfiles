return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 
            { 
                'nvim-lua/plenary.nvim',
                'nvim-telescope/telescope-live-grep-args.nvim',
            },
        },
        config = function()
            require('telescope').setup({
                defaults = {
                    path_display = { "truncate" },
                    file_ignore_patterns = { "^.git/", "^node_modules/", "^vendor/" },
                    layout_config = {
                        horizontal = {
                            width = 0.75
                        },
                        cursor = {
                            height = 0.9,
                            preview_cutoff = 100,
                            width = 0.8
                        },
                    },
                },
                extensions = {}
            })

            local builtin = require('telescope.builtin')
            local extensions = require('telescope').extensions
            vim.keymap.set('n', '<leader>ff', function() builtin.find_files({ hidden = true }) end, {})
            vim.keymap.set('n', '<leader>fm', function() builtin.marks() end, {})
            vim.keymap.set('n', '<leader>fb', function() builtin.buffers() end, {})
            vim.keymap.set('n', '<leader>fg', function() extensions.live_grep_args.live_grep_args() end, {})
            vim.keymap.set('n', 'C-p', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
            vim.keymap.set('n', '<leader>sm', ":Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })
        end
    },
}
