local cinder_dir = vim.fn.expand("~/Projects/cinder")

return {
  dir = cinder_dir,
  name = "cinder.nvim",
  enabled = function()
    return vim.fn.isdirectory(cinder_dir) == 1
  end,
  config = function()
    require("cinder").setup({
      model = "anthropic/claude-opus-4.6",
      models = {
        "openai/gpt-5.3-codex-spark",
        "openai/gpt-5.4",
        "openai/gpt-5.4-mini",
        "anthropic/claude-opus-4.6",
      },
    })
  end,
}
