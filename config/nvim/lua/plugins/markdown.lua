-- ~/.config/nvim/lua/plugins/markdown.lua
local M = {}

function M.setup()
    -- Markdown preview settings
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_command_for_global = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_browser = ""  -- Use default browser
    vim.g.mkdp_echo_preview_url = 1
    
    -- Emoji substitution for markdown files
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            -- Enable emoji completion
            vim.opt_local.complete:append("k")
            
            -- Add emoji substitution mappings
            vim.keymap.set("i", "<C-e>", "<C-x><C-k>", { buffer = true })
            
            -- Add a command to convert emoji shortcodes to Unicode
            vim.api.nvim_buf_create_user_command(0, "EmojiReplace", function()
                vim.cmd([[%s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g]])
            end, {})
            
            -- Add command to list all available emojis
            vim.api.nvim_buf_create_user_command(0, "EmojiList", function()
                vim.cmd('split __Emoji_List__')
                vim.api.nvim_buf_set_option(0, 'buftype', 'nofile')
                vim.api.nvim_buf_set_option(0, 'swapfile', false)
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
                
                local emoji_list = vim.fn['emoji#list']()
                local lines = {}
                for name, emoji in pairs(emoji_list) do
                    table.insert(lines, emoji .. " :" .. name .. ":")
                end
                table.sort(lines)
                vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            end, {})
        end,
    })
    
    -- Set keymaps for markdown files
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            -- Preview keymaps (existing)
            vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', { buffer = true })
            vim.keymap.set('n', '<leader>ms', ':MarkdownPreviewStop<CR>', { buffer = true })
            
            -- Add emoji-related keymaps
            vim.keymap.set('n', '<leader>me', ':EmojiList<CR>', { buffer = true })
            vim.keymap.set('n', '<leader>mr', ':EmojiReplace<CR>', { buffer = true })
        end,
    })
end

return M
