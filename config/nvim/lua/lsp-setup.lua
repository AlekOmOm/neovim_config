
-- ~/.config/nvim/lua/lsp-setup.lua

local lspconfig = require('lspconfig')

-- Get the shared settings from the LSP module
local lsp_module = require('plugins.lsp')
local on_attach = lsp_module.on_attach
local capabilities = lsp_module.capabilities

-- Ensure direct setup for critical servers
lspconfig.pyright.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace"
            }
        }
    }
})

lspconfig.ts_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities
})

lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
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
})

print("Direct LSP setup complete")
