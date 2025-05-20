local M = {}

function M.setup()
  local status_ok, mason = pcall(require, 'mason')
  if not status_ok then
    vim.notify("Mason plugin not found", vim.log.levels.ERROR)
    return false
  end
  
  -- Get the exact path from your utility
  local paths = require('utils.paths')
  local install_path = paths.join(vim.fn.stdpath('data'), 'mason')
  
  mason.setup({
    install_root_dir = install_path,
    ui = {
      border = "rounded",
      icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
    },
  })
  
  -- Register the Mason command explicitly
  vim.cmd[[command! Mason lua require('mason.ui').open()]]
  
  return true
end

return M
