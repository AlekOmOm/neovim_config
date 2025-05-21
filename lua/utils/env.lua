-- lua/utils/env.lua
-- Utilities for managing environment variables and .env files

local logger = require('utils.logger')
local paths = require('utils.paths')
local M = {}

-- Attempt to load environment variables from a .env file
-- @param env_file Path to .env file (default: .env in config root)
-- @return boolean Success status
function M.load_env(env_file)
  -- Default to .env in the Neovim config directory
  env_file = env_file or paths.join(paths.config_dir, '.env')
  
  logger.debug("Attempting to load .env from: " .. env_file)
  
  local f = io.open(env_file, "r")
  if not f then
    logger.debug("No .env file found at: " .. env_file)
    return false
  end
  
  local loaded_count = 0
  for line in f:lines() do
    -- Skip comments and empty lines
    if not line:match("^%s*#") and line:match("%S") then
      local key, value = line:match("^%s*(.-)%s*=%s*(.-)%s*$")
      if key and value then
        -- Remove quotes if present
        value = value:gsub('^"(.-)"$', '%1'):gsub("^'(.-)'$", '%1')
        -- Set environment variable
        vim.env[key] = value
        loaded_count = loaded_count + 1
      end
    end
  end
  f:close()
  
  logger.debug("Loaded " .. loaded_count .. " variables from .env file")
  return true
end

-- Get environment variable with fallback
-- @param key Environment variable name
-- @param default Default value if not found
-- @return Value or default
function M.get(key, default)
  local value = vim.env[key]
  if value and value ~= "" then
    return value
  end
  return default
end

-- Get boolean value from environment variable
-- @param key Environment variable name
-- @param default Default value if not found
-- @return boolean
function M.get_bool(key, default)
  local value = vim.env[key]
  if not value or value == "" then
    return default
  end
  
  value = value:lower()
  return value == "true" or value == "1" or value == "yes" or value == "y"
end

-- Get number value from environment variable
-- @param key Environment variable name
-- @param default Default value if not found
-- @return number
function M.get_number(key, default)
  local value = vim.env[key]
  if not value or value == "" then
    return default
  end
  
  local num = tonumber(value)
  if num then
    return num
  end
  return default
end

-- Get list value from environment variable (comma-separated)
-- @param key Environment variable name
-- @param default Default list if not found
-- @return table (list)
function M.get_list(key, default)
  local value = vim.env[key]
  if not value or value == "" then
    return default or {}
  end
  
  local list = {}
  for item in value:gmatch("([^,]+)") do
    table.insert(list, item:match("^%s*(.-)%s*$"))
  end
  return list
end

return M
