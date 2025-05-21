-- lua/plugins/packer_update.lua
--
-- This file contains utilities to update Packer and patch the deprecation warnings

local M = {}

-- Function to update Packer
function M.update_plugins()
  -- Notify start of update process
  vim.notify("Updating plugins to fix deprecation warnings...", vim.log.levels.INFO)
  
  -- Set up commands to run
  vim.cmd("PackerUpdate wbthomason/packer.nvim github/copilot.vim")
  
  -- Advise on next steps
  vim.notify("Updates initiated. Run :PackerSync to complete the process.", vim.log.levels.INFO)
end

-- Monkey patch for vim.tbl_islist -> vim.islist if available
function M.patch_tbl_islist()
  -- Check if vim.islist exists (Neovim 0.8+)
  if vim.islist then
    -- Only patch if vim.tbl_islist still exists
    if vim.tbl_islist then
      -- Override with vim.islist (no need to store original)
      vim.tbl_islist = function(t)
        return vim.islist(t)
      end
      
      vim.notify("Patched vim.tbl_islist to use vim.islist", vim.log.levels.INFO)
    end
  end
end

-- Apply all patches
function M.apply_all_patches()
  M.patch_tbl_islist()
  
  -- Add version check warning
  local nvim_version = vim.version()
  local version_str = string.format("%d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch)
  
  if nvim_version.minor >= 12 then
    vim.notify("Warning: Your Neovim version (" .. version_str .. ") may have removed vim.tbl_islist. Update Packer ASAP.", vim.log.levels.WARN)
  end
  
  if nvim_version.minor >= 13 then
    vim.notify("Warning: Your Neovim version (" .. version_str .. ") may have removed vim.lsp.start_client. Update Copilot ASAP.", vim.log.levels.WARN)
  end
end

-- Create a user command to easily run updates
vim.api.nvim_create_user_command("FixDeprecationWarnings", function()
  M.update_plugins()
end, {})

return M