require("avante").setup({
  provider = "gemini",
  behavior = {
    enable_cursor_planning_mode = true,
    enable_claude_text_editor_tool_mode = true,
  },
  gemini = {
    model = "gemini-2.0-flash",
  },
  claude = {
    model = "claude-3-5-sonnet-latest",
  },
  openai = {
    model = "o3-mini",
  },
  vendors = {
    ["gemini-pro"] = {
      __inherited_from = "gemini",
      model = "gemini-2.5-pro-exp-03-25",
    },
    ["claude-37"] = {
      __inherited_from = "claude",
      model = "claude-3-7-sonnet-latest",
    },
  },
})
