local async = require "diffview.async"
local diffview = require "diffview"
local diffview_lib = require "diffview.lib"
local diffview_utils = require "diffview.utils"
local RevType = require("diffview.vcs.rev").RevType
local vcs_utils = require "diffview.vcs.utils"

local await = async.await

local function git(cwd, args)
  local command = { "git", "-C", cwd }
  vim.list_extend(command, args)
  return vim.system(command, { text = true }):wait()
end

local function notify_git_error(result, fallback)
  local message = vim.trim(result.stderr or "")
  vim.notify(message ~= "" and message or fallback, vim.log.levels.ERROR)
end

local discard_uncommitted_entry = async.void(function()
  local view = diffview_lib.get_current_view()
  if not view then
    return
  end

  -- Keep Diffview's normal index/worktree restore behavior outside reviews.
  if view.left.type == RevType.STAGE then
    diffview.emit "restore_entry"
    return
  end

  if view.right.type ~= RevType.LOCAL then
    vim.notify("The right side of the diff is not local", vim.log.levels.ERROR)
    return
  end

  local file = view:infer_cur_file()
  if not file then
    return
  end

  local bufnr = diffview_utils.find_file_buffer(file.absolute_path)
  if bufnr and vim.bo[bufnr].modified then
    vim.notify("The file has unsaved changes", vim.log.levels.ERROR)
    return
  end

  local result = git(view.adapter.ctx.toplevel, {
    "--literal-pathspecs",
    "status",
    "--porcelain=v1",
    "-z",
    "--untracked-files=all",
    "--",
    file.path,
  })
  if result.code ~= 0 then
    notify_git_error(result, "Failed to inspect uncommitted changes")
    return
  end

  local status = (result.stdout or ""):sub(1, 2)
  if status == "" then
    vim.notify(("No uncommitted changes for %s"):format(file.path))
    return
  end

  local kind = "working"
  if status ~= "??" and status:sub(1, 1) ~= " " then
    kind = "staged"
  end

  await(vcs_utils.restore_file(view.adapter, file.path, kind))
  view:update_files()
end)

diffview.setup {
  enhanced_diff_hl = true,
  keymaps = {
    file_panel = {
      { "n", "X", discard_uncommitted_entry, { desc = "Discard uncommitted changes" } },
    },
    view = {
      { "n", "X", discard_uncommitted_entry, { desc = "Discard uncommitted changes" } },
    },
  },
}

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

  -- With no revision, diffview shows the working tree and staged changes,
  -- like plain :DiffviewOpen, but still with the review exclusions applied.
  local args = { "-C" .. repo_root }

  if revision then
    table.insert(args, 1, revision)
  end

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

vim.api.nvim_create_user_command("ReviewChanges", function()
  open_review(nil, false)
end, { desc = "Review uncommitted changes" })
