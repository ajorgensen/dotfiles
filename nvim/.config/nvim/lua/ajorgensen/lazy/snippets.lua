return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
        config = function() 
            require("luasnip.loaders.from_snipmate").lazy_load()

            function OpenSnippetsFile()
                local filepath = "~/.config/nvim/snippets/" .. vim.bo.filetype .. '.snippets'
                vim.api.nvim_command("edit" .. filepath)
            end

            vim.keymap.set("n", "<leader>os", ':lua OpenSnippetsFile()<cr>', opts)
        end
    }
}
