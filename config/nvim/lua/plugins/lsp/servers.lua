-- ~/.config/nvim/lua/plugins/lsp/servers.lua

local M = {}

function M.setup(opts)
    -- Get lspconfig
    local status_ok, lspconfig = pcall(require, "lspconfig")
    if not status_ok then
        vim.notify("lspconfig not found!", 0)
        return
    end

    -- Get Mason path
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local mason_bin = mason_path .. "/bin/"

    -- Helper to get the correct executable path
    local function get_mason_bin(server_name)
        local mapping = {
            ["pyright"] = vim.fn.has('win32') == 1 and "pyright-langserver.cmd" or "pyright-langserver",
            ["lua_ls"] = vim.fn.has('win32') == 1 and "lua-language-server.cmd" or "lua-language-server",
            ["tsserver"] = vim.fn.has('win32') == 1 and "typescript-language-server.cmd" or "typescript-language-server",
            ["html"] = vim.fn.has('win32') == 1 and "vscode-html-language-server.cmd" or "vscode-html-language-server",
            ["cssls"] = vim.fn.has('win32') == 1 and "vscode-css-language-server.cmd" or "vscode-css-language-server",
            ["jsonls"] = vim.fn.has('win32') == 1 and "vscode-json-language-server.cmd" or "vscode-json-language-server",
            ["yamlls"] = vim.fn.has('win32') == 1 and "yaml-language-server.cmd" or "yaml-language-server",
            ["bashls"] = vim.fn.has('win32') == 1 and "bash-language-server.cmd" or "bash-language-server",
            ["dockerls"] = vim.fn.has('win32') == 1 and "docker-langserver.cmd" or "docker-langserver",
            ["docker_compose_language_service"] = vim.fn.has('win32') == 1 and "docker-compose-langserver.cmd" or "docker-compose-langserver",
            ["vimls"] = vim.fn.has('win32') == 1 and "vim-language-server.cmd" or "vim-language-server",
            ["rust_analyzer"] = vim.fn.has('win32') == 1 and "rust-analyzer.cmd" or "rust-analyzer"
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
