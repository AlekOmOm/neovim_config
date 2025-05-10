-- Test script for system-specific configuration
-- Can be run with ':luafile lua/core/test_system_specific.lua' from Neovim

local logger = require('utils.logger') -- Added logger

-- Load the system-specific module
local system = require('core.system_specific')

-- Display current environment information
logger.info("\n=== CURRENT CONFIGURATION ===") -- Changed to logger
logger.info("Hostname: " .. system.hostname) -- Changed to logger
logger.info("OS Type: " .. system.os_type) -- Changed to logger
logger.info("Is Windows: " .. tostring(system.is_windows)) -- Changed to logger
logger.info("Is Linux: " .. tostring(system.is_linux)) -- Changed to logger
logger.info("Is Mac: " .. tostring(system.is_mac)) -- Changed to logger
logger.info("Is Desktop: " .. tostring(system.is_desktop)) -- Changed to logger
logger.info("Is Laptop: " .. tostring(system.is_laptop)) -- Changed to logger
logger.info("Is Main Laptop: " .. tostring(system.is_main_laptop)) -- Changed to logger
logger.info("Is Stationary: " .. tostring(system.is_stationary)) -- Changed to logger
logger.info("Has Devdrive: " .. tostring(system.has_devdrive)) -- Changed to logger

-- Test with main laptop simulation (DESKTOP-V2L884C)
logger.info("\n=== TESTING MAIN LAPTOP ENVIRONMENT ===") -- Changed to logger
local main_laptop = system.test_environment("DESKTOP-V2L884C", "Windows_NT")

-- Test with stationary desktop simulation (DESKTOP-19QVLUP)
logger.info("\n=== TESTING STATIONARY DESKTOP ENVIRONMENT ===") -- Changed to logger
local stationary = system.test_environment("DESKTOP-19QVLUP", "Windows_NT")

-- Test with Linux simulation (any hostname)
logger.info("\n=== TESTING LINUX ENVIRONMENT ===") -- Changed to logger
local linux_env = system.test_environment(system.hostname, "Linux")

-- Test with unknown hostname
logger.info("\n=== TESTING UNKNOWN HOSTNAME ===") -- Changed to logger
local unknown = system.test_environment("UNKNOWN-COMPUTER", system.os_type)

logger.info("\n=== TEST COMPLETE ===") -- Changed to logger
logger.info("You can now verify that system-specific settings are correctly detected.") -- Changed to logger
logger.info("To test actual settings application, restart Neovim with:") -- Changed to logger
logger.info("  - Normal startup: Standard configuration for current system") -- Changed to logger
logger.info("  - Override test: vim.g.system_override = {hostname = \"DESKTOP-19QVLUP\"} in init.lua") -- Changed to logger 