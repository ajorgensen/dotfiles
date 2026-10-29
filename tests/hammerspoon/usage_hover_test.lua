-- Run from the dotfiles root: lua tests/hammerspoon/usage_hover_test.lua
local source = "hammerspoon/.hammerspoon/usage_hover.lua"
local env
local tests = 0

local function setup()
	env = {
		mouse = { x = 20, y = 100 },
		itemFrame = { x = 270, y = 0, w = 30, h = 25 },
		screen = { x = 0, y = 0, w = 320, h = 800 },
		content = {
			{
				name = "Claude",
				windows = {
					{ label = "5h", used = 5, reset = "Resets Thu Oct 29, 6:49 PM" },
					{ label = "Weekly", used = 25, reset = "Resets Thu Nov 5, 7:59 AM" },
				},
				status = "Updated Thu Oct 29, 3:02 PM",
			},
			{ name = "Codex", windows = {}, status = "Loading…" },
		},
		contentReads = 0,
	}
	_G.hs = {
		timer = {
			doEvery = function(seconds, fn)
				env.interval = seconds
				env.tick = fn
				return {}
			end,
		},
		mouse = {
			absolutePosition = function()
				return env.mouse
			end,
			getCurrentScreen = function()
				return {
					fullFrame = function()
						return env.screen
					end,
				}
			end,
		},
		canvas = {
			new = function(_)
				local panel = { visible = false }
				function panel:level(value)
					self.windowLevel = value
				end
				function panel:behavior(value)
					self.windowBehavior = value
				end
				function panel:clickActivating(value)
					self.activating = value
				end
				function panel:replaceElements(items)
					self.items = items
				end
				function panel:frame(value)
					self.bounds = value
				end
				function panel:show()
					self.visible = true
				end
				function panel:hide()
					self.visible = false
				end
				env.panel = panel
				return panel
			end,
		},
	}
	local hover = dofile(source)
	env.start = function()
		hover.start({
			frame = function()
				return env.itemFrame
			end,
		}, function()
			env.contentReads = env.contentReads + 1
			return env.content
		end)
	end
	env.start()
end

local function hasText(expected)
	for _, item in ipairs(env.panel.items) do
		if item.type == "text" and item.text == expected then
			return true
		end
	end
	return false
end

local function element(id)
	for _, item in ipairs(env.panel.items) do
		if item.id == id then
			return item
		end
	end
end

local function test(name, fn)
	setup()
	fn()
	tests = tests + 1
	print("ok - " .. name)
end

local ok, message = pcall(function()
	test("shows current usage only when hovering and hides on leave", function()
		env.tick()
		assert(not env.panel and env.contentReads == 0)
		env.mouse = { x = 280, y = 12 }
		env.tick()
		assert(env.panel.visible)
		assert(hasText("Claude") and hasText("Codex"))
		assert(hasText("5h") and hasText("5% used") and hasText("Weekly") and hasText("25% used"))
		assert(hasText("Resets Thu Oct 29, 6:49 PM") and hasText("Loading…"))
		assert(env.panel.activating == false)
		env.mouse.y = 100
		env.tick()
		assert(not env.panel.visible)
	end)

	test("visible content follows background updates without a fetch", function()
		env.mouse = { x = 280, y = 12 }
		env.tick()
		env.content[1].error = "Rate limited; retry later."
		env.content[1].status = "Last success Thu Oct 29, 3:02 PM"
		env.content[1].windows[1].used = 15
		env.tick()
		assert(hasText("Rate limited; retry later."))
		assert(hasText("Last success Thu Oct 29, 3:02 PM"))
		assert(hasText("15% used") and not hasText("5% used"))
		assert(env.contentReads == 2)
	end)

	test("bar lengths show usage without overflowing or hiding over-limit values", function()
		env.mouse = { x = 280, y = 12 }
		env.tick()
		local track = element("Claude-2-track")
		local fill = element("Claude-2-fill")
		assert(fill.frame.w == track.frame.w * 0.25)
		assert(fill.frame.x == track.frame.x and fill.frame.y == track.frame.y)
		env.content[1].windows[1].used = 0
		env.content[1].windows[2].used = 125
		env.tick()
		assert(not element("Claude-1-fill"))
		assert(element("Claude-2-fill").frame.w == element("Claude-2-track").frame.w)
		assert(hasText("0% used") and hasText("125% used"))
	end)

	test("provider errors without data do not display fabricated zero usage", function()
		env.content = { { name = "Claude", windows = {}, error = "No subscription login; sign in." } }
		env.mouse = { x = 280, y = 12 }
		env.tick()
		assert(hasText("No subscription login; sign in."))
		assert(not element("Claude-1-track") and not hasText("0% used"))
	end)

	test("panel stays on screen and below the menu item", function()
		env.mouse = { x = 280, y = 12 }
		env.tick()
		local bounds = env.panel.bounds
		assert(bounds.x >= env.screen.x)
		assert(bounds.x + bounds.w <= env.screen.x + env.screen.w)
		assert(bounds.y > env.itemFrame.y + env.itemFrame.h)
		assert(bounds.y + bounds.h <= env.screen.y + env.screen.h)
	end)

	test("hidden menu items dismiss the panel and repeated start does not add timers", function()
		env.mouse = { x = 280, y = 12 }
		env.tick()
		env.itemFrame = nil
		env.tick()
		assert(not env.panel.visible)
		local tick = env.tick
		env.start()
		assert(env.tick == tick)
	end)
end)

_G.hs = nil
if not ok then
	error(message)
end
print(string.format("%d tests passed", tests))
