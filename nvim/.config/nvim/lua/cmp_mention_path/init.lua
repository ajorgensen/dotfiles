local cmp = require("cmp")

local source = {}

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
  local cwd = vim.fn.getcwd()
  local items = {}

  local cmd = vim.fn.executable("fd") == 1
      and { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" }
    or { "find", ".", "-type", "f", "-not", "-path", "*/.git/*" }

  vim.fn.jobstart(cmd, {
    cwd = cwd,
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
      callback(items)
    end,
  })
end

return source
