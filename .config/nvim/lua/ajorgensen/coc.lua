local nmap = require("ajorgensen.keymap").nmap
local nnoremap = require("ajorgensen.keymap").nmap

nmap("gd", "<Plug>(coc-definition)")
nmap("gy", "<Plug>(coc-type-definition)")
nmap("gr", "<Plug>(coc-references)")

nmap("[g", "<Plug>(coc-diagnostic-prev)")
nmap("]g", "<Plug>(coc-diagnostic-next)")

nnoremap("<space>s", ":<C-u>CocList -I symbols<cr>")
nnoremap("<space>d", ":<C-u>CocList diagnostics<cr>")

nmap("<leader>do", "<Plug>(coc-codeaction)")
nmap("<leader>rn", "<Plug>(coc-rename)")

vim.g.coc_global_extensions = {
  'coc-tsserver',
  'coc-json',
  'coc-css',
  'coc-eslint',
  'coc-prettier',
  'coc-go',
}
