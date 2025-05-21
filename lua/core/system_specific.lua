local M = {}
local logger = require('utils.logger')

-- Load environment variables from .env file if available
local env_ok, env = pcall(require, 'utils.env')
if env_ok then
  env.load_env() -- Load .env file from config directory
  logger.debug("Environment variables loaded")
else
  logger.debug("utils.env module not available, skipping .env loading")
end

-- Environment override for testing (set before requiring this module)
-- Example usage: vim.g.system_override = { hostname = "DESKTOP-19QVLUP" }
local override = vim.g.system_override or {}

-- Get hostname with override support for testing
M.hostname = override.hostname or (env_ok and env.get("NVIM_HOSTNAME")) or vim.fn.hostname()

-- Get OS type with override support for testing
local uname = vim.loop.os_uname()
if override.os_type then
  M.os_type = override.os_type
elseif uname then
  M.os_type = uname.sysname
else
  -- Fallback for headless or minimal environments
  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    M.os_type = "Windows_NT"
  elseif vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
    M.os_type = "Darwin"
  else
    M.os_type = "Linux" -- Default to Linux if unsure
  end
end

M.is_windows = M.os_type == "Windows_NT"
M.is_linux = M.os_type == "Linux"
M.is_mac = M.os_type == "Darwin"

-- Known machine hostnames (from environment variables if available)
M.MAIN_LAPTOP = (env_ok and env.get("NVIM_MAIN_LAPTOP")) or "DESKTOP-V2L884C"  -- Main laptop with devdrive
M.STATIONARY = (env_ok and env.get("NVIM_STATIONARY")) or "DESKTOP-19QVLUP"   -- Stationary desktop

-- Machine type detection based on known hostnames
M.is_desktop = M.hostname == M.STATIONARY
M.is_laptop = M.hostname == M.MAIN_LAPTOP or (not M.is_desktop and not string.match(M.hostname, "DESKTOP"))
M.is_main_laptop = M.hostname == M.MAIN_LAPTOP
M.is_stationary = M.hostname == M.STATIONARY
M.has_devdrive = M.hostname == M.MAIN_LAPTOP -- Only the main laptop has devdrive

--- Applies system-specific settings.
-- This function will be expanded to load configurations based on hostname or OS.
function M.apply_system_settings()
  logger.info("Applying system-specific settings for: " .. M.hostname .. " (" .. M.os_type .. ")")
  logger.debug("Is Desktop: " .. tostring(M.is_desktop))
  logger.debug("Is Laptop: " .. tostring(M.is_laptop))

  -- OS-specific settings
  if M.is_windows then
    logger.info("Applying Windows-specific settings")
    -- vim.cmd("set shellslash")
    -- Additional Windows-specific settings
  end

  if M.is_linux then
    logger.info("Applying Linux-specific settings")
    -- Linux-specific settings
  end

  if M.is_mac then
    logger.info("Applying macOS-specific settings")
    -- macOS-specific settings
  end

  -- Machine-specific settings
  if M.is_main_laptop then
    logger.info("Applying settings for main laptop (" .. M.MAIN_LAPTOP .. ")")
    -- Main laptop specific settings
    
    if M.has_devdrive then
      logger.info("Configuring devdrive settings")
      -- Settings specific to devdrive on main laptop
      -- Example: Configure project paths or dev tools specific to devdrive
    end
  elseif M.is_stationary then
    logger.info("Applying settings for stationary computer (" .. M.STATIONARY .. ")")
    -- Stationary computer specific settings
    -- Example: Configure for larger screen or different performance profile
  else
    logger.info("Applying generic settings for unknown computer")
    -- Generic settings for unknown machines
  end

  -- Try to load machine-specific module if it exists
  local host_specific_module = "conf.machines." .. M.hostname:lower():gsub("%-", "_")
  local success, host_module = pcall(require, host_specific_module)
  if success then
    logger.info("Loading machine-specific module: " .. host_specific_module)
    if type(host_module.setup) == "function" then
      host_module.setup()
    end
  else
    logger.debug("No specific module found for " .. M.hostname)
  end
end

-- Test function to simulate different environments
function M.test_environment(hostname, os_type)
  logger.info("\n--- Testing with simulated environment ---")
  logger.debug("Original hostname: " .. M.hostname)
  logger.debug("Original OS type: " .. M.os_type)
  
  -- Create a new module instance with overrides
  local test_module = require("core.system_specific")
  local mt = getmetatable(test_module) or {}
  mt.__index = mt.__index or test_module
  
  -- Create a new module with overridden values
  local test = setmetatable({}, mt)
  test.hostname = hostname or M.hostname
  test.os_type = os_type or M.os_type
  
  -- Update derived properties
  test.is_windows = test.os_type == "Windows_NT"
  test.is_linux = test.os_type == "Linux"
  test.is_mac = test.os_type == "Darwin"
  test.is_desktop = test.hostname == M.STATIONARY
  test.is_laptop = test.hostname == M.MAIN_LAPTOP or (not test.is_desktop and not string.match(test.hostname, "DESKTOP"))
  test.is_main_laptop = test.hostname == M.MAIN_LAPTOP
  test.is_stationary = test.hostname == M.STATIONARY
  test.has_devdrive = test.hostname == M.MAIN_LAPTOP
  
  logger.info("Simulated hostname: " .. test.hostname)
  logger.info("Simulated OS type: " .. test.os_type)
  logger.debug("Is Windows: " .. tostring(test.is_windows))
  logger.debug("Is Desktop: " .. tostring(test.is_desktop))
  logger.debug("Is Laptop: " .. tostring(test.is_laptop))
  logger.debug("Is Main Laptop: " .. tostring(test.is_main_laptop))
  logger.debug("Is Stationary: " .. tostring(test.is_stationary))
  logger.debug("Has Devdrive: " .. tostring(test.has_devdrive))
  
  -- Try to load the corresponding machine config
  local host_specific_module = "conf.machines." .. test.hostname:lower():gsub("%-", "_")
  local success, _ = pcall(require, host_specific_module)
  logger.debug("Machine-specific config found: " .. tostring(success))
  logger.info("--- End of test simulation ---\n")
  
  return test
end

return M 