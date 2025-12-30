-----------------------
--- Bootstrap lazy.nvim
-----------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------
--- Options
-----------
local undodir = os.getenv "HOME" .. "/.config/undodir"
vim.fn.mkdir(undodir, "p")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g["test#strategy"] = 'neovim'
vim.g["test#go#gotest#options"] = "-v"

vim.o.hlsearch = true       -- Highlight search results
vim.o.ignorecase = true     -- Ignore case in searches
vim.o.incsearch = true      -- Incremental search

vim.o.expandtab = true      -- Insert spaces when <TAB> is pressed
vim.o.tabstop = 2           -- Number of spaces tabs count for
vim.o.shiftwidth = 2        -- Number of spaces inserted for each indentation
vim.o.softtabstop = 2       -- Number of spaces in a tab when editing

vim.o.number = true         -- Show line numbers
vim.o.relativenumber = true -- Show relative line numbers

vim.o.winborder = "rounded"

vim.o.cursorcolumn = false -- Highlight the column of the cursor
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.wrap = false
vim.o.swapfile = false
vim.o.termguicolors = true

vim.o.undodir = undodir
vim.o.undofile = true
vim.o.signcolumn = "yes"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.mouse = "a"
vim.o.scrolloff = 10
vim.o.colorcolumn = "80"

--------------
--- AUTOCMDS
--------------
local augroup = vim.api.nvim_create_augroup("ajorgensen.cfg", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd("LspAttach", {
  group = augroup,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    vim.api.nvim_buf_set_option(args.buf, "omnifunc", "v:lua.vim.lsp.omnifunc")

    if client ~= nil and client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = args.buf })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end
  end,
})

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

vim.api.nvim_create_user_command("LspClients", function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify("No LSP clients attached")
    return
  end

  local client_info = {}
  for _, client in ipairs(clients) do
    table.insert(client_info, string.format("- %s (id: %d)", client.name, client.id))
  end

  vim.notify("Active LSP clients:\n" .. table.concat(client_info, "\n"))
end, {})

vim.api.nvim_create_user_command("InspectCompletion", function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/completion', params, function(err, result, ctx)
    if err then
      vim.notify("Error: " .. vim.inspect(err))
      return
    end

    if not result or not result.items then
      vim.notify("No completion items found")
      return
    end

    -- Show detailed info about first few completions
    local info = {}
    for i, item in ipairs(result.items) do
      if i > 5 then break end -- Limit to first 5 items
      table.insert(info, string.format(
        "Item %d:\n  label: %s\n  detail: %s\n  kind: %s\n  labelDetails: %s",
        i,
        item.label or "nil",
        item.detail or "nil",
        item.kind or "nil",
        vim.inspect(item.labelDetails or {})
      ))
    end

    vim.notify("Completion details:\n" .. table.concat(info, "\n\n"))
  end)
end, {})

-------------
--- PLUGINS
-------------
require("lazy").setup({
  { "rose-pine/neovim" },
  { "michaeljsmith/vim-indent-object" },

  -- TPOPE
  { "tpope/vim-fugitive" },
  { "tpope/vim-projectionist" },
  { "tpope/vim-dispatch" },
  { "tpope/vim-rhubarb" },
  { "tpope/vim-eunuch" },

  {
    "ibhagwan/fzf-lua",
    opts = {
      winopts = {
        preview = {
          hidden = true,
        }
      }
    },
  },

  {
    "stevearc/oil.nvim",
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    lazy = false,
    keys = {},
    opts = {
      --use_default_keymaps = false,
      keymaps = {
        -- TODO
      },
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git'
        end,
      },
      win_options = {
        wrap = true,
      }
    },
  },

  { "folke/trouble.nvim" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-moon")
    end
  },

  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "rust_analyzer", "gopls" },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require 'nvim-treesitter.configs'.setup {
        indent = { enable = true },
        ensure_installed = {
          "lua",
          "go",
          "typescript",
          "json",
          "templ",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        }
      }
    end
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require 'treesitter-context'.setup {
        enable = true,
        line_numbers = true,
        max_lines = 5,
        min_window_height = 0,
        mode = 'cursor',
        multiline_threshold = 20,
        on_attach = nil,
        separator = "-",
        trim_scope = "outer",
        zindex = 20,
      }
    end
  },

  -- SNIPPETS
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require 'luasnip'.setup()
      require 'luasnip.loaders.from_snipmate'.lazy_load({ paths = { "~/.config/nvim/snippets" } })
      require 'luasnip.loaders.from_vscode'.lazy_load()
    end
  },

  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        -- Use `:help formatters` to see a list of builtin formatters
        formatters_by_ft = {
          python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
          terraform = { "tofu_fmt" },
        },
        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        },
      })
    end,
  },

  {
    "stevearc/aerial.nvim",
    keys = {
      { "<leader>a", function() require("telescope").extensions.aerial.aerial() end }
    },
    config = function()
      -- Go to symbol in current file
      require("aerial").setup({
        -- Was using the default, but it seemed to be slow to come up on some Python
        -- files with many functions. Trying this to see if using only the treesitter
        -- backend is faster.
        backends = { "treesitter" },
      })
    end
  },

  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        nerd_font_variant = 'mono'
      },

      signature = { enabled = true },
    },
    opts_extend = { "sources.default" }
  },

  {
    "neovim/nvim-lspconfig",
  },

  { "vim-test/vim-test" },
  { "airblade/vim-gitgutter" },

  -- AI
  { "nvim-lua/plenary.nvim" },
  { "mbbill/undotree" },
  {
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
      })
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'tokyonight',
        },
      }
    end
  }

})

require("alternate").setup()

-------------
--- KEYBINDINGS
-------------

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>x', ':xit<CR>')
vim.keymap.set('n', '-', ':Oil<CR>')
vim.keymap.set('n', '<leader>f', ':FzfLua files<CR>')
vim.keymap.set('n', '<leader>b', ':FzfLua buffers<CR>')
vim.keymap.set('n', '<leader>g', ':FzfLua live_grep<CR>')
vim.keymap.set('n', '<leader>h', ':FzfLua helptags<CR>')
vim.keymap.set('n', '<leader>ds', ':FzfLua lsp_document_symbols<CR>')
vim.keymap.set('n', '<leader>ws', ':FzfLua lsp_live_workspace_symbols<CR>')
vim.keymap.set('n', '<leader>dag', ':lua vim.diagnostic.setqflist()<CR>')
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition)
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>dh", vim.lsp.buf.document_highlight, { desc = "Highlight variable" })
vim.keymap.set("n", "<leader>dc", vim.lsp.buf.clear_references, { desc = "Clear highlight" })
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")
vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>") -- Test nearest test
vim.keymap.set("n", "<leader>tf", ":TestFile<CR>")    -- Test file
vim.keymap.set("n", "<leader>ts", ":TestSuite<CR>")   -- Test suite
vim.keymap.set("n", "<leader>tl", ":TestLast<CR>")    -- Test last test run
vim.keymap.set("n", "<leader>tv", ":TestVisit<CR>")   -- Test visit
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set({ "i", "s" }, "<C-s>e", function()
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  end
end)
vim.keymap.set("n", "<leader>aa", ":Alternate<CR>", { desc = "Switch to alternate file" })
