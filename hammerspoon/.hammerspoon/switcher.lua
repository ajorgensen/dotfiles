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
function getAllVisibleWindows()
  local windows = hs.window.allWindows()
  local choices = {}

  for _, window in ipairs(windows) do
    local app = window:application()
    -- Only include windows that are visible, have a title, and belong to a real application
    if app and window:isVisible() and window:title() ~= "" then
      local appName = app:name()
      local choice = {
        text = appName .. " - " .. window:title(),
        subText = window:role() or "",
        image = hs.image.imageFromAppBundle(app:bundleID()),
        window = window,
      }
      -- Filter out known background processes and helper windows
      local isBackgroundProcess = appName:match("Helper$")
          or appName:match(" Helper$")
          or appName:match("Agent$")
          or window:role() == "AXUnknown"

      if not isBackgroundProcess then
        table.insert(choices, choice)
      end
    end
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
  switcher:show()
end

-- Bind the keyboard shortcut (Option + Space)
hs.hotkey.bind({ "alt" }, "space", showWindowSwitcher)
