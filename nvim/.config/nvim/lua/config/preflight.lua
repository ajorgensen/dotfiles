local function check_for_existing_instance()
  local current_dir = vim.fn.getcwd()
  local lock_file = current_dir .. "/.nvim.lock"

  -- Check if lock file exists
  if vim.fn.filereadable(lock_file) == 1 then
    -- Read process ID from lock file
    local pid = vim.fn.readfile(lock_file)[1]

    -- Check if process is still running
    local is_running = vim.fn.system("ps -p " .. pid .. " > /dev/null 2>&1 && echo 'running' || echo 'not running'")

    if vim.trim(is_running) == "running" then
      local choice = vim.fn.confirm(
        "Another Neovim instance (PID: " .. pid .. ") is already running for this project.\n" ..
        "Would you like to continue anyway?",
        "&Yes\n&No",
        2
      )

      if choice == 2 then -- No
        vim.cmd("quit")
        return
      end
    else
      -- Process not running, clean up stale lock file
      vim.fn.delete(lock_file)
    end
  end

  -- Create lock file with current PID
  vim.fn.writefile({ tostring(vim.fn.getpid()) }, lock_file)

  -- Ensure lock file is removed when Neovim exits
  vim.api.nvim_create_autocmd("VimLeave", {
    pattern = "*",
    callback = function()
      vim.fn.delete(lock_file)
    end
  })
end

-- Run the check when Neovim starts
check_for_existing_instance()
