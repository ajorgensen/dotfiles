vim.api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    { pattern = { "*.txt", "*.md", "*.tex", ".git/COMMIT_EDITMSG" }, command = "setlocal spell" }
)

