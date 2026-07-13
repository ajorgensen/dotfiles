local diffview = require "diffview"

diffview.setup {
  enhanced_diff_hl = true,
}

local function git(cwd, args)
  local command = { "git", "-C", cwd }
  vim.list_extend(command, args)
  return vim.system(command, { text = true }):wait()
end

local function notify_git_error(result, fallback)
  local message = vim.trim(result.stderr or "")
  vim.notify(message ~= "" and message or fallback, vim.log.levels.ERROR)
end

local function current_repo_root()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  local start_dir = buffer_path ~= "" and vim.fs.dirname(buffer_path) or nil

  if not start_dir or vim.fn.isdirectory(start_dir) == 0 then
    start_dir = vim.fn.getcwd()
  end

  local result = git(start_dir, { "rev-parse", "--show-toplevel" })
  if result.code ~= 0 then
    notify_git_error(result, "Failed to find git repository")
    return
  end

  return vim.trim(result.stdout)
end

local function review_excludes(repo_root)
  local result = git(repo_root, {
    "config",
    "--local",
    "--get-all",
    "diffview.review-exclude",
  })

  if result.code == 1 then
    return {}
  elseif result.code ~= 0 then
    notify_git_error(result, "Failed to read review exclusions")
    return {}
  end

  return vim.split(result.stdout or "", "\n", { trimempty = true })
end

local function open_review(revision, imply_local)
  local repo_root = current_repo_root()
  if not repo_root then
    return
  end

  local args = { revision, "-C" .. repo_root }

  if imply_local then
    table.insert(args, "--imply-local")
  end

  local excludes = review_excludes(repo_root)
  if #excludes > 0 then
    table.insert(args, "--")
    for _, exclude in ipairs(excludes) do
      table.insert(args, ":!" .. exclude)
    end
  end

  diffview.open(args)
end

local function complete_revisions(arg_lead)
  return vim.fn.getcompletion("DiffviewOpen " .. arg_lead, "cmdline")
end

local function create_review_command(name, imply_local, desc)
  vim.api.nvim_create_user_command(name, function(opts)
    local base = opts.args ~= "" and opts.args or "origin/main"
    open_review(("%s...HEAD"):format(base), imply_local)
  end, {
    nargs = "?",
    complete = complete_revisions,
    desc = desc,
  })
end

create_review_command("Review", true, "Review branch and working tree changes")
create_review_command("ReviewBranch", false, "Review committed branch changes")

vim.api.nvim_create_user_command("ReviewLast", function()
  open_review("HEAD^!", false)
end, { desc = "Review the last commit" })

vim.api.nvim_create_user_command("ReviewComments", function()
  vim.api.nvim_cmd({ cmd = "Ggrep", args = { "-w", "REVIEW:" } }, {})
end, { desc = "Find inline review comments" })
