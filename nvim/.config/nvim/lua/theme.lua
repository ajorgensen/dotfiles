require("dracula").setup {
  overrides = {
    DiffAdd = { bg = "#2d4739" },
    DiffDelete = { bg = "#492f3a" },
    DiffChange = { bg = "#3b3d4f" },
    DiffText = { bg = "#4d4f68", bold = true },
  },
}

vim.cmd "colorscheme dracula"
