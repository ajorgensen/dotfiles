return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    
    fzf.setup({
      winopts = {
        preview = {
          hidden = "hidden", -- disable preview by default
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

    -- File pickers
    vim.keymap.set('n', '<leader>pf', fzf.files, { desc = "Find files" })
    vim.keymap.set('n', '<C-p>', fzf.git_files, { desc = "Git files" })
    
    -- Grep pickers
    vim.keymap.set('n', '<leader>pws', function()
      fzf.grep_cword()
    end, { desc = "Grep word under cursor" })
    
    vim.keymap.set('n', '<leader>pWs', function()
      fzf.grep_cWORD()
    end, { desc = "Grep WORD under cursor" })
    
    vim.keymap.set('n', '<leader>ps', fzf.live_grep, { desc = "Live grep" })
    
    -- Help and buffers
    vim.keymap.set('n', '<leader>vh', fzf.help_tags, { desc = "Help tags" })
    vim.keymap.set('n', '<leader>b', fzf.buffers, { desc = "Buffers" })
    
    -- LSP pickers
    vim.keymap.set('n', '<leader>ds', fzf.lsp_document_symbols, { desc = "Document symbols" })
    vim.keymap.set('n', '<leader>ws', fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
  end
}
