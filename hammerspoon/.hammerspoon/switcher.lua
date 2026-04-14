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

local appBindings = {
  {
    name = "Ghostty",
    key = "1",
    bundleID = "com.mitchellh.ghostty",
  },
  {
    name = "Slack",
    key = "2",
    bundleID = "com.tinyspeck.slackmacgap",
  },
  {
    name = "Vivaldi",
    key = "3",
    bundleID = "com.vivaldi.Vivaldi",
  },
}

local appSwitchState = {
  bundleID = nil,
  timestamp = 0,
}

local APP_SWITCH_REPEAT_TIMEOUT = 2

local function getRunningApp(appBinding)
  local apps = hs.application.applicationsForBundleID(appBinding.bundleID)
  return apps and apps[1] or nil
end

local function getCyclableWindows(app)
  local windows = {}

  for _, window in ipairs(app:allWindows()) do
    if window:isStandard() and not window:isMinimized() then
      table.insert(windows, window)
    end
  end

  table.sort(windows, function(a, b)
    return a:id() < b:id()
  end)

  return windows
end

local function focusWindow(window, app)
  app:activate()
  window:focus()
end

local function focusOrActivateApp(app)
  local windows = getCyclableWindows(app)

  if #windows > 0 then
    focusWindow(windows[1], app)
    return true
  end

  app:activate()
  return false
end

local function cycleAppWindows(app)
  local windows = getCyclableWindows(app)

  if #windows == 0 then
    app:activate()
    return false
  end

  if #windows == 1 then
    focusWindow(windows[1], app)
    return true
  end

  local focusedWindow = hs.window.focusedWindow()
  local nextIndex = 1

  if focusedWindow and focusedWindow:application() == app then
    for index, window in ipairs(windows) do
      if window:id() == focusedWindow:id() then
        nextIndex = (index % #windows) + 1
        break
      end
    end
  end

  focusWindow(windows[nextIndex], app)
  return true
end

local function launchOrFocusApp(appBinding)
  local app = getRunningApp(appBinding)

  if not app then
    hs.application.launchOrFocusByBundleID(appBinding.bundleID)
    return
  end

  local now = hs.timer.secondsSinceEpoch()
  local isRepeatPress = appSwitchState.bundleID == appBinding.bundleID
    and (now - appSwitchState.timestamp) <= APP_SWITCH_REPEAT_TIMEOUT

  if isRepeatPress then
    cycleAppWindows(app)
  else
    focusOrActivateApp(app)
  end

  appSwitchState.bundleID = appBinding.bundleID
  appSwitchState.timestamp = now
end

for _, appBinding in ipairs(appBindings) do
  hs.hotkey.bind({ "alt" }, appBinding.key, function()
    launchOrFocusApp(appBinding)
  end)
end

-- Bind the keyboard shortcut (Option + Space)
hs.hotkey.bind({ "alt" }, "space", showWindowSwitcher)
