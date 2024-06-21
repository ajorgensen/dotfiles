require("telescope").setup {
  defaults = {
    path_display = { "truncate" },
    file_ignore_patterns = { "^.git/", "^node_modules/", "^vendor/" },
  },
  extensions = {
    fzf = {},
    wrap_results = true,
    history = {
      limit = 100,
    },
  },
}

pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "smart_history")
pcall(require("telescope").load_extension, "live_grep_args")
pcall(require("telescope").load_extension, "harpoon")

local easypick = require "easypick"

-- only required for the example to work
local get_default_branch = "git rev-parse --symbolic-full-name refs/remotes/origin/HEAD | sed 's!.*/!!'"
local base_branch = vim.fn.system(get_default_branch) or "origin/main"

easypick.setup {
  pickers = {
    -- add your custom pickers here
    -- below you can find some examples of what those can look like

    -- list files inside current folder with default previewer
    {
      -- name for your custom picker, that can be invoked using :Easypick <name> (supports tab completion)
      name = "ls",
      -- the command to execute, output has to be a list of plain text entries
      command = "ls",
      -- specify your custom previwer, or use one of the easypick.previewers
      previewer = easypick.previewers.default(),
    },

    -- diff current branch with base_branch and show files that changed with respective diffs in preview
    {
      name = "changed_files",
      command = "git diff --name-only $(git merge-base HEAD origin/" .. base_branch .. " )",
      previewer = easypick.previewers.branch_diff { base_branch = base_branch },
    },

    -- list files that have conflicts with diffs in preview
    {
      name = "conflicts",
      command = "git diff --name-only --diff-filter=U --relative",
      previewer = easypick.previewers.file_diff(),
    },
  },
}

local builtin = require "telescope.builtin"
local extensions = require("telescope").extensions

vim.keymap.set("n", "<leader>ff", function()
  builtin.find_files { hidden = true }
end, {})
vim.keymap.set("n", "<leader>fh", function()
  extensions.harpoon.marks()
end, {})
vim.keymap.set("n", "<leader>fm", function()
  builtin.marks()
end, {})
vim.keymap.set("n", "<leader>fb", function()
  builtin.buffers()
end, {})
vim.keymap.set("n", "<leader>fg", function()
  extensions.live_grep_args.live_grep_args()
end, {})

vim.keymap.set("n", "<leader>fds", builtin.lsp_document_symbols)
vim.keymap.set("n", "<leader>fws", builtin.lsp_workspace_symbols)
vim.keymap.set("n", "<leader>fr", builtin.lsp_references)

vim.keymap.set("n", "C-p", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string { search = vim.fn.input "Grep > " }
end)
vim.keymap.set("n", "<leader>sm", ":Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })
vim.keymap.set("n", "<leader>gc", ":Easypick changed_files<CR>", { desc = "Changed Files" })
