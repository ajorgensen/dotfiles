local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local map = vim.keymap.set
local augroup = vim.api.nvim_create_augroup("ajorgensen.plugins", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

now(function()
  add({
    source = "rose-pine/neovim",
  })

  vim.o.termguicolors = true
  vim.cmd('colorscheme rose-pine-moon')
end)
--now(function()
--  require('mini.notify').setup()
--  vim.notify = require('mini.notify').make_notify()
--end)
now(function()
  add({ source = 'j-hui/fidget.nvim' })
  require('fidget').setup({
    notification = {
      window = {
        winblend = 0,
      },
    },
  })
end)
now(function() require('mini.icons').setup() end)
now(function() require('mini.tabline').setup() end)
now(function() require('mini.statusline').setup() end)

later(function() require('mini.ai').setup() end)
later(function() require('mini.comment').setup() end)
later(function() require('mini.surround').setup() end)

--
-- Fzf
--
now(function()
  add({
    source = "ibhagwan/fzf-lua",
    depends = { "echasnovski/mini.icons" },
  })

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
end)

later(function()
  add({
    source = "stevearc/oil.nvim",
  })

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
)

later(function()
  add({ source = "stevearc/conform.nvim", })
  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylelua" },
      go = { "gofmt" },
    }
  })
end)

later(function() add({ source = 'tpope/vim-fugitive' }) end)
later(function() add({ source = 'tpope/vim-dispatch' }) end)
later(function() add({ source = 'tpope/vim-surround' }) end)
later(function() add({ source = 'tpope/vim-rhubarb' }) end)
later(function() add({ source = 'tpope/vim-eunuch' }) end)
later(function()
  add({ source = 'vim-test/vim-test' })
  vim.g["test#strategy"] = 'neovim'
  vim.g["test#go#gotest#options"] = "-v"

  map("n", "<leader>tn", ":TestNearest<CR>") -- Test nearest test
  map("n", "<leader>tf", ":TestFile<CR>")    -- Test file
  map("n", "<leader>ts", ":TestSuite<CR>")   -- Test suite
  map("n", "<leader>tl", ":TestLast<CR>")    -- Test last test run
  map("n", "<leader>tv", ":TestVisit<CR>")   -- Test visit
end)
later(function() add({ source = 'airblade/vim-gitgutter' }) end)
later(function()
  add({ source = 'supermaven-inc/supermaven-nvim' })

  require("supermaven-nvim").setup {
    disable_inline_completion = false,
  }

  map("n", "<leader>sm", ":SupermavenToggle<CR>", { desc = "Supermaven Toggle" })
end)

now(function()
  add({
    source = 'neovim/nvim-lspconfig',
    depends = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
    },
  })

  require("mason").setup()
  require("mason-lspconfig").setup()
end)

later(function()
  add({
    source = "hrsh7th/nvim-cmp",
    depends = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    }
  })

  local cmp = require("cmp")
  cmp.setup({
    sources = cmp.config.sources(
      {
        { name = 'nvim_lsp' },
        { name = 'supermaven' },
        { name = 'luasnip' },
      },
      {
        { name = 'buffer' },
        { name = 'path' },
      })
  })

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

  autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      autocmd("BufWritePre", {
        pattern = "*",
        group = augroup,
        callback = function()
          vim.lsp.buf.format()
        end,
      })

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
end)

now(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    -- Use 'master' while monitoring updates in 'main'
    checkout = 'master',
    monitor = 'main',
    -- Perform action after every checkout
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
    depends = {
      "nvim-treesitter/nvim-treesitter-context",
    }
  })

  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'dockerfile',
      'fish',
      'git_config',
      'git_rebase',
      'gitattributes',
      'gitcommit',
      'gitignore',
      'go',
      'gomod',
      'gosum',
      'html',
      'javascript',
      'json',
      'lua',
      'make',
      'markdown',
      'python',
      'rust',
      'sql',
      'toml',
      'tsx',
      'typescript',
      'typst',
      'vim',
      'yaml',
      'zig',
      'bash',
      'go',
      'gomod',
      'gosum',
      'lua',
      'vimdoc',
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    auto_install = true,
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
end)

later(function()
  add({
    source = 'yetone/avante.nvim',
    monitor = 'main',
    depends = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'echasnovski/mini.icons'
    },
    hooks = { post_checkout = function() vim.cmd('make BUILD_FROM_SOURCE=true') end }
  })

  require('avante').setup({
    provider = 'claude',
  })
end)
