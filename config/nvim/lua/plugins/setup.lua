-- ~/.config/nvim/lua/plugins/setup.lua

return function()
    require('plugins.copilot')
    require('plugins.lsp')
    require('plugins.completion')
    require('plugins.telescope')
    require('plugins.treesitter')
    require('plugins.theme')
end
