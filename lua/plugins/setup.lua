-- ~/.config/nvim/lua/plugins/setup.lua

local function setup_plugin(plugin_name)
  local status_ok, plugin_setup = pcall(require, 'plugins.' .. plugin_name)
  if status_ok and type(plugin_setup) == 'table' and plugin_setup.setup then
    plugin_setup.setup()
  else
    vim.notify("Failed to load plugin: " .. plugin_name, 1) -- Error
  end
end

return function()
  -- Load theme first
  require('plugins.theme')

  -- Load core functionality
  setup_plugin('treesitter')

  -- Load LSP and completion (with proper error handling)
  local lsp_ok, lsp = pcall(require, 'plugins.lsp')
  if lsp_ok then
    lsp.setup()
  else
    vim.notify("Failed to load LSP", 0)
  end

  setup_plugin('completion')
  setup_plugin('markdown')

  -- Load UI and tools
  setup_plugin('telescope')

  -- Load Copilot
  require('plugins.copilot')
end
