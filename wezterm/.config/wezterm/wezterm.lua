local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.keys = {
  {
    key = "K",
    mods = "CTRL|SHIFT",
    action = act.ClearScrollback("ScrollbackAndViewport"),
  },
}

-- Colors
config.color_scheme = "Monokai (base16)"

-- Fonts
config.font = wezterm.font({ family = "SauceCodePro Nerd Font", weight = "Regular" })
config.font_size = 14

-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"
-- Sets the font for the window frame (tab bar)
config.window_frame = {
  -- Berkeley Mono for me again, though an idea could be to try a
  -- serif font here instead of monospace for a nicer look?
  font = wezterm.font({ family = "Hack Nerd Font Mono", weight = "Bold" }),
  font_size = 11,
}

wezterm.on("update-status", function(window)
  -- Grab the utf8 character for the "powerline" left facing
  -- solid arrow.
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Grab the current window's configuration, and from it the
  -- palette (this is the combination of your chosen colour scheme
  -- including any overrides).
  local color_scheme = window:effective_config().resolved_palette
  local bg = color_scheme.background
  local fg = color_scheme.foreground

  window:set_right_status(wezterm.format({
    -- First, we draw the arrow...
    { Background = { Color = "none" } },
    { Foreground = { Color = bg } },
    { Text = SOLID_LEFT_ARROW },
    -- Then we draw our text
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = " " .. wezterm.hostname() .. " " },
  }))
end)

return config
