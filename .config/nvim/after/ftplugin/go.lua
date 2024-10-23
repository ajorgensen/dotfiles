vim.opt_local.expandtab = false

vim.keymap.set("n", "<space>td", function()
  require("dap-go").debug_test()
end, { buffer = 0 })

function GoBuildAsync()
  local cmd = "go build ./..."
  local function on_exit(job_id, exit_code, event_type)
    if exit_code ~= 0 then
      vim.fn.setqflist({}, " ", {
        title = "Go Build Errors",
        lines = vim.api.nvim_buf_get_lines(vim.api.nvim_create_buf(false, true), 0, -1, false),
      })
      vim.cmd "copen"
    else
      print "Build successful"
    end
  end
  vim.fn.jobstart(cmd, {
    on_exit = on_exit,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

vim.cmd [[command! GoBuildAsync lua GoBuildAsync()]]

function GoBuildQuickfix()
  local output = vim.fn.system "go build ./..."
  if vim.v.shell_error ~= 0 then
    vim.fn.setqflist({}, " ", {
      title = "Go Build Errors",
      lines = vim.split(output, "\n"),
    })
    vim.cmd "copen"
  else
    print "Build successful"
  end
end

-- You can then call this function with a command like:
vim.cmd [[command! GoBuild lua GoBuildQuickfix()]]
