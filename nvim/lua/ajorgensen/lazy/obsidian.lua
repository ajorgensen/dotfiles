return {
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function() 
            vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianBacklinks<CR>", { desc = "Obsidian Backlinks" })
            vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Obsidian New Note" })
            vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { desc = "Obsidian Today" })
            vim.keymap.set("n", "<leader>oy", "<cmd>ObsidianYesterday<CR>", { desc = "Obsidian Yesterday" })
            vim.keymap.set("n", "<leader>or", "<cmd>ObsidianTomorrow<CR>", { desc = "Obsidian Tomorrow" })

            require("obsidian").setup({ 
                new_notes_location = "notes_subdir",
                workspaces = {
                    {
                        name = "personal",
                        path = "~/vaults/tardis",
                        overrides = {
                            notes_subdir = "$in",
                        },
                    }
                },
                daily_notes = {
                    -- Optional, if you keep daily notes in a separate directory.
                    folder = "notes/dailies",
                    -- Optional, if you want to change the date format for the ID of daily notes.
                    date_format = "%Y-%m-%d",
                    -- Optional, if you want to change the date format of the default alias of daily notes.
                    alias_format = "%B %-d, %Y",
                    -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
                    template = nil
                },

                note_id_func = function(title)
                    -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                    -- In this case a note with the title 'My new note' will be given an ID that looks
                    -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
                    local suffix = ""
                    if title ~= nil then
                        -- If title is given, transform it into valid file name.
                        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                    else
                        -- If title is nil, just add 4 random uppercase letters to the suffix.
                        for _ = 1, 4 do
                            suffix = suffix .. string.char(math.random(65, 90))
                        end
                    end
                    -- return tostring(os.time()) .. "-" .. suffix
                    return suffix
                end,

                
                templates = {
                    subdir = "templates",
                    date_format = "%Y-%m-%d-%a",
                    time_format = "%H:%M",
                },

                ui = {
                    enable = false,
                },
            })
        end
    }
}
