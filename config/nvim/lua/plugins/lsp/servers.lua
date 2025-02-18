# ~/.config/nvim/lua/plugins/lsp/servers.lua
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {
    'pyright',
    'dockerls',
    'docker_compose_language_service',
    'rust_analyzer',
    'bashls',
    'yamlls'
}

for _, lsp in ipairs(servers) do
    local config = {
        capabilities = capabilities
    }
    
    if lsp == 'rust_analyzer' then
        config.settings = {
            ['rust-analyzer'] = {
                checkOnSave = {
                    command = "clippy"
                }
            }
        }
    end
    
    require('lspconfig')[lsp].setup(config)
end
