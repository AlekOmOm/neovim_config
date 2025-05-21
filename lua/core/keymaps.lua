-- # ~/.config/nvim/lua/core/keymaps.lua
-- Import the paths utility module for consistency with other core modules
local paths = require('utils.paths')
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Telescope
map('n', '<leader>ff', ':Telescope find_files<CR>', opts)
map('n', '<leader>fg', ':Telescope git_files<CR>', opts)
map('n', '<leader>fb', ':Telescope buffers<CR>', opts)

-- Refactoring
vim.keymap.set("n", "<leader>rn", ":IncRename ")
vim.keymap.set("v", "<leader>re", ":Refactor extract ")
vim.keymap.set("v", "<leader>rf", ":Refactor extract_to_file ")

-- markdown keymaps
vim.api.nvim_set_keymap('n', '<leader>mp', ':MarkdownPreview<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>ms', ':MarkdownCompile<CR>', opts)

