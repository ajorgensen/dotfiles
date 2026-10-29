-- Run from the dotfiles root: TZ=America/New_York lua tests/hammerspoon/ai_usage_test.lua
-- Mock Hammerspoon boundaries only; never read real credentials or make requests.
---@diagnostic disable: duplicate-set-field -- Intentionally replace standard-library boundaries.
local source = "hammerspoon/.hammerspoon/ai_usage.lua"
local originalOpen = io.open
local originalGetenv = os.getenv
local originalTime = os.time
local now = 1793282400
local env
local tests = 0

local function contains(text, expected)
	assert(text:find(expected, 1, true), "Expected: " .. expected .. "\nActual: " .. text)
end

local function setup()
	local json = {}
	local function encoded(value)
		local key = "json-" .. tostring(#json + 1)
		json[#json + 1] = value
		json[key] = value
		return key
	end
	env = { requests = {}, tasks = {}, timers = {}, json = encoded }
	package.loaded.usage_hover = {
		start = function(menu, content)
			env.hoverMenu = menu
			env.hoverContent = content
		end,
	}
	env.credentials = { tokens = { access_token = "codex-token", account_id = "account" } }
	env.menu = {}
	function env.menu:setTitle(value)
		self.title = value
	end
	function env.menu:setTooltip(value)
		self.tooltip = value
	end
	function env.menu:setClickCallback(fn)
		self.click = fn
	end
	local function timer(seconds, fn)
		local value = { seconds = seconds, fn = fn, running = true }
		function value:stop()
			self.running = false
		end
		table.insert(env.timers, value)
		return value
	end
	_G.hs = {
		menubar = {
			new = function()
				return env.menu
			end,
		},
		json = {
			decode = function(text)
				assert(json[text], "Invalid JSON")
				return json[text]
			end,
		},
		http = {
			doAsyncRequest = function(url, method, body, headers, callback, cache, redirects)
				table.insert(env.requests, {
					url = url,
					method = method,
					body = body,
					headers = headers,
					callback = callback,
					cache = cache,
					redirects = redirects,
				})
			end,
		},
		task = {
			new = function(path, callback, args)
				local task = { path = path, callback = callback, args = args }
				function task:start()
					return not env.taskStartFails
				end
				function task:setCallback(fn)
					self.callback = fn
				end
				function task:terminate()
					self.terminated = true
				end
				table.insert(env.tasks, task)
				return task
			end,
		},
		timer = { doAfter = timer, doEvery = timer },
	}
	os.getenv = function(key)
		if key == "HOME" then
			return "/fake-home"
		end
		return nil
	end
	os.time = function(value)
		return value and originalTime(value) or now
	end
	io.open = function(path)
		assert(path == "/fake-home/.codex/auth.json", "Unexpected credential path")
		if not env.credentials then
			return nil
		end
		return {
			read = function()
				return encoded(env.credentials)
			end,
			close = function() end,
		}
	end
	env.module = dofile(source)
	env.module.start()
	return env
end

local function claudeLogin()
	local task = env.tasks[#env.tasks]
	task.callback(0, env.json({ claudeAiOauth = { accessToken = "claude-token" } }))
end

local function reply(index, payload, code, headers)
	env.requests[index].callback(code or 200, env.json(payload), headers)
end

local function test(name, fn)
	setup()
	fn()
	tests = tests + 1
	print("ok - " .. name)
end

local ok, message = pcall(function()
	test("fetches real provider window shapes and renders used percentages and local reset times", function()
		contains(env.module.tooltip(), "Loading")
		assert(env.tasks[1].path == "/usr/bin/security")
		assert(table.concat(env.tasks[1].args, " ") == "find-generic-password -s Claude Code-credentials -w")
		claudeLogin()
		local codexRequest, claudeRequest = env.requests[1], env.requests[2]
		assert(codexRequest.url == "https://chatgpt.com/backend-api/wham/usage")
		assert(codexRequest.headers.Authorization == "Bearer codex-token")
		assert(codexRequest.headers["ChatGPT-Account-Id"] == "account")
		assert(claudeRequest.url == "https://api.anthropic.com/api/oauth/usage")
		assert(claudeRequest.headers.Authorization == "Bearer claude-token")
		-- Anthropic requires the OAuth beta header; subscription tokens are not API keys.
		assert(claudeRequest.headers["anthropic-beta"] == "oauth-2025-04-20")
		for _, request in ipairs(env.requests) do
			assert(request.method == "GET" and request.body == nil)
			assert(request.redirects == false and request.cache == "ignoreLocalAndRemoteCache")
		end
		reply(1, {
			rate_limit = {
				primary_window = { used_percent = 10, limit_window_seconds = 18000, reset_at = now },
				secondary_window = { used_percent = 17, limit_window_seconds = 604800, reset_at = now },
			},
		})
		reply(2, {
			five_hour = { utilization = 0, resets_at = "2026-10-29T14:00:00.393824+00:00" },
			seven_day = { utilization = 1.5, resets_at = "2026-11-05T13:00:00Z" },
			seven_day_sonnet = { utilization = 22, resets_at = "2026-11-05T15:00:00+02:00" },
		})
		local tip = env.module.tooltip()
		contains(tip, "Claude\n  5h: 0% used")
		contains(tip, "Weekly: 1.5% used")
		contains(tip, "Sonnet weekly: 22% used")
		contains(tip, "Codex\n  5h: 10% used")
		contains(tip, "Weekly: 17% used")
		-- Explicit UTC instants must display in local time on both sides of DST ending.
		if originalGetenv("TZ") == "America/New_York" then
			contains(tip, "resets Thu Oct 29, 10:00 AM")
			contains(tip, "resets Thu Nov 5, 8:00 AM")
		end
		assert(env.menu.title == "AI")
		assert(env.hoverMenu == env.menu)
		local providers = env.hoverContent()
		assert(providers[1].name == "Claude" and providers[2].name == "Codex")
		assert(providers[1].windows[2].label == "Weekly" and providers[1].windows[2].used == 1.5)
		assert(providers[2].windows[1].label == "5h" and providers[2].windows[1].used == 10)
		contains(providers[1].status, "Updated")
		if originalGetenv("TZ") == "America/New_York" then
			assert(providers[1].windows[2].reset == "Resets Thu Nov 5, 8:00 AM")
		end
		assert(not tip:find("token", 1, true))
	end)

	test("failure in one provider does not discard the other's usage", function()
		env.tasks[1].callback(44, "", "secret stderr must not be displayed")
		reply(1, { rate_limit = { primary_window = { used_percent = 25, limit_window_seconds = 18000 } } })
		contains(env.module.tooltip(), "Keychain login unavailable")
		contains(env.module.tooltip(), "5h: 25% used · reset unavailable")
		assert(not env.module.tooltip():find("secret", 1, true))
		assert(env.menu.title == "AI!")
	end)

	test("last successful data is marked stale after failure and recovers with new credentials", function()
		reply(1, { rate_limit = { primary_window = { used_percent = 40 } } })
		env.credentials.tokens.access_token = "rotated-token"
		env.menu.click()
		assert(env.requests[2].headers.Authorization == "Bearer rotated-token")
		reply(2, {}, -1)
		contains(env.module.tooltip(), "Network unavailable")
		contains(env.module.tooltip(), "40% used")
		contains(env.module.tooltip(), "Last success")
		local provider = env.hoverContent()[2]
		contains(provider.error, "Network unavailable")
		contains(provider.status, "Last success")
		assert(provider.windows[1].used == 40)
		env.menu.click()
		reply(3, { rate_limit = { primary_window = { used_percent = 45 } } })
		contains(env.module.tooltip(), "45% used")
		assert(not env.module.tooltip():find("Network unavailable", 1, true))
	end)

	test("refresh is idempotent and skips in-flight work", function()
		env.module.start()
		env.menu.click()
		assert(#env.requests == 1 and #env.tasks == 1)
		claudeLogin()
		env.module.refresh()
		assert(#env.requests == 2 and #env.tasks == 1)
		local repeating = env.timers[2]
		assert(repeating.seconds == 300)
		reply(1, {}, 401)
		contains(env.module.tooltip(), "Login expired or access denied")
		repeating.fn()
		assert(#env.requests == 3)
	end)

	test("rate limiting honors cooldown even on click", function()
		reply(1, {}, 429, { ["Retry-After"] = "900" })
		env.menu.click()
		assert(#env.requests == 1)
		contains(env.module.tooltip(), "Rate limited")
		now = now + 901
		env.menu.click()
		assert(#env.requests == 2)
	end)

	test("missing and API-key-only credentials do not make authenticated requests", function()
		reply(1, {}, 401)
		env.credentials = { OPENAI_API_KEY = "not-a-subscription" }
		env.menu.click()
		assert(#env.requests == 1)
		contains(env.module.tooltip(), "run codex login")
		env.tasks[1].callback(0, "malformed credential JSON")
		contains(env.module.tooltip(), "No Claude subscription login")
		assert(#env.requests == 1)
	end)

	test("unknown or invalid usage is unavailable, not zero", function()
		reply(1, { rate_limit = { primary_window = { used_percent = "50" } } })
		contains(env.module.tooltip(), "Subscription limits unavailable")
		assert(not env.module.tooltip():find("0% used", 1, true))
		assert(#env.hoverContent()[2].windows == 0)
		contains(env.hoverContent()[2].error, "Subscription limits unavailable")
		claudeLogin()
		env.requests[2].callback(200, "invalid JSON", {})
		contains(env.module.tooltip(), "Claude\n  Subscription limits unavailable")
	end)

	test("Keychain timeouts allow a later retry without a late callback", function()
		local task = env.tasks[1]
		env.timers[1].fn()
		assert(task.terminated and task.callback == nil)
		contains(env.module.tooltip(), "Keychain access timed out")
		env.menu.click()
		assert(#env.tasks == 2)
		claudeLogin()
		assert(#env.requests == 2)
	end)
end)

io.open = originalOpen
os.getenv = originalGetenv
os.time = originalTime
_G.hs = nil
if not ok then
	error(message)
end
print(string.format("%d tests passed", tests))
