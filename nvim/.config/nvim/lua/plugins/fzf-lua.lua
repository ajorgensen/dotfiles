return {
    'ibhagwan/fzf-lua',

    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
        require('fzf-lua').setup({
            winopts = {
                preview = {
                    hidden = true,
                },
            },
        })

        local fzf = require('fzf-lua')

        vim.keymap.set('n', '<leader>ff', fzf.files, { desc = '[FZF] Find files' })
        vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = '[FZF] Buffers' })
        vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = '[FZF] Live grep' })

        -- LSP keymaps need corresponding LSP setup, omitting for brevity --
        vim.keymap.set('n', '<leader>lr', fzf.lsp_references, { desc = '[FZF] LSP References' })
        vim.keymap.set('n', '<leader>lds', fzf.lsp_document_symbols, { desc = '[FZF] LSP Document Symbols' })
        vim.keymap.set('n', '<leader>lws', fzf.lsp_live_workspace_symbols, { desc = '[FZF] LSP Workspace Symbols' })

        vim.keymap.set('n', '<C-p>', fzf.git_files, { desc = '[FZF] Git Files' })

        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand('<cword>')
            fzf.grep({ query = word })
        end, { desc = '[FZF] Grep current word' })

        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand('<cWORD>')
            fzf.grep({ query = word })
        end, { desc = '[FZF] Grep current WORD' })

        vim.keymap.set('n', '<leader>ps', function()
            local query = vim.fn.input('Grep > ')
            fzf.grep({ query = query })
        end, { desc = '[FZF] Grep with input' })

        vim.keymap.set('n', '<leader>vh', fzf.help_tags, { desc = '[FZF] Help tags' })
    end
}
