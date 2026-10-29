-- Explicit hover display; does not rely on macOS status-item tooltips.
local usageHover = {}
---@diagnostic disable-next-line: undefined-field -- Supplied by Hammerspoon.
local hs = _G.hs
---@type any
local timer = nil
---@type any
local panel = nil
local muted = { white = 0.65 }
local warning = { red = 1, green = 0.73, blue = 0.32 }

---@class UsageWindow
---@field label string
---@field used number
---@field reset string

---@class UsageProvider
---@field name string
---@field error? string
---@field status? string
---@field windows UsageWindow[]

---@param providers UsageProvider[]
local function elements(providers, width)
	local result = {
		{
			type = "rectangle",
			action = "strokeAndFill",
			fillColor = { white = 0.11, alpha = 0.98 },
			strokeColor = { white = 0.3 },
			strokeWidth = 1,
			roundedRectRadii = { xRadius = 10, yRadius = 10 },
			frame = { x = 0, y = 0, w = "100%", h = "100%" },
		},
	}
	local inset = 18
	local innerWidth = width - inset * 2
	local y = 16

	local function text(value, x, top, w, size, color, alignment, height)
		table.insert(result, {
			type = "text",
			text = value,
			textFont = "Helvetica Neue",
			textSize = size,
			textColor = color or { white = 0.95 },
			textAlignment = alignment or "left",
			textLineBreak = "wordWrap",
			frame = { x = x, y = top, w = w, h = height or 22 },
		})
	end

	local function rectangle(id, x, top, w, h, color)
		table.insert(result, {
			id = id,
			type = "rectangle",
			action = "fill",
			fillColor = color,
			roundedRectRadii = { xRadius = h / 2, yRadius = h / 2 },
			frame = { x = x, y = top, w = w, h = h },
		})
	end

	for index, provider in ipairs(providers) do
		if index > 1 then
			rectangle("divider-" .. index, inset, y, innerWidth, 1, { white = 0.25 })
			y = y + 16
		end
		text(provider.name, inset, y, innerWidth, 16)
		y = y + 30
		if provider.error then
			text(provider.error, inset, y, innerWidth, 12, warning, "left", 54)
			y = y + 56
		end
		for row, item in ipairs(provider.windows) do
			local id = provider.name .. "-" .. row
			local color = item.used >= 90 and { red = 1, green = 0.4, blue = 0.4 }
				or item.used >= 75 and warning
				or { red = 0.38, green = 0.73, blue = 0.95 }
			text(item.label, inset, y, innerWidth - 90, 13)
			text(string.format("%g%% used", item.used), width - inset - 90, y, 90, 13, nil, "right")
			rectangle(id .. "-track", inset, y + 24, innerWidth, 6, { white = 0.23 })
			-- Clamp only the bar: preserve the actual percentage, including over-limit usage.
			local fillWidth = innerWidth * math.min(100, math.max(0, item.used)) / 100
			if fillWidth > 0 then
				rectangle(id .. "-fill", inset, y + 24, fillWidth, 6, color)
			end
			text(item.reset, inset, y + 36, innerWidth, 11, muted)
			y = y + 64
		end
		if provider.status then
			text(provider.status, inset, y, innerWidth, 11, provider.error and warning or muted)
			y = y + 24
		end
		y = y + 8
	end
	text("Local times · Refreshes every 5 min · Click AI to refresh", inset, y, innerWidth, 10, muted)
	return result, y + 30
end

function usageHover.start(menu, content)
	if timer then
		return
	end

	timer = hs.timer.doEvery(0.15, function()
		local frame = menu:frame()
		local mouse = hs.mouse.absolutePosition()
		local inside = frame
			and mouse.x >= frame.x
			and mouse.x < frame.x + frame.w
			and mouse.y >= frame.y
			and mouse.y < frame.y + frame.h
		if not inside then
			if panel then
				panel:hide()
			end
			return
		end

		if not panel then
			panel = hs.canvas.new({ x = 0, y = 0, w = 1, h = 1 })
			if not panel then
				return
			end
			panel:level("popUpMenu")
			panel:behavior({ "canJoinAllSpaces", "fullScreenAuxiliary" })
			panel:clickActivating(false)
		end

		local screen = hs.mouse.getCurrentScreen():fullFrame()
		local width = math.min(360, screen.w - 16)
		local items, height = elements(content(), width)
		height = math.min(height, screen.h - 16)
		panel:frame({
			x = math.max(screen.x + 8, math.min(frame.x, screen.x + screen.w - width - 8)),
			y = math.max(screen.y + 8, math.min(frame.y + frame.h + 4, screen.y + screen.h - height - 8)),
			w = width,
			h = height,
		})
		panel:replaceElements(items)
		panel:show()
	end)
end

return usageHover
