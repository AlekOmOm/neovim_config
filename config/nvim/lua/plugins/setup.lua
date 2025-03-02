-- ~/.config/nvim/lua/plugins/setup.lua

return function()
  -- Load core plugins first
  require('plugins.theme')
  require('plugins.treesitter').setup()
  
  -- Load LSP and completion
  require('plugins.lsp').setup()
  require('plugins.completion').setup()
  
  -- Load UI and tools
  require('plugins.telescope').setup()
  require('plugins.copilot').setup()
end
