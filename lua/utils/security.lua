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
-- Initialize allowed commands with defaults
M.allowed_commands = {
  "git", "nvim", "npm", "node", "python", "python3", "lua", "make", "gcc",
  "clang", "cp", "mv", "mkdir", "ls", "find", "grep", "sed", "awk"
}

-- Check for environment variable override
local env_allowed_commands = os.getenv("NVIM_SECURITY_ALLOWED_COMMANDS")
if env_allowed_commands then
  -- Split the environment variable value into a table
  M.allowed_commands = {}
  for command in env_allowed_commands:gmatch("[^,]+") do
    local trimmed_command = command:match("^%s*(.-)%s*$") -- Trim whitespace
    if trimmed_command and trimmed_command ~= "" then
      table.insert(M.allowed_commands, trimmed_command)
    end
  end
  -- Ensure we didn't end up with empty allowed commands
  if #M.allowed_commands == 0 then
    vim.notify("WARNING: NVIM_SECURITY_ALLOWED_COMMANDS parsed to empty list, using defaults", vim.log.levels.WARN)
    M.allowed_commands = {"git", "nvim", "npm", "node", "python", "python3"}
  end
end

-- Define allowed directories for file operations
local env_allowed_dirs = os.getenv("NVIM_SECURITY_ALLOWED_DIRS")
if env_allowed_dirs then
  M.allowed_directories = {}
  for dir in env_allowed_dirs:gmatch("([^:]+)") do
    local trimmed_dir = dir:match("^%s*(.-)%s*$") -- Trim whitespace
    if trimmed_dir and trimmed_dir ~= "" then
      table.insert(M.allowed_directories, trimmed_dir)
    end
  end
  -- Ensure we didn't end up with empty allowed directories
  if #M.allowed_directories == 0 then
    vim.notify("WARNING: NVIM_SECURITY_ALLOWED_DIRS parsed to empty list, using defaults", vim.log.levels.WARN)
    M.allowed_directories = {
      paths.NVIM.CONFIG,
      paths.NVIM.DATA,
      paths.NVIM.STATE,
      paths.NVIM.CACHE
    }
  end
else
  M.allowed_directories = {
    paths.NVIM.CONFIG,
    paths.NVIM.DATA,
    paths.NVIM.STATE,
    paths.NVIM.CACHE
  }
end

-- Check if a file might contain sensitive information
-- @param filepath Path to the file
-- @return boolean True if file might contain sensitive data
function M.might_contain_sensitive_data(filepath)
  local f, err = io.open(filepath, "r")
  if not f then
    vim.notify("Could not check file for sensitive data: " .. (err or "unknown error"), vim.log.levels.WARN)
    return false
  end
  
  local content, read_err = f:read("*all")
  f:close()
  
  if not content then
    vim.notify("Could not read file content: " .. (read_err or "unknown error"), vim.log.levels.WARN)
    return false
  end
  
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
  local f, err = io.open(filepath, "w")
  if not f then
    vim.notify("Failed to open file for writing: " .. filepath, vim.log.levels.ERROR)
    if err then
      vim.notify("Error: " .. err, vim.log.levels.ERROR)
    end
    return false 
  end
  
  local success, write_err = pcall(function() f:write(content) end)
  f:close()
  
  if not success then
    vim.notify("Failed to write to file: " .. (write_err or "unknown error"), vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Check if a path is within allowed directories
-- @param path Path to check
-- @return boolean True if path is allowed
function M.is_path_allowed(path)
  local norm_path = vim.fn.fnamemodify(path, ":p")
  
  -- Try to get real path if the filesystem supports it
  local real_path = norm_path
  pcall(function()
    if vim.loop.fs_realpath then
      real_path = vim.loop.fs_realpath(norm_path) or norm_path
    end
  end)
  
  for _, dir in ipairs(M.allowed_directories) do
    local norm_dir = vim.fn.fnamemodify(dir, ":p")
    
    -- Try to get real path for the directory too
    local real_dir = norm_dir
    pcall(function()
      if vim.loop.fs_realpath then
        real_dir = vim.loop.fs_realpath(norm_dir) or norm_dir
      end
    end)
    
    -- Check if path has the allowed directory as prefix
    if real_path:sub(1, #real_dir) == real_dir then
      -- Extra check to prevent prefix attacks
      local next_char = real_path:sub(#real_dir + 1, #real_dir + 1)
      if next_char == '/' or next_char == '\\' or next_char == '' then
        return true
      end
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
  
  local f, err = io.open(filepath, "r")
  if not f then
    return nil, "Failed to open file: " .. filepath .. (err and (": " .. err) or "")
  end
  
  local content, read_err = f:read("*all")
  f:close()
  
  if not content then
    return nil, "Failed to read file content: " .. (read_err or "unknown error")
  end
  
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
  
  -- Additional check for shell metacharacters in arguments
  local has_shell_metacharacters = cmd:match("[;&|<>$`\\!]")
  if has_shell_metacharacters then
    vim.notify("WARNING: Command contains shell metacharacters: " .. cmd, vim.log.levels.WARN)
    allowed = false
  end
  
  if not allowed and not force then
    vim.notify("WARNING: Potentially unsafe command: " .. cmd, vim.log.levels.WARN)
    local confirm = vim.fn.input("Execute anyway? (y/N): ")
    if confirm:lower() ~= "y" then
      return nil, "Command execution cancelled"
    end
  end
  
  -- Try to use plenary.job if available to avoid shell injection risks
  local has_plenary = pcall(require, 'plenary.job')
  if has_plenary then
    local Job = require('plenary.job')
    local args = {}
    -- Parse command into arguments
    for arg in cmd:gmatch("%S+") do
      if #args == 0 then
        -- First argument is the command itself, save it
        table.insert(args, arg)
      else
        -- Subsequent arguments
        table.insert(args, arg)
      end
    end
    
    local command = args[1]
    table.remove(args, 1) -- Remove command from args list
    
    local result = {}
    local code
    Job:new({
      command = command,
      args = args,
      on_stdout = function(_, data) table.insert(result, data) end,
      on_exit = function(_, exit_code) code = exit_code end,
    }):sync()
    
    return table.concat(result, '\n'), code == 0
  else
    -- Fallback to io.popen, but with warnings
    vim.notify("WARNING: Using less secure io.popen for command execution - plenary.nvim not available", vim.log.levels.WARN)
    local handle = io.popen(cmd)
    if not handle then return nil, "Failed to execute command" end
    
    local result = handle:read("*a")
    local success = handle:close()
    
    return result, success
  end
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
      -- Escape pattern special characters
      local escaped_hostname = hostname:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
      content = content:gsub(escaped_hostname, "<HOSTNAME>")
    end
  end
  
  return content
end

return M
