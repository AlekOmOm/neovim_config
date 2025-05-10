local M = {}

M.levels = {
  NONE = 0,
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  DEBUG = 4,
}

-- Global log level setting
-- To change this, call logger.set_level("DEBUG") for example, from init.lua
M.current_level_name = "ERROR" -- Default to ERROR as requested
M.current_level = M.levels[M.current_level_name]

local function get_level_prefix(level_value)
  for name, value in pairs(M.levels) do
    if value == level_value then
      return string.format("[%s]", name)
    end
  end
  return "[UNKNOWN]"
end

function M.set_level(level_name)
  level_name = string.upper(level_name)
  if M.levels[level_name] then
    M.current_level_name = level_name
    M.current_level = M.levels[level_name]
    if M.current_level >= M.levels.INFO then -- Only print confirmation if level is INFO or more verbose
      print(string.format("%s Log level set to %s", get_level_prefix(M.levels.INFO), M.current_level_name))
    end
  elseif M.current_level >= M.levels.WARN then
    print(string.format("%s Invalid log level: %s. Keeping current level: %s", get_level_prefix(M.levels.WARN), level_name, M.current_level_name))
  end
end

function M.log(level_name, ...)
  level_name = string.upper(level_name)
  local message_level = M.levels[level_name]

  if message_level and message_level <= M.current_level then
    local message_args = {...} -- pack all varargs into a table
    local message_parts = {}
    for i = 1, #message_args do
        table.insert(message_parts, tostring(message_args[i]))
    end
    local message = table.concat(message_parts, " ") -- concatenate all parts with spaces
    print(string.format("%s %s", get_level_prefix(message_level), message))
  end
end

-- Convenience functions
function M.error(...) M.log("ERROR", ...) end
function M.warn(...)  M.log("WARN", ...)  end
function M.info(...)  M.log("INFO", ...)  end
function M.debug(...) M.log("DEBUG", ...) end

return M 