-- ~/.config/nvim/lua/plugins/lsp/servers.lua

local M = {}

-- List of servers to set up
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

function M.setup(opts)
    -- Server-specific configurations
    local server_configs = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { 
                  globals = { 'vim' } },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
            }
          }
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true
              }
            }
          }
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy"
              }
            }
          }
        }

        -- other server-specific configs
    }

    -- Setup each server
      for server_name, config in pairs(server_configs) do

        config.on_attach = opts.on_attach
        config.capabilities = opts.capabilities
        
        lspconfig[server_name].setup(config)
      end
      
      -- Setup servers without special configs
      local simple_servers = {
        'html', 'cssls', 'jsonls', 'bashls', 'dockerls'
        -- more servers
      }
      
      for _, server in ipairs(simple_servers) do
        lspconfig[server].setup({
          on_attach = opts.on_attach,
          capabilities = opts.capabilities
        })
      end
    end

return M

