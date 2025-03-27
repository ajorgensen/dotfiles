require("avante").setup({
  provider = "gemini",
  gemini = {
    model = "gemini-2.0-flash",
  },
  claude = {
    model = "claude-3-7-sonnet-20250219",
  },
  vendors = {
    ["gemini-pro"] = {
      __inherited_from = "gemini",
      model = "gemini-2.5-pro-exp-03-25",
    },
  },
})
