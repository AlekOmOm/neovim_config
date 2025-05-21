local M = {}
local logger = require('utils.logger') -- Added logger

-- Machine-specific settings for main laptop (DESKTOP-V2L884C) with devdrive
function M.setup()
  -- Define paths specific to this machine
  local dev_drive_paths = {
    projects = "D:/dev/projects",
    tools = "D:/dev/tools",
  }
  
  -- Store these paths in a global variable for use in other parts of the config
  vim.g.dev_paths = dev_drive_paths
  
  -- Example specific settings for this machine
  -- Configure UI elements based on laptop screen size
  vim.opt.guifont = "FiraCode NF:h11" -- Adjust font size for laptop display
  
  -- Configure specific plugins for development on this machine
  -- vim.g.plugin_setting_x = "value"
  
  -- Set shortcuts or mappings specific to this machine
  -- vim.keymap.set('n', '<leader>dd', ':cd ' .. dev_drive_paths.projects .. '<CR>', { noremap = true, silent = true, desc = "Change to dev projects" })
  
  logger.info("Applied main laptop specific settings (devdrive configured)") -- Changed to logger
end

return M 