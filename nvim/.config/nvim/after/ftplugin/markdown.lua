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
local max_matches = 200
local mention_path_active = false
local saved_completeopt = nil

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

local function activate()
  if mention_path_active then
    return
  end
  mention_path_active = true
  saved_completeopt = vim.opt_local.completeopt:get()
  -- menuone: show the menu even for a single match; noinsert/noselect: don't
  -- auto-insert while typing; fuzzy: keep Vim's own inter-keystroke filtering
  -- fuzzy instead of strict-prefix, so the menu doesn't vanish on a "typo".
  vim.opt_local.completeopt = { "menuone", "noinsert", "noselect", "fuzzy" }
end

local function deactivate()
  if not mention_path_active then
    return
  end
  mention_path_active = false
  if saved_completeopt then
    vim.opt_local.completeopt = saved_completeopt
    saved_completeopt = nil
  end
end

-- Find the @-token before the cursor. Returns the byte index of "@" and the
-- query typed after it, or nil when the cursor is no longer on a mention.
local function current_mention()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)
  local at_pos = before:find "@[^%s]*$"
  if not at_pos then
    return nil
  end
  return at_pos, before:sub(at_pos + 1)
end

local function fuzzy_matches(files, query)
  if query == "" then
    return files
  end
  local ok, matched = pcall(vim.fn.matchfuzzy, files, query)
  if ok then
    return matched
  end
  return files
end

local function complete_mention_path()
  if vim.fn.mode() ~= "i" then
    return
  end

  local at_pos = current_mention()
  if not at_pos then
    deactivate()
    return
  end

  activate()

  list_files(project_root(), function(files)
    if not mention_path_active or vim.fn.mode() ~= "i" then
      return
    end
    -- Re-evaluate the line in case the user kept typing while files loaded.
    local start, query = current_mention()
    if not start then
      deactivate()
      return
    end
    local items = {}
    for i, path in ipairs(fuzzy_matches(files, query)) do
      if i > max_matches then
        break
      end
      table.insert(items, { word = path, abbr = path, kind = "F", icase = 1 })
    end
    -- complete() expects 1-based column, not counting the leading @.
    vim.fn.complete(start + 1, items)
  end)
end

-- TextChangedP fires while the popup menu is visible, TextChangedI when it
-- isn't (e.g. after Vim closed it because nothing matched). Handling both
-- means the menu comes back as soon as you fix the query.
vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
  buffer = 0,
  callback = function()
    if mention_path_active then
      complete_mention_path()
    end
  end,
})

-- Only stop completing when an item was actually accepted; CompleteDone also
-- fires every time the menu is merely redrawn or closes with no matches.
vim.api.nvim_create_autocmd("CompleteDone", {
  buffer = 0,
  callback = function()
    local item = vim.v.completed_item
    if item and item.word and item.word ~= "" then
      deactivate()
    end
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  buffer = 0,
  callback = deactivate,
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
