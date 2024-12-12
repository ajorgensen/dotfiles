-- Initialize the chooser
local switcher = hs.chooser.new(function(choice)
  if not choice then
    return
  end
  local window = choice.window
  if window then
    window:focus()
  end
end)

-- Function to get all visible windows
local function getAllVisibleWindows()
  local windows = hs.window.visibleWindows()
  local choices = {}

  for _, window in ipairs(windows) do
    local app = window:application()
    local appName = app:name()
    local choice = {
      text = appName .. " - " .. window:title(),
      subText = window:role() or "",
      image = hs.image.imageFromAppBundle(app:bundleID()),
      window = window,
    }

    table.insert(choices, choice)
  end

  -- Sort choices alphabetically by app name
  table.sort(choices, function(a, b)
    return a.text:lower() < b.text:lower()
  end)

  return choices
end

-- Function to show the window switcher
local function showWindowSwitcher()
  switcher:choices(getAllVisibleWindows())
  switcher:query(nil) -- Clear the previous search text
  switcher:show()
end

-- Bind the keyboard shortcut (Option + Space)
hs.hotkey.bind({ "alt" }, "space", showWindowSwitcher)
