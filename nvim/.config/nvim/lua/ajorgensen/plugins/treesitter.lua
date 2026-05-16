local treesitter = require('nvim-treesitter')

local languages = {
  'bash',
  'css',
  'go',
  'gomod',
  'gosum',
  'gowork',
  'html',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'query',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

treesitter.setup()
treesitter.install(languages)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('aj-treesitter', { clear = true }),
  pattern = languages,
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
