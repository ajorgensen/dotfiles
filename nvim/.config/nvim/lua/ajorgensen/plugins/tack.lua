require("tack").setup {
  view = "split",
}

vim.api.nvim_create_user_command("TackReviewFile", function()
  require("tack").review("HEAD -- " .. vim.fn.expand "%:p")
end, { desc = "Review current file with Tack" })

local keymaps = {
  { "n", "<leader>Rr", "<cmd>TackReview<cr>", "Review diff with Tack" },
  { "n", "<leader>RR", "<cmd>TackReload<cr>", "Reload Tack review" },
  { "n", "<leader>Rl", "<cmd>TackComments<cr>", "List Tack comments" },
  { "n", "<leader>Rc", "<cmd>TackComment<cr>", "Comment on line with Tack" },
  { "x", "<leader>Rc", ":<C-u>'<,'>TackComment<cr>", "Comment on selection with Tack" },
  { "n", "<leader>Rx", "<cmd>TackRemove<cr>", "Remove Tack comment" },
}

for _, keymap in ipairs(keymaps) do
  vim.keymap.set(keymap[1], keymap[2], keymap[3], { desc = keymap[4] })
end
