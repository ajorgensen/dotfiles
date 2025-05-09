require("telescope").setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
}
require("telescope").load_extension "fzf"

local builtin = require "telescope.builtin"

-- Find things
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Telescope marks" })

vim.keymap.set("n", "<leader>lr", builtin.lsp_references, { desc = "LSP References" })
vim.keymap.set("n", "<leader>ld", builtin.lsp_document_symbols, { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>lw", builtin.lsp_workspace_symbols, { desc = "LSP workspace symbols" })
vim.keymap.set("n", "<leader>ldw", builtin.lsp_dynamic_workspace_symbols, { desc = "LSP dynamic workspace symbols" })
vim.keymap.set("n", "<leader>jd", builtin.lsp_definitions, { desc = "LSP Jump to Definition" })
