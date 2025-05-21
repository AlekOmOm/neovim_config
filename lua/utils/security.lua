-- lua/utils/security.lua
-- Security utilities for Neovim configuration

local logger = require('utils.logger')
local paths = require('utils.paths')
local M = {}

-- List of patterns for sensitive information
M.sensitive_patterns = {
  "token", "key", "secret", "password", "credential", "auth", "apikey"
}

-- List of allowed command prefixes for safe execution
M.allowed_commands = {
  "git", "nvim", "npm", "node", "python", "python3", "lua", "make", "gcc",
  "clang", "cp", "mv", "mkdir", "ls", "find", "grep", "sed", "awk"
}

-- Define allowed directories for file operations
M.allowed_directories = {
  paths.NVIM.CONFIG,
  paths.NVIM.DATA,
  paths.NVIM.STATE,
  paths.NVIM.CACHE
}

-- Check if a file might contain sensitive information
-- @param filepath Path to the file
-- @return boolean True if file might contain sensitive data
function M.might_contain_sensitive_data(filepath)
  local f = io.open(filepath, "r")
  if not f then return false end
  
  local content = f:read("*all")
  f:close()
  
  for _, pattern in ipairs(M.sensitive_patterns) do
    if content:lower():match(pattern) then
      return true
    end
  end
  return false
end

-- Safe file writing with sensitive content check
-- @param filepath Path to write to
-- @param content Content to write
-- @param force Skip confirmation (default: false)
-- @return boolean Success status
function M.safe_write(filepath, content, force)
  -- Check for sensitive content
  local has_sensitive = false
  for _, pattern in ipairs(M.sensitive_patterns) do
    if type(content) == "string" and content:lower():match(pattern) then
      has_sensitive = true
      break
    end
  end
  
  -- Warn and confirm if sensitive content detected
  if has_sensitive and not force then
    vim.notify("WARNING: Content appears to contain sensitive information", vim.log.levels.WARN)
    local confirm = vim.fn.input("Write anyway? (y/N): ")
    if confirm:lower() ~= "y" then
      return false
    end
  end
  
  -- Check if path is allowed
  if not M.is_path_allowed(filepath) and not force then
    vim.notify("WARNING: Writing to path outside allowed directories: " .. filepath, vim.log.levels.WARN)
    local confirm = vim.fn.input("Write anyway? (y/N): ")
    if confirm:lower() ~= "y" then
      return false
    end
  end
  
  -- Write the file
  local f = io.open(filepath, "w")
  if not f then 
    vim.notify("Failed to open file for writing: " .. filepath, vim.log.levels.ERROR)
    return false 
  end
  
  f:write(content)
  f:close()
  return true
end

-- Check if a path is within allowed directories
-- @param path Path to check
-- @return boolean True if path is allowed
function M.is_path_allowed(path)
  local norm_path = vim.fn.fnamemodify(path, ":p")
  
  for _, dir in ipairs(M.allowed_directories) do
    local norm_dir = vim.fn.fnamemodify(dir, ":p")
    if norm_path:sub(1, #norm_dir) == norm_dir then
      return true
    end
  end
  
  return false
end

-- Safe file reading
-- @param filepath Path to read
-- @param force Skip confirmation for non-allowed paths
-- @return string|nil Content or nil on error
-- @return string|nil Error message on failure
function M.safe_read(filepath, force)
  -- Check if path is allowed
  if not M.is_path_allowed(filepath) and not force then
    vim.notify("WARNING: Reading from path outside allowed directories: " .. filepath, vim.log.levels.WARN)
    local confirm = vim.fn.input("Read anyway? (y/N): ")
    if confirm:lower() ~= "y" then
      return nil, "Operation cancelled"
    end
  end
  
  local f = io.open(filepath, "r")
  if not f then
    return nil, "Failed to open file: " .. filepath
  end
  
  local content = f:read("*all")
  f:close()
  return content
end

-- Execute command safely
-- @param cmd Command to execute
-- @param force Skip confirmation for non-allowed commands
-- @return string|nil Output or nil on error
-- @return boolean|string Success flag or error message
function M.safe_execute(cmd, force)
  -- Check if command starts with an allowed prefix
  local command_base = cmd:match("^%s*(%S+)")
  local allowed = false
  
  for _, allowed_cmd in ipairs(M.allowed_commands) do
    if command_base == allowed_cmd then
      allowed = true
      break
    end
  end
  
  if not allowed and not force then
    vim.notify("WARNING: Potentially unsafe command: " .. cmd, vim.log.levels.WARN)
    local confirm = vim.fn.input("Execute anyway? (y/N): ")
    if confirm:lower() ~= "y" then
      return nil, "Command execution cancelled"
    end
  end
  
  -- Execute the command
  local handle = io.popen(cmd)
  if not handle then return nil, "Failed to execute command" end
  
  local result = handle:read("*a")
  local success = handle:close()
  
  return result, success
end

-- Redact personal information from outputs
-- @param content Content to redact
-- @return string Redacted content
function M.redact_personal_info(content)
  if type(content) ~= "string" then return content end
  
  -- Redact home directory paths
  local home = vim.fn.expand("~"):gsub("%-", "%%-") -- Escape for pattern matching
  content = content:gsub(home, "~")
  
  -- Redact username
  local username = vim.env.USER or vim.fn.expand("$USER")
  if username and username ~= "" then
    content = content:gsub(username, "<USERNAME>")
  end
  
  -- Try to load env module, but don't fail if it's not available yet
  local env = nil
  pcall(function() env = require('utils.env') end)
  
  -- Redact hostnames
  local hostnames = {
    vim.fn.hostname()
  }
  
  -- Add environment hostnames if env module is available
  if env then
    table.insert(hostnames, env.get("NVIM_HOSTNAME"))
    table.insert(hostnames, env.get("NVIM_MAIN_LAPTOP"))
    table.insert(hostnames, env.get("NVIM_STATIONARY"))
  end
  
  for _, hostname in ipairs(hostnames) do
    if hostname and hostname ~= "" then
      content = content:gsub(hostname, "<HOSTNAME>")
    end
  end
  
  return content
end

return M
