require("skill_picker")

require("copy_last")

require("workmux")

maki.setup({
  ui = {
    splash_animation = false,
    mouse_scroll_lines = 5,
    theme = "dracula",
    tool_output_lines = {
      bash = 8,
      read = 5,
    },
  },
  agent = {
    max_output_lines = 3000,
  },
  provider = {
    allowed_models = {
      "anthropic/claude-*-5*",
      "anthropic/claude-fable*",
      "openrouter/anthropic/claude-*-5*",
      "openrouter/anthropic/claude-fable*",
      "openai/gpt-6*",
      "openrouter/google/*",
    },
    excluded_models = {
      "*/*-preview*",
      "*/*:batch",
      "*/*:free",
      "*/*-image*",
    },
  },

  storage = {
    max_log_files = 5,
  },
  plugins = {
    bash = { timeout_secs = 180 },
    index = { max_file_size_mb = 4 },
  },
  always_yolo = true,
  always_thinking = "adaptive",
})
