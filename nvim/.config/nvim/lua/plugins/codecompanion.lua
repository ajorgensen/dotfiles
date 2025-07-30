return {
  "olimorris/codecompanion.nvim",
  opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local default_model = "google/gemini-2.0-flash-001"
    local available_models = {
      "google/gemini-2.0-flash-001",
      "google/gemini-2.5-pro-preview-03-25",
      "anthropic/claude-4.0-sonnet",
      "openai/gpt-4o-mini",
    }
    local current_model = default_model

    local function select_model()
      vim.ui.select(available_models, {
        prompt = "Select  Model:",
      }, function(choice)
        if choice then
          current_model = choice
          vim.notify("Selected model: " .. current_model)
        end
      end)
    end

    require("codecompanion").setup({})

    vim.keymap.set({ "n", "v" }, "<leader>ck", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    vim.keymap.set(
      { "n", "v" },
      "<leader>a",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { noremap = true, silent = true }
    )
    vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

    vim.keymap.set("n", "<leader>cs", select_model, { desc = "Select Gemini Model" })
    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])
  end
}
