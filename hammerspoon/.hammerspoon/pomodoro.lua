local menubar = hs.menubar.new()
local timer = nil
local promptView = nil
local promptController = nil
local remainingTime = 0
local isTimerRunning = false
local shouldAutoPauseMusic = true

-- Function to show a notification
local function showNotification(title, message)
  hs.notify
      .new({
        title = title,
        informativeText = message,
        soundName = hs.notify.defaultNotificationSound,
        hasActionButton = true,
        actionButtonTitle = "Done",
        withdrawAfter = 0, -- 0 means it does not automatically close
      })
      :send()
end

-- Function to format time as MM:SS
local function formatTime(seconds)
  local minutes = math.floor(seconds / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d", minutes, secs)
end

local function closePrompt()
  if promptController then
    promptController:setCallback(nil)
    promptController = nil
  end

  if promptView then
    promptView:delete()
    promptView = nil
  end
end

local function pauseSupportedMedia()
  local pausedApps = {}

  if hs.spotify and hs.spotify.isRunning and hs.spotify.isRunning() and hs.spotify.isPlaying() then
    hs.spotify.pause()
    table.insert(pausedApps, "Spotify")
  end

  if hs.itunes and hs.itunes.isRunning and hs.itunes.isRunning() and hs.itunes.isPlaying() then
    hs.itunes.pause()
    table.insert(pausedApps, "Music")
  end

  return pausedApps
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

    local message = "Timer finished!"
    if shouldAutoPauseMusic then
      local pausedApps = pauseSupportedMedia()
      if #pausedApps > 0 then
        message = string.format("%s Paused %s.", message, table.concat(pausedApps, " and "))
      end
    end

    showNotification("Pomodoro Timer", message)
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
  closePrompt()

  local screenFrame = hs.screen.mainScreen():frame()
  local width = 340
  local height = 230
  local frame = {
    x = screenFrame.x + ((screenFrame.w - width) / 2),
    y = screenFrame.y + ((screenFrame.h - height) / 2),
    w = width,
    h = height,
  }

  promptController = hs.webview.usercontent.new("pomodoroPrompt")
  promptController:setCallback(function(message)
    local body = message and message.body
    if type(body) ~= "table" then
      return
    end

    if body.action == "cancel" then
      closePrompt()
      return
    end

    if body.action == "submit" then
      local duration = tonumber(body.minutes)
      shouldAutoPauseMusic = body.autoPauseMusic ~= false
      closePrompt()

      if duration and duration > 0 then
        startTimer(duration)
      else
        showNotification("Pomodoro Timer", "Please enter a valid number of minutes")
      end
    end
  end)

  local windowStyle = hs.webview.windowMasks.titled
      | hs.webview.windowMasks.closable

  promptView = hs.webview.new(frame, { developerExtrasEnabled = false }, promptController)
      :windowStyle(windowStyle)
      :windowTitle("Pomodoro Timer")
      :closeOnEscape(true)
      :deleteOnClose(false)
      :allowNewWindows(false)
      :allowTextEntry(true)
      :transparent(false)
      :windowCallback(function(action)
        if action == "closing" then
          closePrompt()
        end
      end)

  promptView:html([[
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }

          body {
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
            background: #f5f5f7;
            color: #1d1d1f;
            padding: 20px 24px 24px;
            overflow: hidden;
            -webkit-user-select: none;
            user-select: none;
          }

          form {
            display: flex;
            flex-direction: column;
            gap: 18px;
          }

          .header { display: flex; flex-direction: column; gap: 4px; }
          .header h1 { font-size: 16px; font-weight: 600; letter-spacing: -0.2px; }
          .header p  { font-size: 12px; color: #86868b; }

          input[type="number"] {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #d2d2d7;
            border-radius: 8px;
            background: #fff;
            color: #1d1d1f;
            font-size: 15px;
            font-family: inherit;
            outline: none;
            transition: border-color 0.15s, box-shadow 0.15s;
            -webkit-user-select: text;
            user-select: text;
            -moz-appearance: textfield;
          }
          input[type="number"]::-webkit-inner-spin-button,
          input[type="number"]::-webkit-outer-spin-button { -webkit-appearance: none; margin: 0; }
          input[type="number"]:focus {
            border-color: #0071e3;
            box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.2);
          }
          input[type="number"]::placeholder { color: #acacb0; }

          .checkbox-row {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            color: #515154;
            cursor: pointer;
          }
          .checkbox-row input[type="checkbox"] {
            width: 15px;
            height: 15px;
            accent-color: #0071e3;
            cursor: pointer;
            flex-shrink: 0;
          }

          .actions {
            display: flex;
            justify-content: flex-end;
            gap: 8px;
            padding-top: 2px;
          }

          button {
            border: none;
            border-radius: 8px;
            padding: 7px 18px;
            font-size: 13px;
            font-weight: 500;
            font-family: inherit;
            cursor: pointer;
            transition: filter 0.12s, opacity 0.12s;
          }
          button:active { opacity: 0.7; }

          .cancel-btn {
            background: #e8e8ed;
            color: #1d1d1f;
          }
          .cancel-btn:hover { filter: brightness(0.95); }

          .start-btn {
            background: #d44332;
            color: #fff;
          }
          .start-btn:hover { filter: brightness(1.08); }

          @media (prefers-color-scheme: dark) {
            body { background: #1c1c1e; color: #f5f5f7; }
            .header p { color: #86868b; }
            input[type="number"] {
              background: #2c2c2e;
              border-color: #48484a;
              color: #f5f5f7;
            }
            input[type="number"]::placeholder { color: #636366; }
            input[type="number"]:focus {
              border-color: #0a84ff;
              box-shadow: 0 0 0 3px rgba(10, 132, 255, 0.25);
            }
            .checkbox-row { color: #a1a1a6; }
            .cancel-btn { background: #3a3a3c; color: #f5f5f7; }
            .cancel-btn:hover { filter: brightness(1.15); }
            .start-btn { background: #d44332; }
          }
        </style>
      </head>
      <body>
        <form id="pomodoro-form">
          <div class="header">
            <h1>Start a pomodoro</h1>
            <p>Duration in minutes</p>
          </div>

          <input id="minutes" type="number" min="1" step="1" placeholder="25" autofocus>

          <label class="checkbox-row">
            <input id="auto-pause-music" type="checkbox" checked>
            Pause music when timer ends
          </label>

          <div class="actions">
            <button class="cancel-btn" type="button" id="cancel">Cancel</button>
            <button class="start-btn" type="submit">Start</button>
          </div>
        </form>

        <script>
          const postMessage = (payload) => {
            webkit.messageHandlers.pomodoroPrompt.postMessage(payload)
          }

          document.getElementById("pomodoro-form").addEventListener("submit", (event) => {
            event.preventDefault()
            postMessage({
              action: "submit",
              minutes: document.getElementById("minutes").value,
              autoPauseMusic: document.getElementById("auto-pause-music").checked,
            })
          })

          document.getElementById("cancel").addEventListener("click", () => {
            postMessage({ action: "cancel" })
          })

          window.addEventListener("keydown", (event) => {
            if (event.key === "Escape") {
              postMessage({ action: "cancel" })
            }
          })
        </script>
      </body>
    </html>
  ]])

  promptView:show()
  promptView:bringToFront()
  hs.application.get("Hammerspoon"):activate()
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
