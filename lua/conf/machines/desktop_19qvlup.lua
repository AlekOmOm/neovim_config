local M = {}
local logger = require('utils.logger') -- Added logger

-- Machine-specific settings for stationary desktop (DESKTOP-19QVLUP)
function M.setup()
  -- Define paths specific to this machine
  local stationary_paths = {
    projects = "D:/OneDrive/. Universitet/. GitHub",
    data = "D:/Data",  -- Adjust based on actual drive configuration
  }
  
  -- Store these paths in a global variable for use in other parts of the config
  vim.g.desktop_paths = stationary_paths
  
  -- Example specific settings for this desktop machine
  -- Configure UI elements based on larger desktop screen
  vim.opt.guifont = "FiraCode NF:h12" -- Larger font for desktop display
  
  -- Enhanced visual settings that make sense on a desktop
  vim.opt.cursorline = true
  vim.opt.colorcolumn = "80,120"
  
  -- Example: Configure splitting to prefer vertical splits on widescreen
  vim.opt.splitright = true
  vim.opt.splitbelow = false
  
  -- Set shortcuts or mappings specific to this machine
  -- vim.keymap.set('n', '<leader>dp', ':cd ' .. stationary_paths.projects .. '<CR>', { noremap = true, silent = true, desc = "Change to projects" })
  
  logger.info("Applied stationary desktop specific settings") -- Changed to logger
end

return M 