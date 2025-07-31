local augroup = vim.api.nvim_create_augroup("ajorgensen.cfg", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

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
