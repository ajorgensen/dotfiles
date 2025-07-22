local set = vim.keymap.set

set("n", "<Esc>", "<cmd>nohlsearch<CR>")

set("n", "<leader>lr", "<cmd>LspRestart<CR><cmd>lua vim.diagnostic.reset()<CR>", { desc = "Restart LSP server" })

set("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit all" })
set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and Quit file" })
set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close buffer" })

-- Diagnostic keymaps
set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
set("n", "<leader>qf", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

set("n", "<leader>h", vim.lsp.buf.document_highlight, { desc = "Highlight variable" })
set("n", "<leader>ch", vim.lsp.buf.clear_references, { desc = "Clear highlight" })
