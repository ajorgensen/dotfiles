local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.ensure_installed({
	'tsserver',
	'eslint',
	'sumneko_lua',
	'rust_analyzer',
	'gopls',
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-y>'] = cmp.mapping.confirm({ select = true }),
	['<C-space>'] = cmp.mapping.complete(),
})

lsp.setup_nvim_cmp({
	mapping = cmp_mappings
})

lsp.on_attach(function(_, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set("n", "<leader>vii", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "<leader>fo", function() vim.lsp.buf.format() end, opts)
	vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        -- formatting
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.stylua,

        -- diagnostics
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.write_good,

        -- code actions
        null_ls.builtins.code_actions.eslint_d,
        require("typescript.extensions.null-ls.code-actions"),
    },
})

local mason_nullls = require("mason-null-ls")
mason_nullls.setup({
  automatic_installation = true,
  automatic_setup = true,
  ensure_installed = { 'goimports', 'eslint_d', 'prettierd' },
})
mason_nullls.setup_handlers({})