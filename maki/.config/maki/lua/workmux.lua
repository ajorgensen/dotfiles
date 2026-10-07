-- Reports the focused session's status and title to workmux, so the tmux
-- window icon, `workmux status`, `workmux wait`, and the dashboard track maki.
-- Workmux reads the title from the tmux pane title. Outside tmux this does
-- nothing.

local WORKMUX_STATUS = {
  working = "working",
  needs_input = "waiting",
  idle = "done",
}

local last_status
local last_title

-- Runs a tmux-only shell snippet. $1 in the snippet is `arg`.
local function run_in_tmux(script, arg)
  local id, err = maki.fn.jobstart(
    { "sh", "-c", '[ -n "$TMUX" ] || exit 0; ' .. script, "sh", arg },
    { scope = "plugin", stdout = false, stderr = false }
  )
  if not id then
    maki.log.warn("workmux: job failed to start: " .. err)
  end
  return id
end

local function set_status(status)
  if status == last_status then
    return
  end
  last_status = status
  return run_in_tmux('command -v workmux >/dev/null && workmux set-window-status "$1"', status)
end

local function set_title(title)
  if title == last_title then
    return
  end
  last_title = title
  return run_in_tmux('tmux select-pane -t "$TMUX_PANE" -T "$1"', title)
end

local function title_for(session_title)
  if not session_title or session_title == "" then
    return "maki"
  end
  return "maki - " .. session_title
end

maki.api.create_autocmd("SessionStatusChanged", {
  callback = function(ev)
    if not ev.data.focused then
      return
    end
    set_title(title_for(ev.data.title))
    local status = WORKMUX_STATUS[ev.data.status]
    if not status then
      return
    end
    -- Startup reports idle before any work; do not show it as done.
    if status == "done" and last_status == nil then
      return
    end
    set_status(status)
  end,
})

maki.api.create_autocmd("SessionTitleChanged", {
  callback = function(ev)
    if not ev.data.focused then
      return
    end
    set_title(title_for(ev.data.title))
  end,
})

maki.api.create_autocmd("SessionEnd", {
  callback = function(ev)
    if ev.data.reason ~= "shutdown" then
      return
    end
    local wait_ms = math.min(ev.data.deadline_ms or 500, 500)
    local status_job = set_status("clear")
    local title_job = set_title("")
    if status_job then
      maki.fn.jobwait(status_job, wait_ms)
    end
    if title_job then
      maki.fn.jobwait(title_job, wait_ms)
    end
  end,
})
