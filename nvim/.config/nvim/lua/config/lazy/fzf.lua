return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>pf", function() require("fzf-lua").files() end, desc = "Find files" },
    { "<C-p>", function() require("fzf-lua").git_files() end, desc = "Git files" },
    { "<leader>pws", function() require("fzf-lua").grep_cword() end, desc = "Grep word under cursor" },
    { "<leader>pWs", function() require("fzf-lua").grep_cWORD() end, desc = "Grep WORD under cursor" },
    { "<leader>ps", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
    { "<leader>vh", function() require("fzf-lua").help_tags() end, desc = "Help tags" },
    { "<leader>b", function() require("fzf-lua").buffers() end, desc = "Buffers" },
    { "<leader>ds", function() require("fzf-lua").lsp_document_symbols() end, desc = "Document symbols" },
    { "<leader>ws", function() require("fzf-lua").lsp_live_workspace_symbols() end, desc = "Workspace symbols" },
  },
  opts = {
    winopts = {
      preview = {
        hidden = "hidden",
      },
    },
    files = {
      previewer = false,
    },
    grep = {
      previewer = false,
    },
    lsp = {
      previewer = false,
    },
  },
}
