--
-- Options
--
local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "
opt.tabstop = 4
opt.shiftwidth = 4
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

--
-- Keymaps
--
local opts = { silent = true }
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit all" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and Quit file" })
map("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close buffer" })

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
map("n", "<leader>qf", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("n", "<leader>h", vim.lsp.buf.document_highlight, { desc = "Highlight variable" })
map("n", "<leader>ch", vim.lsp.buf.clear_references, { desc = "Clear highlight" })

map("t", "<esc><esc>", "<c-\\><c-n>")
map("n", ",st", function()
  vim.cmd.new()
  vim.cmd.wincmd "J"
  vim.api.nvim_win_set_height(0, 12)
  vim.wo.winfixheight = true
  vim.cmd.term()
end)

--
-- Autocmds
--
local augroup = vim.api.nvim_create_augroup("ajorgensen.cfg", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePre", {
  pattern = "*",
  group = augroup,
  callback = function()
    vim.lsp.buf.format()
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

autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    vim.lsp.buf.format()
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.templ",
  command = "set filetype=templ",
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

--
-- Plugins
--


local function setup_fzf()
  local fzf = require('fzf-lua')

  map('n', '<leader>ff', fzf.files, { desc = '[FZF] Find files' })
  map('n', '<leader>fb', fzf.buffers, { desc = '[FZF] Buffers' })
  map('n', '<leader>fg', fzf.live_grep, { desc = '[FZF] Live grep' })

  -- LSP keymaps need corresponding LSP setup, omitting for brevity --
  map('n', '<leader>lR', fzf.lsp_references, { desc = '[FZF] LSP References' })
  map('n', '<leader>lds', fzf.lsp_document_symbols, { desc = '[FZF] LSP Document Symbols' })
  map('n', '<leader>lws', fzf.lsp_live_workspace_symbols, { desc = '[FZF] LSP Workspace Symbols' })

  map('n', '<C-p>', fzf.git_files, { desc = '[FZF] Git Files' })

  map('n', '<leader>pws', function()
    local word = vim.fn.expand('<cword>')
    fzf.grep({ query = word })
  end, { desc = '[FZF] Grep current word' })

  map('n', '<leader>pWs', function()
    local word = vim.fn.expand('<cWORD>')
    fzf.grep({ query = word })
  end, { desc = '[FZF] Grep current WORD' })

  map('n', '<leader>ps', function()
    local query = vim.fn.input('Grep > ')
    fzf.grep({ query = query })
  end, { desc = '[FZF] Grep with input' })

  map('n', '<leader>vh', fzf.help_tags, { desc = '[FZF] Help tags' })

  -- Add this after your existing keymaps (around line 44)

  -- Git status: shows staged and unstaged files
  map('n', '<leader>gs', fzf.git_status, { desc = '[FZF] Git status (staged/unstaged)' })

  -- Files changed between current branch and main
  map('n', '<leader>gD', function()
    fzf.fzf_exec('git diff --name-only main...HEAD', {
      prompt = 'Changed vs main > ',
      actions = {
        ['default'] = function(selected)
          vim.cmd('edit ' .. selected[1])
        end,
        ['ctrl-v'] = function(selected)
          vim.cmd('vsplit ' .. selected[1])
        end,
        ['ctrl-s'] = function(selected)
          vim.cmd('split ' .. selected[1])
        end,
      }
    })
  end, { desc = '[FZF] Files changed vs main branch' })

  map('n', '<leader>gc', function()
    fzf.git_diff_tree({ range = 'main..HEAD' })
  end, { desc = '[FZF] Git diff vs main branch (interactive)' })

  fzf.setup({
    "max-perf",
    winopts = {
      preview = {
        hidden = true,
      },
    },
  })
end

local function setup_oil()
  require("oil").setup {
    columns = { "icon" },
    keymaps = {
      ["<C-h>"] = false,
      ["<M-h>"] = "actions.select_split",
    },
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
      natural_order = true,
    },
    win_options = {
      wrap = true,
    },
  }

  -- Open parent directory in current window
  map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

  -- Open parent directory in floating window
  map("n", "<space>-", require("oil").toggle_float)
end

local function setup_treesitter()
  local nts = require("nvim-treesitter").setup({
    ensure_installed = {
      "bash",
      "c",
      "dockerfile",
      "fish",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "gosum",
      "html",
      "javascript",
      "json",
      "lua",
      "make",
      "markdown",
      "python",
      "rust",
      "sql",
      "toml",
      "tsx",
      "typescript",
      "typst",
      "vim",
      "yaml",
      "zig",
    },
  })

  autocmd("PackChanged", { -- update treesitter parsers/queries with plugin updates
    group = augroup,
    callback = function(args)
      print("pack changed")
      local spec = args.data.spec
      if spec and spec.name == "nvim-treesitter" and args.data.kind == "update" then
        vim.schedule(function()
          nts.update()
        end)
      end
    end,
  })

  autocmd("FileType", { -- enable treesitter highlighting and indents
    group = augroup,
    callback = function(args)
      local filetype = args.match
      local lang = vim.treesitter.language.get_lang(filetype)
      if vim.treesitter.language.add(lang) then
        if vim.treesitter.query.get(filetype, "indents") then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        vim.treesitter.start()
      end
    end,
  })

  require("treesitter-context").setup({
    max_lines = 3,
    multiline_threshold = 1,
    separator = "-",
    min_window_height = 20,
    line_numbers = true,
  })
end

local function setup_lsp()
  local cfg = vim.lsp.enable
  cfg("gopls")
  cfg("ts_ls")
  cfg("lua_ls")
  cfg("html")
  cfg("cssls")

  autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client:supports_method("textDocument/implementation") then
        local bufopts = { noremap = true, silent = true, buffer = args.buf }
        map("i", "<C-k>", vim.lsp.completion.get, bufopts) -- open completion menu manually

        map("n", "gd", vim.lsp.buf.definition, bufopts)
        map("n", "gt", vim.lsp.buf.type_definition, bufopts)
        map("n", "gi", vim.lsp.buf.implementation, bufopts)
        map("n", "K", vim.lsp.buf.hover, bufopts)

        map("n", "<leader>vca", vim.lsp.buf.code_action, bufopts)
        map("n", "<leader>vrr", vim.lsp.buf.references, bufopts)
        map("n", "<leader>vrn", vim.lsp.buf.rename, bufopts)

        map("n", "]d", vim.diagnostic.goto_next, bufopts)
        map("n", "[d", vim.diagnostic.goto_prev, bufopts)

        map("n", "<C-s>", vim.lsp.buf.signature_help, bufopts)
        map("n", "<leader>vmt", vim.lsp.buf.format, bufopts)
      end

      if client:supports_method("textDocument/completion") then
        client.server_capabilities.completionProvider.triggerCharacters = chars
        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      end

      local cmp = require('cmp')
      local cmp_lsp = require('cmp_nvim_lsp')
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities())

      local cmp_select = { behavior = cmp.SelectBehavior.Select }

      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'supermaven' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })

      vim.diagnostic.config({
        -- update_in_insert = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end,
  })
end

vim.pack.add({
  "https://github.com/rose-pine/neovim",

  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-web-devicons",

  "https://github.com/stevearc/oil.nvim",
  "https://github.com/stevearc/conform.nvim",

  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/nvim-treesitter/nvim-treesitter-context",

  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-cmdline",
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saadparwaiz1/cmp_luasnip",
  "https://github.com/rafamadriz/friendly-snippets",

  -- the pope
  "https://github.com/tpope/vim-eunuch",
  "https://github.com/tpope/vim-rhubarb",
  "https://github.com/tpope/vim-surround",
  "https://github.com/tpope/vim-dispatch",
  "https://github.com/tpope/vim-projectionist",
  "https://github.com/tpope/vim-fugitive",

  "https://github.com/vim-test/vim-test",
  "https://github.com/airblade/vim-gitgutter",
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/supermaven-inc/supermaven-nvim",
})
vim.cmd.colorscheme("rose-pine-moon")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

require('nvim-web-devicons').setup({})
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylelua" },
    go = { "gofmt" },
  }
})
require('fidget').setup({
  notification = {
    window = {
      winblend = 0,
    },
  },
})

require("supermaven-nvim").setup {
  callback = function()
    require("supermaven-nvim").setup {
      disable_inline_completion = false,
    }
    map("n", "<leader>sm", ":SupermavenToggle<CR>", { desc = "Supermaven Toggle" })
  end
}

require("luasnip").setup {
  callback = function()
    local ls = require("luasnip")

    -- Load your custom snippets
    require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "~/.config/nvim/snippets" } })

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    ls.filetype_extend("javascript", { "jsdoc" })

    --- TODO: What is expand?
    map({ "i" }, "<C-s>e", function() ls.expand() end, { silent = true })

    map({ "i", "s" }, "<C-s>;", function() ls.jump(1) end, { silent = true })
    map({ "i", "s" }, "<C-s>,", function() ls.jump(-1) end, { silent = true })

    map({ "i", "s" }, "<C-s>c", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true })
  end
}

--
-- vim-test
--
vim.g["test#strategy"] = 'neovim'
vim.g["test#go#gotest#options"] = "-v"

map("n", "<leader>tn", ":TestNearest<CR>") -- Test nearest test
map("n", "<leader>tf", ":TestFile<CR>")    -- Test file
map("n", "<leader>ts", ":TestSuite<CR>")   -- Test suite
map("n", "<leader>tl", ":TestLast<CR>")    -- Test last test run
map("n", "<leader>tv", ":TestVisit<CR>")   -- Test visit

setup_fzf()
setup_oil()
setup_treesitter()
setup_lsp()
