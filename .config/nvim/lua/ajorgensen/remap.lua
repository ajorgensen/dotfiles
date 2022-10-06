local nnoremap = require("ajorgensen.keymap").nnoremap
local inoremap = require("ajorgensen.keymap").inoremap

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
ShowDocumentation = function()
  if vim.fn.CocAction('hasProvider', 'hover') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.fn.feedkeys('K', 'in')
  end
end

nnoremap("<leader>ff", "<cmd>Telescope find_files hidden=true<cr>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<cr>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>")
nnoremap("<leader>fh", "<cmd>Telescope help_tags<cr>")

nnoremap("K", ShowDocumentation, { silent = true })

-- NERDTree
nnoremap("<leader>ft", "<cmd>NERDTreeToggle<cr>")
