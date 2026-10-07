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
    default_model = "anthropic/claude-opus-5-5",
    allowed_models = {
      "anthropic/claude-*-5-*",
      "anthropic/claude-fable*",
      "openai/gpt-6*",
    },
    excluded_models = { "*/*-preview" },
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
