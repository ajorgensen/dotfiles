-- /skill: browse the skills the `skill` tool can load, and hand one to the model.
--
-- Discovery mirrors maki's bundled skill plugin (same dirs, same order, later
-- dirs win on name clashes), so the picker shows what the model can load.

local ListPicker = require("maki.list_picker")

local SKILL_FILE = "SKILL.md"
local PROJECT_SKILL_DIRS = { ".maki/skills", ".claude/skills", ".opencode/skills", ".agents/skills" }
local GLOBAL_SKILL_DIRS = { ".claude/skills", ".config/opencode/skills", ".agents/skills" }

local function parse_frontmatter(content)
  local fm_text, body = content:match("^%-%-%-\r?\n(.-)\r?\n%-%-%-\r?\n?(.*)$")
  if not fm_text then
    return {}, content
  end
  local fm = maki.yaml.decode(fm_text)
  if type(fm) ~= "table" then
    return {}, body
  end
  return fm, body
end

local function scan(dir, scope, skills)
  local entries = maki.fs.dir(dir)
  if not entries then
    return
  end
  for _, entry in ipairs(entries) do
    local content = entry[2] == "directory" and maki.fs.read(maki.fs.joinpath(dir, entry[1], SKILL_FILE))
    if content then
      local fm, body = parse_frontmatter(content)
      if body:match("%S") then
        local name = type(fm.name) == "string" and fm.name or entry[1]
        skills[name] = {
          name = name,
          description = type(fm.description) == "string" and fm.description or "",
          scope = scope,
        }
      end
    end
  end
end

local function project_ancestors()
  local cwd = maki.uv.cwd()
  if not cwd then
    return {}
  end
  local dirs = { cwd }
  if maki.fs.metadata(maki.fs.joinpath(cwd, ".git")) then
    return dirs
  end
  for _, parent in ipairs(maki.fs.parents(cwd)) do
    dirs[#dirs + 1] = parent
    if maki.fs.metadata(maki.fs.joinpath(parent, ".git")) then
      break
    end
  end
  return dirs
end

local function discover()
  local skills = {}
  local config = maki.env.config_dir()
  if config then
    scan(maki.fs.joinpath(config, "skills"), "global", skills)
  end
  local home = maki.uv.os_homedir()
  if home then
    for _, rel in ipairs(GLOBAL_SKILL_DIRS) do
      scan(maki.fs.joinpath(home, rel), "global", skills)
    end
  end
  for _, ancestor in ipairs(project_ancestors()) do
    for _, rel in ipairs(PROJECT_SKILL_DIRS) do
      scan(maki.fs.joinpath(ancestor, rel), "project", skills)
    end
  end
  return skills
end

local function sorted_items(skills)
  local items = {}
  for _, s in pairs(skills) do
    items[#items + 1] = { label = s.name, detail = s.description, section = s.scope }
  end
  table.sort(items, function(a, b)
    if a.section ~= b.section then
      return a.section == "project"
    end
    return a.label < b.label
  end)
  return items
end

local function skill_prompt(name)
  return "Use the `" .. name .. "` skill: "
end

-- Leaves the prompt in the input so the user can add the task before sending.
local function stage(name)
  local st, err = maki.ui.input()
  if not st then
    maki.ui.flash("/skill: " .. tostring(err))
    return
  end
  local ok, edit_err = maki.ui.input_edit({
    start = st.cursor,
    stop = st.cursor,
    text = skill_prompt(name),
    version = st.version,
    session_id = st.session_id,
  })
  if not ok then
    maki.ui.flash("/skill: " .. tostring(edit_err))
  end
end

local function pick(skills)
  local items = sorted_items(skills)
  if #items == 0 then
    maki.ui.flash("No skills found")
    return
  end
  local event = ListPicker.open(items, {
    title = " Skills ",
    footer = { { "Enter", "use skill" } },
  })
  if event.type ~= "choice" then
    return
  end
  stage(event.item.label)
end

maki.api.register_command({
  name = "/skill",
  description = "Browse skills, or run one: /skill [name] [task]",
  nargs = "*",
  handler = function(opts)
    local skills = discover()
    local name, task = opts.args:match("^%s*(%S*)%s*(.-)%s*$")
    if name == "" then
      pick(skills)
      return
    end
    if not skills[name] then
      maki.ui.flash("Unknown skill: " .. name)
      return
    end
    if task == "" then
      stage(name)
      return
    end
    local _, err = maki.session.prompt(skill_prompt(name) .. task)
    if err then
      maki.ui.flash("/skill: " .. tostring(err))
    end
  end,
})
