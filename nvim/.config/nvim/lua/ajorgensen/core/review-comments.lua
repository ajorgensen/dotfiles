-- Inline review markers for the :ReviewChanges / address-ai workflow.
-- AI markers are user directives; AGENT markers are agent replies.

local ai_pattern = [[\bAI(\(\w+\))?:]]
local agent_pattern = [[\bAGENT(\(\w+\))?:]]

local function insert_marker(marker)
  local commentstring = vim.bo.commentstring
  if not commentstring:find "%%s" then
    vim.notify("No comment syntax for this filetype", vim.log.levels.ERROR)
    return
  end

  local prefix, suffix = commentstring:match "^(.-)%%s(.*)$"
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local indent = vim.api.nvim_get_current_line():match "^%s*"
  local head = indent .. prefix .. marker .. " "

  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, { head .. suffix })
  vim.api.nvim_win_set_cursor(0, { lnum, #head })

  if suffix == "" then
    vim.cmd "startinsert!"
  else
    vim.cmd "startinsert"
  end
end

local marker_keymaps = {
  { "<leader>ai", "AI:", "Insert AI marker" },
  { "<leader>ar", "AI(review):", "Insert AI(review) marker" },
  { "<leader>aa", "AI(ask):", "Insert AI(ask) marker" },
  { "<leader>am", "AI(impl):", "Insert AI(impl) marker" },
}

for _, keymap in ipairs(marker_keymaps) do
  vim.keymap.set("n", keymap[1], function()
    insert_marker(keymap[2])
  end, { desc = keymap[3] })
end

local function markers_to_quickfix(pattern, title)
  local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local command = { "rg", "--vimgrep", "--hidden", "--glob", "!.git", pattern, root }
  local result = vim.system(command, { text = true }):wait()

  if result.code == 1 then
    vim.notify("No " .. title .. " found")
    return
  elseif result.code ~= 0 then
    local message = vim.trim(result.stderr or "")
    vim.notify(message ~= "" and message or "rg failed", vim.log.levels.ERROR)
    return
  end

  vim.fn.setqflist({}, " ", {
    title = title,
    lines = vim.split(result.stdout, "\n", { trimempty = true }),
    efm = "%f:%l:%c:%m",
  })
  vim.cmd "copen"
end

vim.api.nvim_create_user_command("AIMarkers", function()
  markers_to_quickfix(ai_pattern, "AI markers")
end, { desc = "List AI markers in quickfix" })

vim.api.nvim_create_user_command("AgentMarkers", function()
  markers_to_quickfix(agent_pattern, "AGENT markers")
end, { desc = "List AGENT markers in quickfix" })

local function set_marker_highlights()
  vim.api.nvim_set_hl(0, "ReviewMarkerAI", { link = "Todo", default = true })
  vim.api.nvim_set_hl(0, "ReviewMarkerAgent", { link = "DiagnosticInfo", default = true })
end

local function add_window_matches()
  if vim.w.review_marker_matches then
    return
  end

  vim.fn.matchadd("ReviewMarkerAI", [[\v<AI(\(\w+\))?:]])
  vim.fn.matchadd("ReviewMarkerAgent", [[\v<AGENT(\(\w+\))?:]])
  vim.w.review_marker_matches = true
end

local group = vim.api.nvim_create_augroup("aj-review-markers", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_marker_highlights,
})

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  group = group,
  callback = add_window_matches,
})

set_marker_highlights()
add_window_matches()
