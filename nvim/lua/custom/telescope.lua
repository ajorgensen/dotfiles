require("telescope").setup({
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
})

pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "smart_history")
pcall(require("telescope").load_extension, "live_grep_args")
pcall(require("telescope").load_extension, "harpoon")

local builtin = require("telescope.builtin")
local extensions = require("telescope").extensions

vim.keymap.set("n", "<leader>ff", function()
  builtin.find_files({ hidden = true })
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
vim.keymap.set("n", "C-p", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set("n", "<leader>sm", ":Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })
