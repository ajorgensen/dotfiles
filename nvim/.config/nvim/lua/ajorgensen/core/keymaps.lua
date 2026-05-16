vim.g.mapleader = ' '
vim.g.maplocalleader = ' ' -- Set local leader key to space

local format = require('ajorgensen.core.format')
local reference_highlight = require('ajorgensen.core.reference_highlight')

vim.g['test#strategy'] = 'neovim' -- Use neovim terminal for test execution
vim.g['test#go#gotest#options'] = '-v' -- Enable verbose output for Go tests

local function yank_relative_file_path(include_line_range)
  local path = vim.fn.expand('%:.')

  if include_line_range then
    local start_line = vim.fn.line('v')
    local end_line = vim.fn.line('.')

    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    if start_line == end_line then
      path = string.format('%s:%d', path, start_line)
    else
      path = string.format('%s:%d-%d', path, start_line, end_line)
    end
  end

  vim.fn.setreg('+', path)
end

local keymaps = {
  { 'n', '<leader>o', ':update<CR> :source<CR>', 'Update and source current file' },
  { 'n', '<leader>w', ':write<CR>', 'Write file' },
  { 'n', '<leader>q', ':quit<CR>', 'Quit window' },
  { 'n', '<leader>x', ':xit<CR>', 'Write and quit' },
  { 'n', '<leader>re', '<cmd>restart<cr>', 'Restart Neovim (:restart)' },
  { 'n', '<leader>yF', ":let @+ = expand('%:p')<CR>", 'Yank full file path' },
  { 'n', '<leader>dag', vim.diagnostic.setqflist, 'Diagnostics to quickfix' },
  { 'n', '<leader>df', vim.diagnostic.open_float, 'Line diagnostics' },
  { 'n', '<leader>cf', function() format.format(0, { async = true }) end, 'Format buffer' },
  { 't', '<esc><esc>', '<c-\\><c-n>', 'Exit terminal mode' },
  { 'n', '<C-h>', '<C-w><C-h>', 'Move focus to the left window' },
  { 'n', '<C-l>', '<C-w><C-l>', 'Move focus to the right window' },
  { 'n', '<C-j>', '<C-w><C-j>', 'Move focus to the lower window' },
  { 'n', '<C-k>', '<C-w><C-k>', 'Move focus to the upper window' },
}

for _, keymap in ipairs(keymaps) do
  vim.keymap.set(keymap[1], keymap[2], keymap[3], { desc = keymap[4] })
end

vim.keymap.set('n', '<leader>yf', function()
  yank_relative_file_path(false)
end, { desc = 'Yank relative file path' })

vim.keymap.set('x', '<leader>yf', function()
  yank_relative_file_path(true)
end, { desc = 'Yank relative file path with line range' })

vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Previous diagnostic' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next diagnostic' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('aj-lsp-keymaps', { clear = true }),
  callback = function(event)
    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = event.buf, desc = desc })
    end

    map('gW', vim.lsp.buf.workspace_symbol, 'Workspace symbol')
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gt', vim.lsp.buf.type_definition, 'Go to type definition')
    map('grh', reference_highlight.highlight, 'Highlight references')
    map('<leader>dh', reference_highlight.highlight, 'Highlight references')
    map('<leader>dc', reference_highlight.clear, 'Clear highlight')
  end,
})

-- Native completion ergonomics. Mirrors the previous nvim-cmp bindings:
--   <C-x><C-o>: trigger completion (LSP omnifunc)
--   <C-y>: confirm currently selected item
--   <C-n>/<C-p>: cycle items when popup is visible (default keys, no-op here)
vim.keymap.set('i', '<C-x><C-o>', '<C-x><C-o>', { desc = 'Trigger LSP completion' })

vim.keymap.set('i', '<C-y>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-y>'
  end
  return '<C-y>'
end, { expr = true, desc = 'Confirm completion' })
