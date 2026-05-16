local M = {}

local format_group = vim.api.nvim_create_augroup('aj-format-on-save', { clear = true })

local function has_formatter(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method('textDocument/formatting') then
      return true
    end
  end

  return false
end

function M.format(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  opts = opts or {}

  if not has_formatter(bufnr) then
    return
  end

  vim.lsp.buf.format(vim.tbl_extend('force', {
    bufnr = bufnr,
    timeout_ms = 5000,
  }, opts))
end

vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_group,
  callback = function(event)
    M.format(event.buf)
  end,
})

return M
