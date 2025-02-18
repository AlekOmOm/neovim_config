# ~/.config/nvim/lua/plugins/lsp/servers.lua
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {
    'pyright',
    'dockerls',
    'docker_compose_language_service',
    'rust_analyzer',
    'bashls',
    'yamlls',
    'vimls',
    'jsonls',
    'html',
    'cssls',
    'ts_ls',
    'lua_ls'
}

for _, lsp in ipairs(servers) do
    local config = {
        capabilities = capabilities
    }

    -- Lua-specific settings
    if lsp == 'lua_ls' then
        config.settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }  -- Recognize 'vim' global
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
            }
        }
    end
   
    -- Rust-specific settings
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
