-- # plugins/telescope.lua


local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup({
    defaults = {
        -- Default configuration for telescope goes here:
        prompt_prefix = "🔍 ",
        selection_caret = "❯ ",
        path_display = { "truncate" },
        
        mappings = {
            i = {
                ["<C-n>"] = actions.cycle_history_next,
                ["<C-p>"] = actions.cycle_history_prev,
                
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                
                ["<C-c>"] = actions.close,
                ["<CR>"] = actions.select_default,
                ["<C-x>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,
                
                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,
            },
            
            n = {
                ["<esc>"] = actions.close,
                ["<CR>"] = actions.select_default,
                ["<C-x>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,
                
                ["j"] = actions.move_selection_next,
                ["k"] = actions.move_selection_previous,
                ["H"] = actions.move_to_top,
                ["M"] = actions.move_to_middle,
                ["L"] = actions.move_to_bottom,
                
                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,
            },
        },
    },
    pickers = {
        -- Default configuration for builtin pickers goes here:
        find_files = {
            theme = "dropdown",
            previewer = false,
        },
        git_files = {
            theme = "dropdown",
            previewer = false,
        },
        buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
            mappings = {
                n = {
                    ["dd"] = actions.delete_buffer,
                },
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})

-- Load telescope extensions
local status_ok, _ = pcall(telescope.load_extension, 'fzf')
if not status_ok then
    -- silently fail if fzf extension isn't available
    -- you can optionally print a message here

    print("Failed to load fzf extension")

end
