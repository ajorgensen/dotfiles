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
    extensions = {
        command_palette = {
            { "File",
                { "entire selection (C-a)",  ':call feedkeys("GVgg")' },
                { "save current file (C-s)", ':w' },
                { "save all files (C-A-s)",  ':wa' },
                { "quit (C-q)",              ':qa' },
                { "file browser (C-i)",      ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
                { "search word (A-w)",       ":lua require('telescope.builtin').live_grep()",                  1 },
                { "git files (A-f)",         ":lua require('telescope.builtin').git_files()",                  1 },
                { "files (C-f)",             ":lua require('telescope.builtin').find_files()",                 1 },
            },
            { "Help",
                { "tips",            ":help tips" },
                { "cheatsheet",      ":help index" },
                { "tutorial",        ":help tutor" },
                { "summary",         ":help summary" },
                { "quick reference", ":help quickref" },
                { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
            },
            { "Vim",
                { "reload vimrc",              ":source $MYVIMRC" },
                { 'check health',              ":checkhealth" },
                { "jumps (Alt-j)",             ":lua require('telescope.builtin').jumplist()" },
                { "commands",                  ":lua require('telescope.builtin').commands()" },
                { "command history",           ":lua require('telescope.builtin').command_history()" },
                { "registers (A-e)",           ":lua require('telescope.builtin').registers()" },
                { "colorshceme",               ":lua require('telescope.builtin').colorscheme()",    1 },
                { "vim options",               ":lua require('telescope.builtin').vim_options()" },
                { "keymaps",                   ":lua require('telescope.builtin').keymaps()" },
                { "buffers",                   ":Telescope buffers" },
                { "search history (C-h)",      ":lua require('telescope.builtin').search_history()" },
                { "paste mode",                ':set paste!' },
                { 'cursor line',               ':set cursorline!' },
                { 'cursor column',             ':set cursorcolumn!' },
                { "spell checker",             ':set spell!' },
                { "relative number",           ':set relativenumber!' },
                { "search highlighting (F12)", ':set hlsearch!' },
            }
        }
    }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function() builtin.find_files({ hidden = true }) end, {})
vim.keymap.set('n', '<leader>fm', function() builtin.marks() end, {})
vim.keymap.set('n', '<leader>fb', function() builtin.buffers() end, {})
vim.keymap.set('n', 'C-p', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>pg', function() builtin.live_grep() end, {})
vim.keymap.set('n', '<leader>sm', ":Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })

require('telescope').load_extension('command_palette')
