-- # plugins/telescope.lua


local telescope = require('telescope')
local actions = require('telescope.actions')
local previewers = require('telescope.previewers')
local uv = vim.loop

local builtin_maker = previewers.buffer_previewer_maker

local new_maker = function(filepath, bufnr, opts)
  filepath = vim.fn.expand(filepath)

  -- async stat (no lag on big trees)
  uv.fs_stat(filepath, function(stat)
    -- no stat? locked or nonexistent
    if not stat or stat.type ~= 'file' then
      return
    end

    -- >1 MB → don't preview (tweak as you like)
    if stat.size > 1024 * 1024 then
      return
    end

    -- binary mime? requires the *nix `file` cmd
    vim.system({ 'file', '--mime', '--brief', filepath }, {
      text = true,
    }, function(res)
      if res.code == 0 and not res.stdout:match('text') then
        return                     -- binary, skip
      end
      -- fall back to the stock previewer
      builtin_maker(filepath, bufnr, opts)
    end)
  end)
end

telescope.setup({
    defaults = {
        buffer_previewer_maker = new_maker,
        -- Default configuration for telescope goes here:
        prompt_prefix = "🔍 ",
        selection_caret = "❯ ",
        path_display = { "truncate" },
        file_ignore_patterns = {
            "%.git/",
            ".git/",
            "node_modules/",
            "*.log",
            "*.log.*",
            "target/",
            "bower_components/",
            ".next/",
            "__pycache__/",
            "venv/",
            ".venv/",
            "env/",
            "build/",
            "dist/",
            ".gradle/",
        },
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
    
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
    pickers = {
        find_files = {
            hidden = true,                               -- still show dotfiles
            follow = true,
            find_command = (function()
                local command = { "fdfind", "--type", "f", "--strip-cwd-prefix", "--hidden" }
                -- Get the ignore patterns from defaults. We are inside the setup call,
                -- but defaults might not be fully processed yet when this function is defined.
                -- It's safer to redefine or access them carefully.
                -- For simplicity here, we'll redefine. If this table is changed in defaults,
                -- it needs to be changed here too.
                local patterns_to_exclude = {
                    "%.git/",
                    ".git/",
                    "node_modules/",
                    "*.log",
                    "*.log.*",
                    "target/",
                    "bower_components/",
                    ".next/",
                    "__pycache__/",
                    "venv/",
                    ".venv/",
                    "env/",
                    "build/",
                    "dist/",
                    ".gradle/",
                }
                for _, pattern in ipairs(patterns_to_exclude) do
                    table.insert(command, "--exclude")
                    table.insert(command, pattern)
                end
                return command
            end)(),
        },
        live_grep = {
            
            additional_args = function()
                return { "--glob", "!.git/*" }           -- ripgrep version

            end,
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

-- soft-wrap & nice breaks in every telescope preview
vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(ev)
        if vim.bo[ev.buf].filetype == "TelescopePreview" then
            vim.wo[ev.win].wrap       = true
            vim.wo[ev.win].linebreak  = true
            vim.wo[ev.win].showbreak  = "↪ "   -- optional visual cue
        end
    end,
})

