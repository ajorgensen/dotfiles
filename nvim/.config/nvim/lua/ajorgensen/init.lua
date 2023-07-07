require("ajorgensen.set")
require("ajorgensen.remap")
require("ajorgensen.lazy")
require("ajorgensen.autocmd")

local augroup = vim.api.nvim_create_augroup
local myGroup = augroup('ajorgensen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require('plenary.reload').reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})


autocmd({'BufWritePre'}, {
    group = myGroup,
    pattern = '*',
    command = [[%s/\s\+$//e]],
})
