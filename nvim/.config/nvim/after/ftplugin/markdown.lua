vim.opt_local.linebreak = true
vim.opt_local.wrap = true

local function complete_mention_path()
  require("cmp").complete({
    config = {
      sources = {
        { name = "mention_path" },
      },
    },
  })
end

vim.keymap.set("i", "<C-x>@", complete_mention_path, {
  buffer = true,
  desc = "Insert file path (@-mention)",
})

vim.keymap.set("i", "@<C-x>", function()
  vim.schedule(complete_mention_path)
  return "@"
end, {
  buffer = true,
  desc = "Insert @ and complete file path",
  expr = true,
})
