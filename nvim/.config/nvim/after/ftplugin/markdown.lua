vim.opt_local.linebreak = true
vim.opt_local.wrap = true

local uv = vim.uv
local cache_ttl_ns = 5 * 1e9
local ignored_dirs = {
  ".git",
  ".next",
  ".turbo",
  ".venv",
  "build",
  "coverage",
  "dist",
  "node_modules",
  "target",
  "vendor",
}
local cache = {}
local mention_path_active = false

local function project_root()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
  return vim.fs.root(start, { ".git", "package.json", "go.mod", "Cargo.toml", "pyproject.toml", "Makefile" })
    or vim.fn.getcwd()
end

local function build_cmd()
  if vim.fn.executable "fd" == 1 then
    local cmd = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden" }
    for _, dir in ipairs(ignored_dirs) do
      table.insert(cmd, "--exclude")
      table.insert(cmd, dir)
    end
    return cmd
  end
  local cmd = { "find", "." }
  for _, dir in ipairs(ignored_dirs) do
    vim.list_extend(cmd, { "(", "-name", dir, "-type", "d", "-prune", ")", "-o" })
  end
  vim.list_extend(cmd, { "-type", "f", "-print" })
  return cmd
end

local function list_files(root, callback)
  local cached = cache[root]
  if cached and (uv.hrtime() - cached.updated_at) < cache_ttl_ns then
    callback(cached.items)
    return
  end

  local items = {}
  vim.fn.jobstart(build_cmd(), {
    cwd = root,
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, path in ipairs(data) do
        if path and #path > 0 then
          path = path:gsub("^%./", "")
          table.insert(items, path)
        end
      end
    end,
    on_exit = function()
      cache[root] = { items = items, updated_at = uv.hrtime() }
      vim.schedule(function()
        callback(items)
      end)
    end,
  })
end

local function complete_mention_path()
  if vim.fn.mode() ~= "i" then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)
  local at_pos = before:find "@[^%s]*$"
  if not at_pos then
    mention_path_active = false
    return
  end

  mention_path_active = true

  list_files(project_root(), function(files)
    -- Re-evaluate the line in case the user kept typing while files loaded.
    local cur_line = vim.api.nvim_get_current_line()
    local cur_col = vim.api.nvim_win_get_cursor(0)[2]
    local cur_before = cur_line:sub(1, cur_col)
    local start = cur_before:find "@[^%s]*$"
    if not start then
      mention_path_active = false
      return
    end
    local query = cur_before:sub(start + 1):lower()
    local matches = {}
    for _, path in ipairs(files) do
      if query == "" or path:lower():find(query, 1, true) then
        table.insert(matches, { word = path, abbr = path, kind = "F", icase = 1 })
      end
    end
    -- complete() expects 1-based column, not counting the leading @.
    vim.fn.complete(start + 1, matches)
  end)
end

vim.api.nvim_create_autocmd("TextChangedI", {
  buffer = 0,
  callback = function()
    if mention_path_active then
      complete_mention_path()
    end
  end,
})

vim.api.nvim_create_autocmd({ "CompleteDone", "InsertLeave" }, {
  buffer = 0,
  callback = function()
    mention_path_active = false
  end,
})

vim.keymap.set("i", "<C-x>@", complete_mention_path, {
  buffer = true,
  desc = "Complete file path (@-mention)",
})

vim.keymap.set("i", "@<C-x>", function()
  vim.schedule(complete_mention_path)
  return "@"
end, {
  buffer = true,
  desc = "Insert @ and complete file path",
  expr = true,
})
