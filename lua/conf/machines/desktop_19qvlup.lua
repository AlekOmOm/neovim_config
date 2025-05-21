local M = {}
local logger = require('utils.logger')
local env_ok, env = pcall(require, 'utils.env')

-- Machine-specific settings for stationary desktop (DESKTOP-19QVLUP)
function M.setup()
  -- Define paths specific to this machine, using environment variables if available
  local stationary_paths = {
    projects = (env_ok and env.get("NVIM_DESKTOP_PROJECTS_PATH")) or "D:/OneDrive/. Universitet/. GitHub",
    data = (env_ok and env.get("NVIM_DESKTOP_DATA_PATH")) or "D:/Data",
  }
  
  -- Store these paths in a global variable for use in other parts of the config
  vim.g.desktop_paths = stationary_paths
  
  -- Example specific settings for this desktop machine
  -- Configure UI elements based on larger desktop screen
  local font_size = (env_ok and env.get_number("NVIM_DESKTOP_FONT_SIZE", 12)) or 12
  vim.opt.guifont = "FiraCode NF:h" .. font_size
  
  -- Enhanced visual settings that make sense on a desktop
  vim.opt.cursorline = (env_ok and env.get_bool("NVIM_DESKTOP_CURSORLINE", true)) or true
  
  -- Color column can be configured via environment variable as a comma-separated list
  local color_column = (env_ok and env.get("NVIM_DESKTOP_COLOR_COLUMN")) or "80,120"
  vim.opt.colorcolumn = color_column
  
  -- Configure splitting behavior
  vim.opt.splitright = true
  vim.opt.splitbelow = false
  
  -- Set shortcuts or mappings specific to this machine
  -- vim.keymap.set('n', '<leader>dp', ':cd ' .. stationary_paths.projects .. '<CR>', { noremap = true, silent = true, desc = "Change to projects" })
  
  logger.info("Applied stationary desktop specific settings")
end

return M 