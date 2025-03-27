require("neodev").setup {}

require("mason").setup()
local lspconfig = require "lspconfig"

local ensure_installed = {
  "lua_ls",
  "gopls",
  "ltex",
}

require("mason-lspconfig").setup {
  ensure_installed = ensure_installed,
  automatic_installation = true,
}

-- Define server-specific configurations
local server_configs = {
  gopls = {
    cmd = { "gopls", "serve" },
    settings = {
      gopls = {
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  },

  ltex = {
    settings = {
      ltex = {
        language = "en-US",
        diagnosticSeverity = "information",
        additionalRules = {
          enablePickyRules = true,
          motherTongue = "en-US",
        },
        disabledRules = {},
        hiddenFalsePositives = {},
        dictionary = {
          ["en-US"] = {
            -- Ignore
            "Wheres",
          },
        },
      },
    },
    filetypes = { "markdown", "text", "tex", "latex", "gitcommit" },
  },

  typos_lsp = {
    init_options = {
      diagnosticSeverity = "Hint",
      config = {
        dictionaries = {
          ["*"] = {
            words = {
              -- Ignore
              "Wheres",
            },
          },
        },
      },
    },
  },
}

require("mason-lspconfig").setup_handlers {
  function(server_name)
    if server_configs[server_name] then
      lspconfig[server_name].setup(server_configs[server_name])
    else
      lspconfig[server_name].setup {}
    end
  end,
}

local disable_semantic_tokens = {
  lua = true,
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = args.buffer, remap = false }
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

    vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gf", function()
      vim.lsp.buf.format()
      vim.lsp.buf.code_action { context = { only = { "source.organizeImports" } }, apply = true }
    end, opts)
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover()
    end, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>vmt", vim.lsp.buf.format, opts)

    local filetype = vim.bo[bufnr].filetype
    if disable_semantic_tokens[filetype] then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

-- Autoformatting setup
require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    javascript = { "prettierd", "prettier" },
  },
  format_on_save = {
    lsp_format = "fallback",
  },
}
