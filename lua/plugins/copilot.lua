-- lua/plugins/copilot.lua
-- Complete Copilot plugin configuration
-- ============================================================================

-- Core settings
vim.g.copilot_no_tab_map = true          -- Disable default tab mapping
vim.g.copilot_assume_mapped = true       -- Tell Copilot we have custom mappings
vim.g.copilot_tab_fallback = ""          -- What to do when tab is pressed and Copilot has no suggestion

-- Suggestion display settings
vim.g.copilot_filetypes = {              -- Enable/disable for specific filetypes
  ["*"] = true,                          -- Enable for all filetypes by default
  ["markdown"] = true,                   -- Specifically enable for markdown
  ["TelescopePrompt"] = false,           -- Disable for Telescope
}

-- Disable for specific buffer types
vim.g.copilot_enabled = true             -- Global toggle for Copilot

-- Custom key mappings
-- Main navigation and interaction
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Next()', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Previous()', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-H>", 'copilot#Dismiss()', { silent = true, expr = true })

-- Partial completion support
vim.api.nvim_set_keymap("i", "<A-J>", 'copilot#AcceptWord()', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<A-L>", 'copilot#AcceptLine()', { silent = true, expr = true })

-- Toggle commands for enabling/disabling
vim.api.nvim_create_user_command('CopilotToggle', function()
  if vim.g.copilot_enabled == 1 then
    vim.cmd('Copilot disable')
    print("Copilot disabled")
  else
    vim.cmd('Copilot enable')
    print("Copilot enabled")
  end
end, {})

-- Note: Indentation settings are handled in after/plugin/copilot.lua