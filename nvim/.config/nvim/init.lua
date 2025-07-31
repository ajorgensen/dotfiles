-- mini setup
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps'
require('mini.deps').setup({ path = { package = path_package } })
local now = MiniDeps.now
local opt = vim.opt

-- Options
now(function()
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "
  opt.tabstop = 4
  opt.shiftwidth = 4
  opt.autoindent = true
  opt.smartindent = true
  opt.inccommand = "split"

  -- Search settings
  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  opt.ignorecase = true
  opt.smartcase = true
  opt.number = true
  opt.relativenumber = true
  opt.splitbelow = true
  opt.splitright = true
  opt.signcolumn = "yes"
  opt.expandtab = true
  opt.mouse = "a"
  opt.showmode = false
  opt.breakindent = true
  local undodir = os.getenv "HOME" .. "/.config/undodir"
  vim.fn.mkdir(undodir, "p")
  opt.undodir = undodir
  opt.undofile = true
  opt.updatetime = 250

  -- Decrease mapped sequence wait time
  -- Displays which-key popup sooner
  opt.timeoutlen = 300

  -- Minimal number of screen lines to keep above and below the cursor.
  opt.scrolloff = 10

  -- Set highlight on search, but clear on pressing <Esc> in normal mode
  opt.hlsearch = true
  opt.incsearch = true

  opt.colorcolumn = "80"
end)

require('keymaps')
require('autocmds')
require('plugins')
