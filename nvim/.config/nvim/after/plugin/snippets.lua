require("luasnip.loaders.from_snipmate").lazy_load()

function OpenSnippetsFile()
    local filepath = "~/.config/nvim/snippets/" .. vim.bo.filetype .. '.snippets'
    vim.api.nvim_command("edit" .. filepath)
end

vim.keymap.set("n", "<leader>os", ':lua OpenSnippetsFile()<cr>', opts)
