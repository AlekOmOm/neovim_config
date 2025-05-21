-- after/plugin/copilot.lua
-- Ensures Copilot respects file-specific indentation settings

local function setup_copilot_indentation()
  -- Detect indentation settings from the current buffer
  local indent_size = vim.bo.tabstop
  local use_spaces = vim.bo.expandtab
  
  -- Update Copilot's indentation settings
  vim.g.copilot_tab_spaces = indent_size
  vim.g.copilot_indent_mode = use_spaces and 'space' or 'tab'
  
  -- Conditionally update copilot.vim parameters if it exposes an API method
  if vim.fn.exists('*copilot#SetIndentation') == 1 then
    vim.fn['copilot#SetIndentation'](indent_size, use_spaces)
  end
end

-- Create autocmds to update settings when needed
vim.api.nvim_create_augroup("CopilotIndentation", { clear = true })

vim.api.nvim_create_autocmd({"BufEnter", "FileType"}, {
  group = "CopilotIndentation",
  callback = setup_copilot_indentation
})

-- Run when Copilot initializes
vim.api.nvim_create_autocmd("User", {
  pattern = "CopilotReady",
  callback = setup_copilot_indentation,
})

-- Initial setup
setup_copilot_indentation()
