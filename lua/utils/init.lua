-- ~/.config/nvim/lua/utils/init.lua
-- Initialize the utils module

-- util modules: 
-- 1. ./init_file.lua


local M = {}

M.init_file = require('utils.init_file')

-- Export the paths module
M.paths = require('utils.paths')

-- Add additional utility modules here as needed

return M

