-- Subscription limits, not API spend or estimates from local token logs.
-- Credentials stay in memory; the CLIs own login and token refresh.
local aiUsage = {}
local usageHover = require("usage_hover")
---@diagnostic disable-next-line: undefined-field -- Supplied by Hammerspoon.
local hs = _G.hs
local REFRESH_SECONDS = 300
local home = os.getenv("HOME")
---@type any
local menu = nil
---@type any
local refreshTimer = nil
---@type any
local credentialTask = nil
---@type any
local credentialTimeout = nil
local claude = { name = "Claude" }
local codex = { name = "Codex" }

local function decode(text)
	if type(text) ~= "string" then
		return nil
	end
	local ok, value = pcall(hs.json.decode, text)
	if ok and type(value) == "table" then
		return value
	end
	return nil
end

local function readJSON(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return decode(content)
end

local function nonEmpty(value)
	return type(value) == "string" and value ~= ""
end

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function isoEpoch(value)
	if type(value) ~= "string" then
		return nil
	end
	local year, month, day, hour, minute, second, zone =
		value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)%.?%d*(.*)$")
	if not year then
		return nil
	end
	local zoneOffset = 0
	if zone ~= "Z" then
		local sign, hours, minutes = zone:match("^([+-])(%d%d):(%d%d)$")
		if not sign then
			return nil
		end
		zoneOffset = (tonumber(hours) * 60 + tonumber(minutes)) * 60 * (sign == "+" and 1 or -1)
	end
	local localEpoch = os.time({
		year = year,
		month = month,
		day = day,
		hour = hour,
		min = minute,
		sec = second,
		isdst = false,
	})
	-- Treat both tables as standard time to remove the local timezone without DST skew.
	local utc = os.date("!*t", localEpoch) --[[@as osdate]]
	utc.isdst = false
	return localEpoch + os.difftime(localEpoch, os.time(utc)) - zoneOffset
end

local function window(label, used, reset)
	if not finite(used) or used < 0 then
		return nil
	end
	return { label = label, used = used, reset = finite(reset) and reset > 0 and reset or nil }
end

local function claudeWindows(payload)
	local windows = {}
	for _, spec in ipairs({
		{ "five_hour", "5h" },
		{ "seven_day", "Weekly" },
		{ "seven_day_opus", "Opus weekly" },
		{ "seven_day_sonnet", "Sonnet weekly" },
	}) do
		local raw = payload[spec[1]]
		local item = type(raw) == "table" and window(spec[2], raw.utilization, isoEpoch(raw.resets_at))
		if item then
			table.insert(windows, item)
		end
	end
	return windows
end

local function codexWindows(payload)
	local limits = payload.rate_limit
	if type(limits) ~= "table" then
		return {}
	end
	local windows = {}
	for _, spec in ipairs({ { "primary_window", "Primary" }, { "secondary_window", "Secondary" } }) do
		local raw = limits[spec[1]]
		if type(raw) == "table" then
			local seconds = raw.limit_window_seconds
			local label = spec[2]
			if finite(seconds) and seconds > 0 then
				label = seconds == 604800 and "Weekly" or string.format("%gh", seconds / 3600)
			end
			local item = window(label, raw.used_percent, raw.reset_at)
			if item then
				table.insert(windows, item)
			end
		end
	end
	return windows
end

---@param epoch number
local function timeText(epoch)
	local formatted = os.date("%a %b %d, %I:%M %p", epoch) --[[@as string]]
	return (formatted:gsub(" 0", " "))
end

-- Presentation data only; hover never reads credentials or requests usage.
function aiUsage.snapshot()
	local providers = {}
	for _, provider in ipairs({ claude, codex }) do
		local windows = {}
		for _, item in ipairs(provider.windows or {}) do
			table.insert(windows, {
				label = item.label,
				used = item.used,
				reset = item.reset and ("Resets " .. timeText(item.reset)) or "Reset unavailable",
			})
		end
		table.insert(providers, {
			name = provider.name,
			error = provider.error,
			windows = windows,
			status = provider.updatedAt and ((provider.error and "Last success " or "Updated ") .. timeText(
				provider.updatedAt
			)) or (not provider.error and "Loading…" or nil),
		})
	end
	return providers
end

function aiUsage.tooltip()
	local sections = {}
	for _, provider in ipairs({ claude, codex }) do
		local lines = { provider.name }
		if provider.error then
			table.insert(lines, "  " .. provider.error)
		end
		if provider.updatedAt then
			for _, item in ipairs(provider.windows) do
				local reset = item.reset and ("resets " .. timeText(item.reset)) or "reset unavailable"
				table.insert(lines, string.format("  %s: %g%% used · %s", item.label, item.used, reset))
			end
			local status = provider.error and "Last success" or "Updated"
			table.insert(lines, "  " .. status .. " " .. timeText(provider.updatedAt))
		elseif not provider.error then
			table.insert(lines, "  Loading…")
		end
		table.insert(sections, table.concat(lines, "\n"))
	end
	return table.concat(sections, "\n\n") .. "\n\nLocal reset times · Refreshes every 5 min\nClick AI to refresh"
end

local function updateMenu()
	if not menu then
		return
	end
	menu:setTitle((claude.error or codex.error) and "AI!" or "AI")
end

local function fail(provider, message)
	provider.busy = false
	provider.error = message
	updateMenu()
end

local function fetch(provider, url, headers, parse)
	-- Do not cache authenticated responses or follow redirects with a bearer token.
	hs.http.doAsyncRequest(url, "GET", nil, headers, function(code, body, responseHeaders)
		provider.busy = false
		if code == 401 or code == 403 then
			fail(provider, "Login expired or access denied; open " .. provider.name .. " CLI to sign in.")
			return
		end
		if code == 429 then
			local delay = REFRESH_SECONDS
			for key, value in pairs(responseHeaders or {}) do
				if key:lower() == "retry-after" then
					delay = math.max(delay, tonumber(value) or 0)
				end
			end
			provider.retryAt = os.time() + delay
			fail(provider, "Rate limited; retry after " .. timeText(provider.retryAt))
			return
		end
		if code ~= 200 then
			fail(
				provider,
				code < 0 and "Network unavailable; will retry." or ("Usage request failed (HTTP " .. code .. ").")
			)
			return
		end
		local payload = decode(body)
		local windows = payload and parse(payload) or {}
		if #windows == 0 then
			fail(provider, "Subscription limits unavailable in response.")
			return
		end
		provider.windows = windows
		provider.updatedAt = os.time()
		provider.error = nil
		provider.retryAt = nil
		updateMenu()
	end, "ignoreLocalAndRemoteCache", false)
end

local function fetchClaude(credentials)
	local oauth = credentials and credentials.claudeAiOauth
	if type(oauth) ~= "table" or not nonEmpty(oauth.accessToken) then
		fail(claude, "No Claude subscription login; run claude to sign in.")
		return
	end
	fetch(claude, "https://api.anthropic.com/api/oauth/usage", {
		Authorization = "Bearer " .. oauth.accessToken,
		["anthropic-beta"] = "oauth-2025-04-20",
		["User-Agent"] = "claude-code/2.1.0",
		Accept = "application/json",
	}, claudeWindows)
end

local function refreshClaude()
	if claude.busy or (claude.retryAt and os.time() < claude.retryAt) then
		return
	end
	claude.busy = true
	-- macOS Claude Code uses Keychain. No secret appears in process arguments.
	credentialTask = hs.task.new("/usr/bin/security", function(exitCode, stdout)
		credentialTask = nil
		credentialTimeout:stop()
		credentialTimeout = nil
		if exitCode ~= 0 then
			fail(claude, "Claude Keychain login unavailable; allow access or sign in with claude.")
			return
		end
		fetchClaude(decode(stdout))
	end, { "find-generic-password", "-s", "Claude Code-credentials", "-w" })
	if not credentialTask or not credentialTask:start() then
		credentialTask = nil
		fail(claude, "Could not read Claude Keychain login.")
		return
	end
	credentialTimeout = hs.timer.doAfter(60, function()
		-- Remove the callback before terminating so a late exit cannot start a request.
		credentialTask:setCallback(nil)
		credentialTask:terminate()
		credentialTask = nil
		credentialTimeout = nil
		fail(claude, "Keychain access timed out; click to retry.")
	end)
end

local function refreshCodex()
	if codex.busy or (codex.retryAt and os.time() < codex.retryAt) then
		return
	end
	codex.busy = true
	local credentials = readJSON((os.getenv("CODEX_HOME") or (home .. "/.codex")) .. "/auth.json")
	local tokens = credentials and credentials.tokens
	if type(tokens) ~= "table" or not nonEmpty(tokens.access_token) then
		fail(codex, "No Codex subscription login; run codex login.")
		return
	end
	local headers = {
		Authorization = "Bearer " .. tokens.access_token,
		Accept = "application/json",
		["User-Agent"] = "Hammerspoon-AI-Usage",
	}
	if nonEmpty(tokens.account_id) then
		headers["ChatGPT-Account-Id"] = tokens.account_id
	end
	fetch(codex, "https://chatgpt.com/backend-api/wham/usage", headers, codexWindows)
end

function aiUsage.refresh()
	if not menu then
		return
	end
	refreshClaude()
	refreshCodex()
end

function aiUsage.start()
	if refreshTimer then
		return
	end
	menu = hs.menubar.new()
	if not menu then
		return
	end
	menu:setClickCallback(aiUsage.refresh)
	updateMenu()
	aiUsage.refresh()
	refreshTimer = hs.timer.doEvery(REFRESH_SECONDS, aiUsage.refresh)
	usageHover.start(menu, aiUsage.snapshot)
end

return aiUsage
