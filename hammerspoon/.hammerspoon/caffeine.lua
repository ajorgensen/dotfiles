-- Keep the display (and therefore the system) awake. Replaces Caffeine.app.
--
-- State is saved in hs.settings so it survives config reloads and restarts:
--   nil                  -> off, sleep allowed
--   {}                   -> on, indefinitely
--   { expiresAt = <t> }  -> on until epoch time <t>

local SETTINGS_KEY = "caffeine.state"

local DURATIONS = {
  { title = "15 minutes", seconds = 15 * 60 },
  { title = "30 minutes", seconds = 30 * 60 },
  { title = "1 hour", seconds = 60 * 60 },
  { title = "2 hours", seconds = 2 * 60 * 60 },
  { title = "4 hours", seconds = 4 * 60 * 60 },
  { title = "8 hours", seconds = 8 * 60 * 60 },
}

local menu = hs.menubar.new()
local expiryTimer = nil

-- Monochrome template coffee cup, like Caffeine.app: filled when on, outline
-- when off. Template images follow the light/dark menu bar automatically.
local function cupIcon(filled)
  local black = { black = 1 }
  local canvas = hs.canvas.new({ x = 0, y = 0, w = 18, h = 18 })
  canvas:appendElements(
    {
      type = "arc",
      center = { x = 13, y = 8.5 },
      radius = 2.75,
      startAngle = 0,
      endAngle = 180,
      arcRadii = false,
      action = "stroke",
      strokeColor = black,
      strokeWidth = 1.5,
    },
    {
      type = "segments",
      closed = true,
      coordinates = {
        { x = 2.5, y = 4.5 },
        { x = 13.5, y = 4.5 },
        { x = 12.5, y = 13.5 },
        { x = 3.5, y = 13.5 },
      },
      action = filled and "strokeAndFill" or "stroke",
      fillColor = black,
      strokeColor = black,
      strokeWidth = 1.5,
      strokeJoinStyle = "round",
    },
    {
      type = "segments",
      coordinates = { { x = 1, y = 16 }, { x = 16, y = 16 } },
      action = "stroke",
      strokeColor = black,
      strokeWidth = 1.5,
      strokeCapStyle = "round",
    }
  )

  local image = canvas:imageFromCanvas()
  canvas:delete()
  return image:template(true)
end

local ICON_ON = cupIcon(true)
local ICON_OFF = cupIcon(false)

local function formatTime(epoch)
  return (os.date("%I:%M %p", epoch):gsub("^0", ""))
end

local function statusText(state)
  if not state then
    return "Sleep allowed"
  end

  if not state.expiresAt then
    return "Awake indefinitely"
  end

  return "Awake until " .. formatTime(state.expiresAt)
end

local function apply(state)
  if expiryTimer then
    expiryTimer:stop()
    expiryTimer = nil
  end

  if state and state.expiresAt and state.expiresAt <= os.time() then
    state = nil
  end

  if state then
    hs.settings.set(SETTINGS_KEY, state)
  else
    hs.settings.clear(SETTINGS_KEY)
  end

  hs.caffeinate.set("displayIdle", state ~= nil)

  if state and state.expiresAt then
    expiryTimer = hs.timer.doAfter(state.expiresAt - os.time(), function()
      apply(nil)
    end)
  end

  if menu then
    menu:setIcon(state and ICON_ON or ICON_OFF, true)
    menu:setTooltip(statusText(state))
  end
end

local function currentState()
  return hs.settings.get(SETTINGS_KEY)
end

local function toggle()
  if currentState() then
    apply(nil)
  else
    apply({})
  end
end

local function buildMenu()
  local state = currentState()
  local items = {
    { title = statusText(state), disabled = true },
    { title = "-" },
    {
      title = "Indefinitely",
      checked = state ~= nil and state.expiresAt == nil,
      fn = function()
        apply({})
      end,
    },
  }

  for _, duration in ipairs(DURATIONS) do
    table.insert(items, {
      title = duration.title,
      fn = function()
        apply({ expiresAt = os.time() + duration.seconds })
      end,
    })
  end

  table.insert(items, { title = "-" })
  table.insert(items, {
    title = "Turn off",
    disabled = state == nil,
    fn = function()
      apply(nil)
    end,
  })

  return items
end

if menu then
  menu:setMenu(buildMenu)
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "K", toggle)

-- Restore the saved state; expired timed sessions turn off here.
apply(currentState())
