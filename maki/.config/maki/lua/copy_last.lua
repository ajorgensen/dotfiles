local ListPicker = require("maki.list_picker")

local function last_assistant_text()
  local msgs, err = maki.session.messages()
  if not msgs then
    return nil, err
  end

  for i = #msgs, 1, -1 do
    local msg = msgs[i]
    if msg.role == "assistant" and msg.kind == "turn" and not msg.hidden then
      local parts = {}
      for _, block in ipairs(msg.content) do
        if block.type == "text" and block.text ~= "" then
          parts[#parts + 1] = block.text
        end
      end
      if #parts > 0 then
        return table.concat(parts, "\n\n")
      end
    end
  end

  return nil, "No assistant response available"
end

local function quote_content(line)
  local indent, content = line:match("^( *)>[ \t]?(.*)$")
  if indent and #indent <= 3 then
    return content
  end
end

local function response_choices(text)
  local choices = { { label = "Whole response", text = text } }
  local lines = {}
  for line in (text:gsub("\r\n", "\n") .. "\n"):gmatch("(.-)\n") do
    lines[#lines + 1] = line
  end

  local i = 1
  while i <= #lines do
    local content = {}
    local kind
    local quoted = quote_content(lines[i])
    local indent, fence, info = lines[i]:match("^( *)([`~]+)(.*)$")
    if quoted then
      kind = "Quote"
      while i <= #lines and quote_content(lines[i]) do
        content[#content + 1] = quote_content(lines[i])
        i = i + 1
      end
    elseif
      fence
      and #indent <= 3
      and #fence >= 3
      and fence == fence:sub(1, 1):rep(#fence)
      and not (fence:sub(1, 1) == "`" and info:find("`", 1, true))
    then
      local language = info:match("^%s*(%S+)")
      kind = "Code block" .. (language and " (" .. language .. ")" or "")
      i = i + 1
      while i <= #lines do
        local closing_indent, closing = lines[i]:match("^( *)([`~]+)[ \t]*$")
        if closing and #closing_indent <= 3 and #closing >= #fence and closing == fence:sub(1, 1):rep(#closing) then
          break
        end
        local line = lines[i]
        for _ = 1, #indent do
          if line:sub(1, 1) ~= " " then
            break
          end
          line = line:sub(2)
        end
        content[#content + 1] = line
        i = i + 1
      end
      i = i + 1
    else
      i = i + 1
    end

    if kind then
      local value = table.concat(content, "\n")
      local preview = value:match("%S[^\n]*") or "(empty)"
      choices[#choices + 1] = {
        label = kind .. " " .. #choices .. ": " .. maki.ui.truncate_text(preview, 70).head,
        text = value,
      }
    end
  end
  return choices
end

local function select_response(title)
  local text, err = last_assistant_text()
  if not text then
    maki.ui.flash(err)
    return
  end
  local choices = response_choices(text)
  if #choices == 1 then
    return choices[1]
  end
  local event = ListPicker.open(choices, {
    title = title,
    footer = { { "Enter", "select" }, { "Esc", "cancel" } },
  })
  if event.type == "choice" then
    return event.item
  end
end

local function copy_response()
  local choice = select_response(" Copy what? ")
  if not choice then
    return
  end
  local id, err = maki.fn.jobstart({ "sh", "-c", 'printf %s "$1" | pbcopy', "sh", choice.text }, {
    scope = "plugin",
    on_exit = function(_, code)
      maki.ui.flash(code == 0 and "Copied " .. choice.label or "pbcopy failed")
    end,
  })
  if not id then
    maki.ui.flash("Copy failed: " .. tostring(err))
  end
end

local function ask_response()
  local before, err = maki.ui.input()
  if not before then
    maki.ui.flash("Ask failed: " .. tostring(err))
    return
  end
  local choice = select_response(" Ask about what? ")
  if not choice then
    return
  end
  local st, input_err = maki.ui.input()
  if not st then
    maki.ui.flash("Ask failed: " .. tostring(input_err))
    return
  end
  if st.session_id ~= before.session_id then
    maki.ui.flash("Ask cancelled: focused session changed")
    return
  end
  local quoted = "> " .. choice.text:gsub("\r\n", "\n"):gsub("\n", "\n> ") .. "\n\n"
  local ok, edit_err = maki.ui.input_edit({
    start = 0,
    stop = 0,
    text = quoted,
    cursor = #quoted + st.cursor,
    version = st.version,
    session_id = st.session_id,
  })
  if not ok then
    maki.ui.flash("Ask failed: " .. tostring(edit_err))
  end
end

maki.keymap.set("n", "<C-y>", copy_response, { desc = "Copy response or block" })

maki.api.register_command({
  name = "/copy-response",
  description = "Copy the last response, code block, or quoted passage",
  handler = copy_response,
})

maki.api.register_command({
  name = "/ask-response",
  description = "Quote the last response or a block in the input, without sending",
  handler = ask_response,
})
