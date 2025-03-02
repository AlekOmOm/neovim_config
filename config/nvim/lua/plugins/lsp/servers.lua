-- ~/.config/nvim/lua/plugins/lsp/servers.lua

local M = {}

function M.setup(opts)
    -- Get lspconfig
    local status_ok, lspconfig = pcall(require, "lspconfig")
    if not status_ok then
        vim.notify("lspconfig not found!", "error")
        return
    end

    -- Get Mason path
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local mason_bin = mason_path .. "/bin/"
    
    -- Helper to get the correct executable path
    local function get_mason_bin(server_name)
        local mapping = {
            ["pyright"] = "pyright-langserver.cmd",
            ["lua_ls"] = "lua-language-server.cmd",
            ["tsserver"] = "typescript-language-server.cmd",
            ["html"] = "vscode-html-language-server.cmd",
            ["cssls"] = "vscode-css-language-server.cmd",
            ["jsonls"] = "vscode-json-language-server.cmd",
            ["yamlls"] = "yaml-language-server.cmd",
            ["bashls"] = "bash-language-server.cmd",
            ["dockerls"] = "docker-langserver.cmd",
            ["docker_compose_language_service"] = "docker-compose-langserver.cmd",
            ["vimls"] = "vim-language-server.cmd",
            ["rust_analyzer"] = "rust-analyzer.cmd"
        }
        
        local bin_name = mapping[server_name] or (server_name .. ".cmd")
        return mason_bin .. bin_name
    end

    -- Server-specific configurations with proper cmd paths
    local server_configs = {
        lua_ls = {
            cmd = { get_mason_bin("lua_ls") },
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
        },
        pyright = {
            cmd = { get_mason_bin("pyright") },
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
            cmd = { get_mason_bin("rust_analyzer") },
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = {
                        command = "clippy"
                    }
                }
            }
        }
    }

    -- List of servers without special configs
    local simple_servers = {
        'html', 'cssls', 'jsonls', 'bashls', 'dockerls',
        'docker_compose_language_service', 'tsserver', 'yamlls', 'vimls'
    }
    
    -- Setup servers with special configs
    for server_name, config in pairs(server_configs) do
        config.on_attach = opts.on_attach
        config.capabilities = opts.capabilities
        
        lspconfig[server_name].setup(config)
        vim.notify("Configured LSP: " .. server_name, "info")
    end
    
    -- Setup servers without special configs
    for _, server in ipairs(simple_servers) do
        lspconfig[server].setup({
            cmd = { get_mason_bin(server) },
            on_attach = opts.on_attach,
            capabilities = opts.capabilities
        })
        vim.notify("Configured LSP: " .. server, "info")
    end
end

return M
