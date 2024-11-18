require("pomodoro")
require("window")

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
