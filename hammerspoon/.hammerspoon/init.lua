require("pomodoro")
require("window")
require("switcher")
require("github_reviews").start()

-- Enable CLI integration (`hs -c ...`) for local validation/debugging.
pcall(require, "hs.ipc")

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Microphone mute toggle and menu bar icon
local micMuter = hs.menubar.new()

local function setMicMuteIcon(isMuted)
  if isMuted then
    micMuter:setTitle("🔇")
  else
    micMuter:setTitle("🔊")
  end
end

local function toggleMicMute()
  local currentAudioInput = hs.audiodevice.defaultInputDevice()
  local isMuted = currentAudioInput:inputMuted()
  currentAudioInput:setInputMuted(not isMuted)
  setMicMuteIcon(not isMuted)
end

if micMuter then
  micMuter:setClickCallback(toggleMicMute)
  setMicMuteIcon(hs.audiodevice.defaultInputDevice():inputMuted())
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "M", toggleMicMute)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "D", function()
  local focusedWindow = hs.window.focusedWindow()

  print("\n*** Focused Window ***")
  if focusedWindow then
    print(
      string.format(
        [[
Title: %s
Bundle ID: %s
Role: %s
Subrole: %s
Standard: %s
----------------------------------------]],
        focusedWindow:title(),
        focusedWindow:application():bundleID(),
        focusedWindow:role(),
        focusedWindow:subrole(),
        tostring(focusedWindow:isStandard())
      )
    )
  else
    print("No focused window")
  end

  print("\n*** All Visible Windows ***")
  local visibleWindows = hs.window.visibleWindows()
  for i, window in ipairs(visibleWindows) do
    print(
      string.format(
        [[
Window %d:
  App: %s
  Title: %s
  Bundle ID: %s
  ID: %s
----------------------------------------]],
        i,
        window:application():name(),
        window:title(),
        window:application():bundleID(),
        window:id()
      )
    )
  end
end)
