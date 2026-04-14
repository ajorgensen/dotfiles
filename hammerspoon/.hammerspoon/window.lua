local windowActionStates = {}
local WINDOW_ACTION_TIMEOUT = 10 -- seconds

local bundleConfig = {
  ["app.tuple.app"] = {},
  ["us.zoom.xos"] = { "Zoom Meeting" },
}

-- Helper function to check if a window should be excluded
local function shouldExcludeWindow(win)
  local bundleID = win:application():bundleID()
  local allowedTitles = bundleConfig[bundleID]

  if not allowedTitles then
    return false
  end

  if #allowedTitles == 0 then
    return true
  end

  local title = win:title()
  for _, allowedTitle in ipairs(allowedTitles) do
    if title == allowedTitle then
      return false
    end
  end

  return true
end

local function applyPadding(frame, screenFrame)
  local paddedWidth = screenFrame.w * 0.95
  local paddedHeight = screenFrame.h * 0.95
  local paddingX = (screenFrame.w - paddedWidth) / 2
  local paddingY = (screenFrame.h - paddedHeight) / 2
  
  local widthRatio = frame.w / screenFrame.w
  local xRatio = (frame.x - screenFrame.x) / screenFrame.w
  
  return {
    x = screenFrame.x + paddingX + (xRatio * paddedWidth),
    y = screenFrame.y + paddingY,
    w = widthRatio * paddedWidth,
    h = paddedHeight
  }
end

local function nextActionIndex(stateStore, windowID, actionCount)
  local currentTime = hs.timer.secondsSinceEpoch()
  local state = stateStore[windowID]

  if not state or (currentTime - state.timestamp) > WINDOW_ACTION_TIMEOUT then
    state = { index = 1, timestamp = currentTime }
  else
    state.index = state.index % actionCount + 1
    state.timestamp = currentTime
  end

  stateStore[windowID] = state
  return state.index
end

local function createWindowCycleHandler(actionKey, actions)
  windowActionStates[actionKey] = windowActionStates[actionKey] or {}

  return function()
    local win = hs.window.focusedWindow()
    if not win or shouldExcludeWindow(win) then
      return
    end

    local screenFrame = win:screen():frame()
    local actionIndex = nextActionIndex(windowActionStates[actionKey], win:id(), #actions)
    local frame = actions[actionIndex](screenFrame)

    win:setFrame(applyPadding(frame, screenFrame))
  end
end

hs.hotkey.bind(
  { "cmd", "alt", "ctrl" },
  "Left",
  createWindowCycleHandler("left", {
    function(screenFrame)
      return {
        x = screenFrame.x,
        y = screenFrame.y,
        w = screenFrame.w / 2,
        h = screenFrame.h,
      }
    end,
    function(screenFrame)
      return {
        x = screenFrame.x,
        y = screenFrame.y,
        w = screenFrame.w / 3,
        h = screenFrame.h,
      }
    end,
  })
)

hs.hotkey.bind(
  { "cmd", "alt", "ctrl" },
  "Right",
  createWindowCycleHandler("right", {
    function(screenFrame)
      return {
        x = screenFrame.x + (screenFrame.w / 2),
        y = screenFrame.y,
        w = screenFrame.w / 2,
        h = screenFrame.h,
      }
    end,
    function(screenFrame)
      return {
        x = screenFrame.x + (screenFrame.w * 2 / 3),
        y = screenFrame.y,
        w = screenFrame.w / 3,
        h = screenFrame.h,
      }
    end,
  })
)

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

-- Function to move current window to left half and all other windows to right half
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "A", function()
  local focusedWindow = hs.window.focusedWindow()
  if not focusedWindow then
    return -- No focused window, nothing to do
  end

  local screen = focusedWindow:screen()
  local max = screen:frame()

  local leftFrame = {
    x = max.x,
    y = max.y,
    w = max.w / 2,
    h = max.h
  }

  local rightFrame = {
    x = max.x + (max.w / 2),
    y = max.y,
    w = max.w / 2,
    h = max.h
  }

  leftFrame = applyPadding(leftFrame, max)
  rightFrame = applyPadding(rightFrame, max)

  focusedWindow:setFrame(leftFrame)

  local windows = hs.window.visibleWindows()
  for _, window in ipairs(windows) do
    if window ~= focusedWindow and window:screen() == screen and not shouldExcludeWindow(window) then
      window:setFrame(rightFrame)
    end
  end
end)

-- Function to move current window to right half and all other windows to left half
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "F", function()
  local focusedWindow = hs.window.focusedWindow()
  if not focusedWindow then
    return -- No focused window, nothing to do
  end

  local screen = focusedWindow:screen()
  local max = screen:frame()

  local rightFrame = {
    x = max.x + (max.w / 2),
    y = max.y,
    w = max.w / 2,
    h = max.h
  }

  local leftFrame = {
    x = max.x,
    y = max.y,
    w = max.w / 2,
    h = max.h
  }

  rightFrame = applyPadding(rightFrame, max)
  leftFrame = applyPadding(leftFrame, max)

  focusedWindow:setFrame(rightFrame)

  local windows = hs.window.visibleWindows()
  for _, window in ipairs(windows) do
    if window ~= focusedWindow and window:screen() == screen and not shouldExcludeWindow(window) then
      window:setFrame(leftFrame)
    end
  end
end)
