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

  return nil, "no agent message to copy"
end

maki.keymap.set("n", "<C-y>", function()
  local text, err = last_assistant_text()
  if not text then
    maki.ui.flash(err)
    return
  end

  local id, start_err = maki.fn.jobstart({ "sh", "-c", 'printf %s "$1" | pbcopy', "sh", text }, {
    scope = "plugin",
    on_exit = function(_, code)
      maki.ui.flash(code == 0 and "Copied last agent message" or "pbcopy failed")
    end,
  })
  if not id then
    maki.ui.flash("copy failed: " .. start_err)
  end
end, { desc = "Copy last agent message" })
