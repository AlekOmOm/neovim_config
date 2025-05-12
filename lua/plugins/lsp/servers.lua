-- ~/.config/nvim/lua/plugins/lsp/servers.lua

local paths = require('utils.paths')

local M = {}

function M.setup(opts)

    vim.defer_fn(function()

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
        local is_windows = vim.fn.has('win32') == 1

        local mapping = {
            ["pyright"] = is_windows and "pyright-langserver.cmd" or "pyright-langserver",
            ["lua_ls"] = is_windows and "lua-language-server.cmd" or "lua-language-server",
            ["ts_ls"] = is_windows and "typescript-language-server.cmd" or "typescript-language-server",
            ["eslint"] = is_windows and "vscode-eslint-language-server.cmd" or "vscode-eslint-language-server",
            ["eslint_d"] = is_windows and "vscode-eslint-language-server.cmd" or "vscode-eslint-language-server",
            ["html"] = is_windows and "vscode-html-language-server.cmd" or "vscode-html-language-server",
            ["cssls"] = is_windows and "vscode-css-language-server.cmd" or "vscode-css-language-server",
            ["jsonls"] = is_windows and "vscode-json-language-server.cmd" or "vscode-json-language-server",
            ["yamlls"] = is_windows and "yaml-language-server.cmd" or "yaml-language-server",
            ["bashls"] = is_windows and "bash-language-server.cmd" or "bash-language-server",
            ["dockerls"] = is_windows and "docker-langserver.cmd" or "docker-langserver",
            ["docker_compose_language_service"] = is_windows and "docker-compose-langserver.cmd" or "docker-compose-langserver",
            ["vimls"] = is_windows and "vim-language-server.cmd" or "vim-language-server",
            ["rust_analyzer"] = is_windows and "rust-analyzer.cmd" or "rust-analyzer",
            ["markdown_oxide"] = is_windows and "markdown-oxide.cmd" or "markdown-oxide"
        }

        local bin_name = mapping[server_name]
        if not bin_name then
            bin_name = is_windows and (server_name .. ".cmd") or server_name
        end
        return paths.join(vim.fn.stdpath("data"), "mason", "bin", bin_name)
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
                    pythonPath = vim.env.NVIM_PYTHON_EXE and vim.env.NVIM_PYTHON_EXE ~= "" and vim.env.NVIM_PYTHON_EXE or "python",
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
        },
        markdown_oxide = {
            cmd = { get_mason_bin("markdown_oxide") },
            filetypes = { "markdown" },
            root_dir = require("lspconfig").util.root_pattern(".git", ".obsidian", ".moxide.toml", "*.md"),
            single_file_support = true,
        },
    }

    -- List of servers without special configs
    local simple_servers = {
        'html', 'cssls', 'jsonls', 'bashls', 'dockerls',
        'docker_compose_language_service', 'ts_ls', 'yamlls', 'vimls'
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

    end, 100)
end

return M
