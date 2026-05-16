vim.o.hlsearch = true -- Highlight search results
vim.o.ignorecase = true -- Ignore case in searches
vim.o.incsearch = true -- Incremental search

vim.o.expandtab = true -- Insert spaces when <TAB> is pressed
vim.o.tabstop = 2 -- Number of spaces tabs count for
vim.o.shiftwidth = 2 -- Number of spaces inserted for each indentation
vim.o.softtabstop = 2 -- Number of spaces in a tab when editing
vim.o.smartindent = true -- Enable smart indentation
vim.o.autoindent = true -- Copy indent from current line when starting a new line

vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Show relative line numbers
vim.o.cursorcolumn = false -- Highlight the column of the cursor
vim.o.wrap = false -- Disable line wrapping
vim.o.scrolloff = 10 -- Keep 10 lines visible above/below cursor
vim.o.colorcolumn = "80" -- Show vertical line at column 80
vim.o.signcolumn = "yes" -- Always show the sign column

vim.o.winborder = "single" -- Keep floating windows visually simple
vim.o.splitbelow = true -- Horizontal splits open below
vim.o.splitright = true -- Vertical splits open to the right

vim.o.termguicolors = true -- Enable 24-bit RGB colors in the terminal
vim.opt.guicursor = "" -- Disable cursor style changes

vim.o.swapfile = true -- Keep crash recovery available
vim.o.updatetime = 250 -- Responsive CursorHold without excessive churn

local undodir = os.getenv "HOME" .. "/.config/undodir"
vim.fn.mkdir(undodir, "p")
vim.o.undodir = undodir -- Set directory for undo files
vim.o.undofile = true -- Enable persistent undo

vim.o.mouse = "a" -- Enable mouse support in all modes

vim.o.completeopt = "menuone,noselect,popup" -- Native LSP completion UX

vim.filetype.add {
  extension = {
    fbs = "fbs",
    templ = "templ",
  },
}
