local cinder_dir = vim.fn.expand("~/Projects/cinder")

return {
  dir = cinder_dir,
  name = "cinder.nvim",
  enabled = function()
    return vim.fn.isdirectory(cinder_dir) == 1
  end,
  config = function()
    require("cinder").setup({
      provider = 'pi',
      model = "openai/gpt-5.4",

      profiles = {
        quick = { model = "openai/gpt-5.4-mini" },
      }
    })
  end,
}
