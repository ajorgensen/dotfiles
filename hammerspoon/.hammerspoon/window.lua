-- TODO: Can we refactor this to be represented as an action chain and just
-- pass in the functinos and abstract away the state tracking?

-- Tables to store window states and timestamps for left and right separately
local windowStatesLeft = {}
local windowStatesRight = {}
local exclude = { "app.tuple.app" }

-- Helper function to check if a window should be excluded
local function shouldExcludeWindow(win)
  local bundleID = win:application():bundleID()
  for _, excludeID in ipairs(exclude) do
    if bundleID == excludeID then
      return true
    end
  end
  return false
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", function()
  if shouldExcludeWindow(hs.window.focusedWindow()) then
    return
  end

  local win = hs.window.focusedWindow()
  local id = win:id()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  local currentTime = hs.timer.secondsSinceEpoch()
  local TIMEOUT = 10 -- seconds

  -- Initialize or update window state
  if not windowStatesLeft[id] then
    windowStatesLeft[id] = { state = 1, timestamp = currentTime }
  else
    -- Check if we're within the timeout period
    if (currentTime - windowStatesLeft[id].timestamp) <= TIMEOUT then
      -- Within timeout, cycle the state
      windowStatesLeft[id].state = windowStatesLeft[id].state % 2 + 1
    else
      -- Past timeout, reset to state 1
      windowStatesLeft[id].state = 1
    end
    windowStatesLeft[id].timestamp = currentTime
  end

  -- State 1: Half screen
  if windowStatesLeft[id].state == 1 then
    f.w = max.w / 2
    f.x = max.x
    -- State 2: One third screen
  else
    f.w = max.w / 3
    f.x = max.x
  end

  f.y = max.y
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", function()
  if shouldExcludeWindow(hs.window.focusedWindow()) then
    return
  end

  local win = hs.window.focusedWindow()
  local id = win:id()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  local currentTime = hs.timer.secondsSinceEpoch()
  local TIMEOUT = 10 -- seconds

  -- Initialize or update window state
  if not windowStatesRight[id] then
    windowStatesRight[id] = { state = 1, timestamp = currentTime }
  else
    -- Check if we're within the timeout period
    if (currentTime - windowStatesRight[id].timestamp) <= TIMEOUT then
      -- Within timeout, cycle the state
      windowStatesRight[id].state = windowStatesRight[id].state % 2 + 1
    else
      -- Past timeout, reset to state 1
      windowStatesRight[id].state = 1
    end
    windowStatesRight[id].timestamp = currentTime
  end

  -- State 1: Half screen
  if windowStatesRight[id].state == 1 then
    f.w = max.w / 2
    f.x = max.x + (max.w / 2)
    -- State 2: One third screen
  else
    f.w = max.w / 3
    f.x = max.x + (max.w * 2 / 3)
  end

  f.y = max.y
  f.h = max.h
  win:setFrame(f)
end)

-- Bind the window collapsing functionality to a hotkey (e.g., Cmd+Shift+C)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", function()
  local focusedWindow = hs.window.focusedWindow()
  local screen = focusedWindow:screen()
  local screenFrame = screen:frame()

  -- Calculate the new size (95% of screen size)
  local newWidth = screenFrame.w * 0.95
  local newHeight = screenFrame.h * 0.95

  -- Calculate the new position (centered)
  local newX = screenFrame.x + (screenFrame.w - newWidth) / 2
  local newY = screenFrame.y + (screenFrame.h - newHeight) / 2

  -- Get all windows on the same screen and set their frames
  local windows = hs.window.visibleWindows()
  for _, window in ipairs(windows) do
    if window:screen() == screen and not shouldExcludeWindow(window) then
      window:setFrame(hs.geometry.rect(newX, newY, newWidth, newHeight))
    end
  end
end)

-- Bind the window collapsing functionality to a hotkey (e.g., Cmd+Shift+C)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "S", function()
  local focusedWindow = hs.window.focusedWindow()
  local screen = focusedWindow:screen()
  local screenFrame = screen:frame()

  -- Calculate the new size (55% width, 95% height of screen size)
  local newWidth = screenFrame.w * 0.55
  local newHeight = screenFrame.h * 0.95

  -- Calculate the new position (centered)
  local newX = screenFrame.x + (screenFrame.w - newWidth) / 2
  local newY = screenFrame.y + (screenFrame.h - newHeight) / 2

  -- Get all windows on the same screen and set their frames
  local windows = hs.window.visibleWindows()
  for _, window in ipairs(windows) do
    if window:screen() == screen and not shouldExcludeWindow(window) then
      window:setFrame(hs.geometry.rect(newX, newY, newWidth, newHeight))
    end
  end
end)

-- Function to hide all windows except the focused one
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "H", function()
  local focusedWindow = hs.window.focusedWindow()
  if not focusedWindow then
    return -- No focused window, nothing to do
  end

  local windows = hs.window.allWindows()
  for _, window in ipairs(windows) do
    if window ~= focusedWindow then
      window:minimize()
    end
  end
end)
