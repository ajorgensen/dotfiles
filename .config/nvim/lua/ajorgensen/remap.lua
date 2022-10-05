local nnoremap = require("ajorgensen.keymap").nnoremap

nnoremap("<leader>pv", "<cmd>Ex<CR>")
nnoremap("<leader>sz", "<cmd>source $MYVIMRC<CR>")

-- Move around splits with <c-hjkl>
nnoremap("<c-j>", "<c-w>j")
nnoremap("<c-k>", "<c-w>k")
nnoremap("<c-h>", "<c-w>h")
nnoremap("<c-l>", "<c-w>l")

-- FZF
--vim.g.fzf_layout = { down = '40%' }
--nnoremap("<leader>f", ":FZF<cr>")
--nnoremap("<leader>p", ":GFiles<cr>")

-- Telescope
nnoremap("<leader>ff", "<cmd>Telescope find_files<cr>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<cr>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>")
nnoremap("<leader>fh", "<cmd>Telescope help_tags<cr>")

-- NERDTree
nnoremap("<leader>ft", "<cmd>NERDTreeToggle<cr>")
