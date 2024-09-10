local menubar = hs.menubar.new()
local timer = nil
local remainingTime = 0
local isTimerRunning = false

-- Function to show a notification
local function showNotification(title, message)
  hs.notify
      .new({
        title = title,
        informativeText = message,
        soundName = hs.notify.defaultNotificationSound,
        hasActionButton = false,
      })
      :send()
end

-- Function to format time as MM:SS
local function formatTime(seconds)
  local minutes = math.floor(seconds / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d", minutes, secs)
end

-- Function to update the menu bar
local function updateMenuBar()
  if remainingTime > 0 then
    menubar:setTitle(formatTime(remainingTime))
    remainingTime = remainingTime - 1
  else
    menubar:setTitle("🍅")
    if timer then
      timer:stop()
      timer = nil
    end
    isTimerRunning = false
    showNotification("Pomodoro Timer", "Timer finished!")
  end
end

-- Function to start the timer
local function startTimer(duration)
  if timer then
    timer:stop()
  end
  remainingTime = duration * 60
  menubar:setTitle(formatTime(remainingTime))
  timer = hs.timer.doEvery(1, updateMenuBar)
  isTimerRunning = true
  -- Removed the notification for timer start
end

-- Function to stop the timer
local function stopTimer()
  if timer then
    timer:stop()
    timer = nil
  end
  remainingTime = 0
  menubar:setTitle("🍅")
  isTimerRunning = false
  -- Removed the notification for timer stop
end

-- Function to prompt for duration and start timer
local function promptAndStartTimer()
  local button, minutes = hs.dialog.textPrompt("Pomodoro Timer", "Enter duration in minutes:", "", "Start", "Cancel")
  if button == "Start" then
    local duration = tonumber(minutes)
    if duration and duration > 0 then
      startTimer(duration)
    else
      showNotification("Pomodoro Timer", "Please enter a valid number of minutes")
    end
  end
end

-- Function to handle menubar clicks
local function handleMenubarClick()
  if isTimerRunning then
    local button = hs.dialog.blockAlert("Stop Timer", "Do you want to stop the current timer?", "Yes", "No")
    if button == "Yes" then
      stopTimer()
    end
  else
    promptAndStartTimer()
  end
end

-- Create the menu bar item
menubar:setTitle("🍅")
menubar:setClickCallback(handleMenubarClick)
