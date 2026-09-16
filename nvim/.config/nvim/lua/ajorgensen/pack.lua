local plugins = {
  -- Colors
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/mofiqul/dracula.nvim" },

  -- Oil
  { src = "https://github.com/nvim-mini/mini.icons" },
  { src = "https://github.com/stevearc/oil.nvim" },

  -- Fzf Lua
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/ibhagwan/fzf-lua" },

  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },

  -- Markdown
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/folke/zen-mode.nvim" },

  -- LSP
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },

  -- Git
  { src = "https://github.com/airblade/vim-gitgutter" },
  { src = "https://github.com/sindrets/diffview.nvim" },

  -- Tests
  { src = "https://github.com/vim-test/vim-test" },

  -- Tpope
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/tpope/vim-projectionist" },
  { src = "https://github.com/tpope/vim-dispatch" },
  { src = "https://github.com/tpope/vim-rhubarb" },
  { src = "https://github.com/tpope/vim-eunuch" },

  -- Undo tree
  { src = "https://github.com/mbbill/undotree" },
}

local cinder_dir = vim.fn.expand("~/Projects/cinder")
if vim.fn.isdirectory(cinder_dir) == 1 then
  table.insert(plugins, {
    src = cinder_dir,
    name = "cinder.nvim",
  })
end

vim.pack.add(plugins)

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if opts.args ~= "" then
    -- update specific plugin
    local plugins = vim.split(opts.args, "%s+", { triempty = true })
    vim.pack.update(plugins)
  else
    -- update all
    vim.pack.update()
  end
end, { desc = "Update all plugins" })

-- Plugin Setup
require "ajorgensen.plugins.lsp.lspconfig"
require "ajorgensen.plugins.lsp.mason"
require "ajorgensen.plugins.oil"
require "ajorgensen.plugins.fzf"
require "ajorgensen.plugins.treesitter"
require "ajorgensen.plugins.treesitter-context"
require "ajorgensen.plugins.render-markdown"
require "ajorgensen.plugins.zen-mode"
require "ajorgensen.plugins.git-gutter"
require "ajorgensen.plugins.diffview"
require "ajorgensen.plugins.vim-test"
require "ajorgensen.plugins.tpope"
require "ajorgensen.plugins.undotree"
require "ajorgensen.plugins.cinder"

