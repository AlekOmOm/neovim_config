-- Linux Compatibility Test Script
-- Run this script with: nvim --headless -c "luafile scripts/linux_compatibility_test.lua" -c q

local paths = require('utils.paths')

local function log(message)
  print(message)
  -- Also append to a log file for later review
  local log_file = io.open(paths.join(vim.fn.stdpath('cache'), 'linux_compat_test.log'), 'a')
  if log_file then
    log_file:write(message .. '\n')
    log_file:close()
  end
end

local function test_paths()
  log("=== Testing Path Handling ===")
  
  -- Check path separator
  log("Path separator: " .. paths.path_sep)
  if paths.path_sep ~= '/' then
    log("WARNING: Path separator is not '/' on this Linux system")
  else
    log("✓ Path separator correctly set to '/'")
  end
  
  -- Check standard paths
  log("config_dir: " .. paths.NVIM.CONFIG)
  log("data_dir: " .. paths.NVIM.DATA)
  log("cache_dir: " .. paths.NVIM.CACHE)
  log("state_dir: " .. paths.NVIM.STATE)
  
  -- Test path joining
  local test_path = paths.join(paths.NVIM.CONFIG, "lua", "utils", "paths.lua")
  log("Joined path test: " .. test_path)
  if vim.fn.filereadable(test_path) == 1 then
    log("✓ Path joining works correctly")
  else
    log("WARNING: Path joining failed - could not find paths.lua")
  end
  
  -- Test home directory
  log("Home directory: " .. paths.HOME)
end

local function test_lsp_paths()
  log("\n=== Testing LSP Configuration ===")
  
  -- Check Mason bin directory
  local mason_bin = paths.join(paths.NVIM.DATA, "mason", "bin")
  log("Mason bin directory: " .. mason_bin)
  if vim.fn.isdirectory(mason_bin) == 1 then
    log("✓ Mason directory exists")
  else
    log("WARNING: Mason bin directory not found")
  end
  
  -- Check for .cmd extensions in LSP server commands
  local lsp_servers = {
    "pyright-langserver",
    "lua-language-server",
    "typescript-language-server"
  }
  
  for _, server in ipairs(lsp_servers) do
    local server_path = paths.join(mason_bin, server)
    local server_cmd_path = paths.join(mason_bin, server .. ".cmd")
    
    log("Testing server: " .. server)
    if vim.fn.filereadable(server_path) == 1 then
      log("✓ Server exists without .cmd extension: " .. server_path)
    elseif vim.fn.filereadable(server_cmd_path) == 1 then
      log("WARNING: Server found with .cmd extension: " .. server_cmd_path)
    else
      log("NOTE: Server not installed: " .. server)
    end
  end
end

local function test_shada_path()
  log("\n=== Testing Shada File Configuration ===")
  
  -- Expected Linux shada path
  local expected_shada_path = paths.join(paths.NVIM.STATE, 'neovim.shada')
  log("Expected Linux shada path: " .. expected_shada_path)
  
  -- Get current shada path from vim.opt
  local current_shada_path = vim.opt.shadafile:get()
  log("Current shada path: " .. current_shada_path)
  
  if current_shada_path == expected_shada_path then
    log("✓ Shada path correctly configured for Linux")
  else
    log("WARNING: Shada path may not be correctly set for Linux")
  end
end

local function test_os_detection()
  log("\n=== Testing OS Detection ===")
  
  local sysname = vim.loop.os_uname().sysname
  log("System name detected: " .. sysname)
  
  if sysname == "Linux" then
    log("✓ Correctly detected Linux OS")
  elseif sysname == "Windows_NT" then
    log("WARNING: Running on Windows, not Linux")
  else
    log("NOTE: Running on " .. sysname .. " (not Linux or Windows)")
  end
  
  -- Test vim.fn.has
  local is_windows = vim.fn.has('win32') == 1
  log("vim.fn.has('win32') returns: " .. tostring(is_windows))
  if is_windows then
    log("WARNING: vim.fn.has('win32') is true on a Linux system")
  else
    log("✓ vim.fn.has('win32') correctly returns false on Linux")
  end
end

-- Run all tests
log("\n====================================")
log("LINUX COMPATIBILITY TEST")
log("Run at: " .. os.date())
log("====================================\n")

test_os_detection()
test_paths()
test_lsp_paths()
test_shada_path()

log("\n====================================")
log("TEST COMPLETED")
log("See the full log at: " .. paths.join(vim.fn.stdpath('cache'), 'linux_compat_test.log'))
log("====================================") 