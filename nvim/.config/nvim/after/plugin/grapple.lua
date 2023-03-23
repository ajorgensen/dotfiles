vim.keymap.set("n", "<leader>m", vim.cmd.GrappleToggle)
vim.keymap.set("n", "<leader>k", function() vim.cmd.GrapplePopup("tags") end)
vim.keymap.set("n", "<leader>j", function() vim.cmd.GrappleCycle("forward") end)
vim.keymap.set("n", "<leader>J", function() vim.cmd.GrappleCycle("backward") end)
