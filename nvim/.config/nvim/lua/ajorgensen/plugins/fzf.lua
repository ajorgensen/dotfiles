local fzf = require('fzf-lua')

fzf.setup({
  winopts = {
    preview = {
      hidden = 'hidden',
    },
  },
  files = {
    previewer = false,
  },
  grep = {
    previewer = false,
  },
  lsp = {
    previewer = false,
  },
})

local keymaps = {
  { '<leader>pf', fzf.files, 'Find files' },
  { '<C-p>', fzf.git_files, 'Git files' },
  { '<leader>pws', fzf.grep_cword, 'Grep word under cursor' },
  { '<leader>pWs', fzf.grep_cWORD, 'Grep WORD under cursor' },
  { '<leader>ps', fzf.live_grep, 'Live grep' },
  { '<leader>vh', fzf.help_tags, 'Help tags' },
  { '<leader>b', fzf.buffers, 'Buffers' },
  { '<leader>ds', fzf.lsp_document_symbols, 'Document symbols' },
  { '<leader>ws', fzf.lsp_live_workspace_symbols, 'Workspace symbols' },
}

for _, keymap in ipairs(keymaps) do
  vim.keymap.set('n', keymap[1], keymap[2], { desc = keymap[3] })
end
