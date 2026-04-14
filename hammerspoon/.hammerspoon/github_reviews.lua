local githubReviews = {}

local REFRESH_INTERVAL_SECONDS = 300
local REVIEW_QUERY = "is:open is:pr review-requested:@me archived:false"
local REVIEW_URL = "https://github.com/pulls?q=is%3Aopen+is%3Apr+review-requested%3A%40me+archived%3Afalse"

local menubar = hs.menubar.new()
local refreshTimer = nil
local activeTask = nil
local ghPath = nil

local function updateMenubar(title, tooltip)
  if not menubar then
    return
  end

  menubar:setTitle(title)
  menubar:setTooltip(tooltip)
end

local function githubCliPath()
  if ghPath then
    return ghPath
  end

  for _, path in ipairs({ "/opt/homebrew/bin/gh", "/usr/local/bin/gh", "/usr/bin/gh" }) do
    if hs.fs.attributes(path) then
      ghPath = path
      return ghPath
    end
  end

  return nil
end

local function setCount(count)
  if count > 0 then
    updateMenubar(string.format("GH %d", count), string.format("%d pull requests need your review", count))
    return
  end

  updateMenubar("GH", "No pull requests currently request your review")
end

local function setError(message)
  updateMenubar("GH!", message)
end

local function refresh()
  if activeTask then
    return
  end

  local cli = githubCliPath()
  if not cli then
    setError("GitHub CLI not found at a standard path")
    return
  end

  activeTask = hs.task.new(cli, function(exitCode, stdout, stderr)
    activeTask = nil

    if exitCode ~= 0 then
      local errorMessage = stderr and stderr:gsub("%s+$", "") or ""
      if errorMessage == "" then
        errorMessage = "Failed to fetch GitHub review requests"
      end
      setError(errorMessage)
      return
    end

    local payload = hs.json.decode(stdout)
    if not payload or type(payload.total_count) ~= "number" then
      setError("Unexpected response from GitHub CLI")
      return
    end

    setCount(payload.total_count)
  end, {
    "api",
    "search/issues",
    "--method",
    "GET",
    "-f",
    "q=" .. REVIEW_QUERY,
    "-f",
    "per_page=1",
  })

  if not activeTask then
    setError("Unable to start GitHub CLI task")
    return
  end

  if not activeTask:start() then
    activeTask = nil
    setError("Unable to start GitHub CLI task")
  end
end

function githubReviews.start()
  if not menubar then
    return
  end

  menubar:setClickCallback(function(modifiers)
    if modifiers and modifiers.ctrl then
      refresh()
    else
      hs.urlevent.openURL(REVIEW_URL)
    end
  end)

  setCount(0)
  refresh()

  if refreshTimer then
    refreshTimer:stop()
  end

  refreshTimer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, refresh)
end

return githubReviews
