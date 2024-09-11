require("pomodoro")

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.loadSpoon("AClock")
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", function()
  spoon.AClock:toggleShow()
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "M", function()
  local focusedWindow = hs.window.focusedWindow()
  local allWindows = hs.window.allWindows()

  for _, window in ipairs(allWindows) do
    if window ~= focusedWindow then
      window:minimize()
    end
  end
end)

-- Bind the window collapsing functionality to a hotkey (e.g., Cmd+Shift+C)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", function()
  local screen = hs.screen.mainScreen()
  local screenFrame = screen:frame()

  -- Calculate the new size (90% of screen size)
  local newWidth = screenFrame.w * 0.9
  local newHeight = screenFrame.h * 0.9

  -- Calculate the new position (centered)
  local newX = screenFrame.x + (screenFrame.w - newWidth) / 2
  local newY = screenFrame.y + (screenFrame.h - newHeight) / 2

  -- Get all windows and set their frames
  local windows = hs.window.visibleWindows()
  for _, window in ipairs(windows) do
    window:setFrame(hs.geometry.rect(newX, newY, newWidth, newHeight))
  end
end)

-- This Hammerspoon script arranges windows as follows:
-- 1. Moves the currently focused window to the right half of the screen
-- 2. Moves all other non-minimized windows to the left half of the screen
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "L", function()
  local focusedWin = hs.window.focusedWindow()
  local allWindows = hs.window.visibleWindows()
  local screen = focusedWin:screen()
  local max = screen:frame()

  for _, win in ipairs(allWindows) do
    local f = win:frame()

    if win == focusedWin then
      -- Move focused window to right half
      f.x = max.x + (max.w / 2)
      f.y = max.y
      f.w = max.w / 2
      f.h = max.h
    elseif not win:isMinimized() then
      -- Move other non-minimized windows to left half
      f.x = max.x
      f.y = max.y
      f.w = max.w / 2
      f.h = max.h
    end

    win:setFrame(f)
  end
end)

-- This Hammerspoon script arranges windows as follows:
-- 1. Moves the currently focused window to the right half of the screen
-- 2. Moves all other non-minimized windows to the left half of the screen
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "J", function()
  local focusedWin = hs.window.focusedWindow()
  local allWindows = hs.window.visibleWindows()
  local screen = focusedWin:screen()
  local max = screen:frame()

  for _, win in ipairs(allWindows) do
    local f = win:frame()

    if win == focusedWin then
      -- Move focused window to left half
      f.x = max.x
      f.y = max.y
      f.w = max.w / 2
      f.h = max.h
    elseif not win:isMinimized() then
      -- Move other non-minimized windows to right half
      f.x = max.x + (max.w / 2)
      f.y = max.y
      f.w = max.w / 2
      f.h = max.h
    end

    win:setFrame(f)
  end
end)
