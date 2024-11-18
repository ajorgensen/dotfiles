local group = vim.api.nvim_create_augroup("custom-treesitter", { clear = true })

require("nvim-treesitter.configs").setup {
  ensure_installed = { "python", "cpp", "lua", "vim", "json" },
  ignore_install = {},    -- List of parsers to ignore installing
  highlight = {
    enable = true,        -- false will disable the whole extension
    disable = { "help" }, -- list of language that will be disabled
  },
}

local syntax_on = {}

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    local bufnr = args.buf
    local ft = vim.bo[bufnr].filetype
    pcall(vim.treesitter.start)

    if syntax_on[ft] then
      vim.bo[bufnr].syntax = "on"
    end
  end,
})
