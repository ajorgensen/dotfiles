require("pomodoro")
require("window")
require("switcher")

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
  print("\n*** All Visible Windows ***")
  local allWindows = hs.window.allWindows()
  for i, window in ipairs(allWindows) do
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
