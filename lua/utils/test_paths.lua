-- Test file for paths module
-- Run with :lua dofile('lua/utils/test_paths.lua')

-- Import the paths module directly
local paths_file = vim.fn.getcwd() .. '/lua/utils/paths.lua'
local paths = dofile(paths_file)

-- Test and print results
print("Testing paths utility module...")
print("------------------------------")
print("config_dir:", paths.NVIM.CONFIG)
print("data_dir:", paths.NVIM.DATA)
print("cache_dir:", paths.NVIM.CACHE) 
print("state_dir:", paths.NVIM.STATE)
print("path_sep:", paths.path_sep)
print("home_dir:", paths.HOME)

-- Test join function
local test_path = paths.join(paths.NVIM.CONFIG, "lua", "utils", "paths.lua")
print("\nTest join:")
print("Joined path:", test_path)

-- Test to_absolute function
print("\nTest to_absolute:")
print("Relative 'lua/utils/paths.lua' to absolute:", paths.to_absolute("lua/utils/paths.lua"))
print("Already absolute path:", paths.to_absolute(paths.NVIM.CONFIG))

-- Test relative_to_config
print("\nTest relative_to_config:")
local abs_path = paths.join(paths.NVIM.CONFIG, "lua", "utils", "paths.lua")
print("Original:", abs_path)
print("Relative:", paths.relative_to_config(abs_path))

print("\nTest ensure_dir:")
local test_dir = paths.join(paths.NVIM.CACHE, "test_path_utils")
print("Creating directory:", test_dir)
local success = paths.ensure_dir(test_dir)
print("Directory created/exists:", success)

print("\nPaths module test completed.") 