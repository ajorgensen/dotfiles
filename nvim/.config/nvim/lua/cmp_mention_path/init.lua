local cmp = require("cmp")
local uv = vim.uv

local source = {}
local cache = {}
local pending = {}
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

local function project_root()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
  local root = vim.fs.root(start, {
    ".git",
    "package.json",
    "go.mod",
    "Cargo.toml",
    "pyproject.toml",
    "Makefile",
  })

  return root or vim.fn.getcwd()
end

source.new = function()
  return setmetatable({}, { __index = source })
end

function source:is_available()
  return vim.bo.filetype == "markdown"
end

function source:get_debug_name()
  return "mention_path"
end

function source:get_keyword_pattern()
  return [=[\%(@\)\@<=[^[:space:]]*]=]
end

function source:get_trigger_characters()
  return { "@" }
end

function source:complete(_, callback)
  local root = project_root()
  local now = uv.hrtime()
  local cached = cache[root]

  if cached and (now - cached.updated_at) < cache_ttl_ns then
    callback(vim.deepcopy(cached.items))
    return
  end

  if pending[root] then
    table.insert(pending[root], callback)
    return
  end

  local items = {}
  pending[root] = { callback }

  local cmd
  if vim.fn.executable("fd") == 1 then
    cmd = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden" }
    for _, dir in ipairs(ignored_dirs) do
      table.insert(cmd, "--exclude")
      table.insert(cmd, dir)
    end
  else
    cmd = { "find", "." }
    for _, dir in ipairs(ignored_dirs) do
      table.insert(cmd, "(")
      table.insert(cmd, "-name")
      table.insert(cmd, dir)
      table.insert(cmd, "-type")
      table.insert(cmd, "d")
      table.insert(cmd, "-prune")
      table.insert(cmd, ")")
      table.insert(cmd, "-o")
    end
    table.insert(cmd, "-type")
    table.insert(cmd, "f")
    table.insert(cmd, "-print")
  end

  vim.fn.jobstart(cmd, {
    cwd = root,
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, path in ipairs(data) do
        if path and #path > 0 then
          path = path:gsub("^%./", "")
          table.insert(items, {
            label = path,
            kind = cmp.lsp.CompletionItemKind.File,
            sortText = path,
          })
        end
      end
    end,
    on_exit = function()
      cache[root] = {
        items = items,
        updated_at = uv.hrtime(),
      }

      for _, pending_callback in ipairs(pending[root] or {}) do
        pending_callback(vim.deepcopy(items))
      end

      pending[root] = nil
    end,
  })
end

return source
