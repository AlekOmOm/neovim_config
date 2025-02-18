-- lua/plugins/copilot.lua
-- Copilot plugin configuration
-- ============================================================================

-- -- copilot settings
-- - key sequence: <C-J> => hotkeys: ctrl + j, ctrl + k, ctrl + l (for accept, next, previous)
vim.g.copilot_no_tab_map = false
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })


