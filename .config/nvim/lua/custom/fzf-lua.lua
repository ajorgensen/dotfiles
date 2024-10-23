require("fzf-lua").setup {
  defaults = {
    git_icons = false,
    file_icons = false,
    color_icons = false,
  },
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
    },
  },
}

vim.keymap.set("n", "<leader>fR", require("fzf-lua").registers, { desc = "Fzf Registers" })
vim.keymap.set("n", "<leader>fb", require("fzf-lua").buffers, { desc = "Fzf Buffers" })
vim.keymap.set("n", "<leader>ff", require("fzf-lua").files, { desc = "Fzf Files" })
vim.keymap.set("n", "<leader>fg", require("fzf-lua").live_grep_glob, { desc = "Fzf Grep" })
vim.keymap.set("n", "<leader>fj", require("fzf-lua").helptags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fm", require("fzf-lua").marks, { desc = "Marks" })

vim.keymap.set("n", "<leader>gc", require("fzf-lua").git_bcommits, { desc = "Browse File Commits" })
vim.keymap.set("n", "<leader>gs", require("fzf-lua").git_status, { desc = "Git Status" })

vim.keymap.set("n", "<leader>fr", require("fzf-lua").lsp_references, { desc = "References" })

vim.keymap.set("n", "<leader>fwd", require("fzf-lua").lsp_workspace_diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fdd", require("fzf-lua").lsp_document_diagnostics, { desc = "Document Diagnostics" })

vim.keymap.set("n", "<leader>fds", require("fzf-lua").lsp_document_symbols, { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>fws", require("fzf-lua").lsp_live_workspace_symbols, { desc = "Workspace Symbols" })

vim.keymap.set("n", "<leader>jd", require("fzf-lua").lsp_definitions, { desc = "Jump to Definition" })
vim.keymap.set("n", "<leader>ds", require("fzf-lua").lsp_document_symbols, { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>lr", require("fzf-lua").lsp_references, { desc = "LSP References" })

vim.keymap.set(
  "n",
  "<leader>ca",
  ":lua require'fzf-lua'.lsp_code_actions({ winopts = {relative='cursor',row=1.01, col=0, height=0.2, width=0.4} })<cr>",
  { desc = "Code Actions" }
)

vim.keymap.set(
  "n",
  "<leader>s",
  ":lua require'fzf-lua'.spell_suggest({ winopts = {relative='cursor',row=1.01, col=0, height=0.2, width=0.2} })<cr>",
  { desc = "Spelling Suggestions" }
)

vim.api.nvim_set_keymap(
  "v",
  "<leader>fs",
  ":lua require'fzf-lua'.grep({search=GetVisualSelection()})<CR>",
  { desc = "Search for selected text", noremap = true, silent = true }
)

-- Function to get the currently highlighted/selected text in visual mode
function GetVisualSelection()
  -- Get the current buffer handle
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get the type of visual mode ('v' = visual character mode, 'V' = visual line mode, Ctrl-V = visual block mode)
  local mode = vim.fn.visualmode()

  -- Get the starting and ending rows/columns of the visual selection
  -- The end row/col need to be corrected to handle inclusive/exclusive ranges properly

  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  -- Positions are line-based, so subtract 1 to get zero-indexed positions for use in Lua API
  local start_row = start_pos[2] - 1 -- Line number
  local start_col = start_pos[3] - 1 -- Column number
  local end_row = end_pos[2] - 1     -- Line number
  local end_col = end_pos[3] - 1     -- Column number

  -- If it's character-wise selection (visual 'v'), adjust for inclusive behavior
  if mode == "v" then
    end_col = end_col + 1
  end

  -- Call the nvim_buf_get_text function to get the selected text
  local selected_text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

  -- Join the lines into a single string
  local result = table.concat(selected_text, "\n")

  print("Selected text: " .. result)

  return result
end
