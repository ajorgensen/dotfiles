vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g["test#strategy"] = 'neovim'
vim.g["test#go#gotest#options"] = "-v"

vim.o.winborder = "rounded"
vim.o.tabstop = 2
vim.o.cursorcolumn = false
vim.o.ignorecase = true
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.wrap = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.swapfile = false
vim.o.termguicolors = true
local undodir = os.getenv "HOME" .. "/.config/undodir"
vim.fn.mkdir(undodir, "p")
vim.o.undodir = undodir
vim.o.undofile = true
vim.o.incsearch = true
vim.o.signcolumn = "yes"
vim.o.splitbelow = true
vim.o.expandtab = true
vim.o.splitright = true
vim.o.mouse = "a"
vim.o.scrolloff = 10
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.colorcolumn = "80"

local map = vim.keymap.set
map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map('n', '<leader>x', ':xit<CR>')
map('n', '-', ':Oil<CR>')
map('n', '<leader>f', ':FzfLua files<CR>')
map('n', '<leader>h', ':FzfLua helptags<CR>')
map('n', '<leader>lf', vim.lsp.buf.format)
map('n', 'gW', vim.lsp.buf.workspace_symbol)
map('n', 'gd', vim.lsp.buf.definition)
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
map("n", "<leader>dh", vim.lsp.buf.document_highlight, { desc = "Highlight variable" })
map("n", "<leader>dc", vim.lsp.buf.clear_references, { desc = "Clear highlight" })
map("t", "<esc><esc>", "<c-\\><c-n>")

map("n", "<leader>tn", ":TestNearest<CR>") -- Test nearest test
map("n", "<leader>tf", ":TestFile<CR>")    -- Test file
map("n", "<leader>ts", ":TestSuite<CR>")   -- Test suite
map("n", "<leader>tl", ":TestLast<CR>")    -- Test last test run
map("n", "<leader>tv", ":TestVisit<CR>")   -- Test visit

map("i", "<C-s>e", function() require("luasnip").expand_or_jump() end)

vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/vim-test/vim-test" },
  { src = "https://github.com/airblade/vim-gitgutter" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },

  -- tpope
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/tpope/vim-projectionist" },
  { src = "https://github.com/tpope/vim-dispatch" },
  { src = "https://github.com/tpope/vim-rhubarb" },
  { src = "https://github.com/tpope/vim-eunuch" },
})

require 'mason'.setup()
require 'mason-lspconfig'.setup()
require 'oil'.setup()
require 'fzf-lua'.setup()
require 'supermaven-nvim'.setup({})
require 'luasnip'.setup()
require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "~/.config/nvim/snippets" } })
require("luasnip.loaders.from_vscode").lazy_load()

vim.lsp.enable({
  "lua_ls",
  "gopls",
  "tsserver",
  "jsonls",
  "bufls",
})
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      }
    }
  }
})

-- colors
vim.cmd("colorscheme rose-pine-moon")
vim.cmd(":hi statusline guibg=NONE")

local augroup = vim.api.nvim_create_augroup("ajorgensen.cfg", { clear = true })
local autocmd = vim.api.nvim_create_autocmd
autocmd("FileType", {
  group = augroup,
  callback = function(args)
    local filetype = args.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if vim.treesitter.language.add(lang) then
      vim.treesitter.start()
    end
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.txt,*.md,*.tex,*.git/COMMIT_EDITMSG",
  group = augroup,
  callback = function()
    vim.opt_local.spell = true
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.md",
  group = augroup,
  callback = function()
    vim.opt_local.textwidth = 120
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
  end,
})

vim.api.nvim_create_user_command("Browse", function(opts)
  vim.fn.system { "open", opts.fargs[1] }
end, { nargs = 1 })

vim.api.nvim_create_user_command("Cppath", function()
  local path = vim.fn.expand "%:p"
  vim.fn.setreg("+", path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})
