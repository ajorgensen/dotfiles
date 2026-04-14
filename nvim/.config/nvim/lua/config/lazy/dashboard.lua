return {
  "goolord/alpha-nvim",
  cond = function()
    return vim.fn.argc() == 0
  end,
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "                             ",
      "    _/\\__                    ",
      "   (    @\\___                ",
      "   /         O               ",
      "  /   (_____/                ",
      " /_____/   U                 ",
      "                             ",
      "     neovim space cat        ",
    }
    dashboard.section.header.opts.hl = "Type"

    dashboard.section.buttons.val = {
      dashboard.button("e", "new file", "<cmd>ene<cr><cmd>startinsert<cr>"),
      dashboard.button("f", "find files", "<cmd>FzfLua files<cr>"),
      dashboard.button("g", "live grep", "<cmd>FzfLua live_grep<cr>"),
      dashboard.button("r", "recent files", "<cmd>FzfLua oldfiles<cr>"),
      dashboard.button("o", "open file tree", "<cmd>Oil<cr>"),
      dashboard.button("q", "quit", "<cmd>qa<cr>"),
    }
    dashboard.section.buttons.opts.hl = "Statement"
    dashboard.section.buttons.opts.hl_shortcut = "Number"

    dashboard.section.footer.val = {
      os.date("orbit check: %A, %B %d"),
    }
    dashboard.section.footer.opts.hl = "Comment"

    dashboard.config.layout = {
      { type = "padding", val = 4 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.colorcolumn = ""
        vim.opt_local.signcolumn = "no"
        vim.opt_local.cursorline = false
        vim.opt_local.foldenable = false
      end,
    })
  end,
}
