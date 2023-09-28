vim.o.termguicolors = true

local theme = "base16-" .. os.getenv("BASE16_THEME") or "catppuccin"
vim.cmd("colorscheme " .. theme)
