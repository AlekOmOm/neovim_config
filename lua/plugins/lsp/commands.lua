-- ~/.config/nvim/lua/plugins/lsp/commands.lua

local M = {}

function M.setup()
    -- Get the debug module
    local debug = require('plugins.lsp.debug')

    -- Create user commands for LSP diagnostics and management
    vim.api.nvim_create_user_command('LspInfo', function()
        debug.list_clients()
    end, {})
    
    vim.api.nvim_create_user_command('LspLog', function()
        debug.show_lsp_log()
    end, {})
    
    vim.api.nvim_create_user_command('LspStart', function(opts)
        local server = opts.args
        if server == "" then
            vim.notify("Please specify a server name", "error")
            return
        end
        debug.start_server(server)
    end, {
        nargs = 1,
        complete = function()
            return {
                "pyright", "lua_ls", "ts_ls", "html", "cssls", "jsonls",
                "yamlls", "bashls", "dockerls", "vimls", "rust_analyzer"
            }
        end
    })
    
    vim.api.nvim_create_user_command('LspCheck', function()
        debug.verify_mason()
    end, {})
    
    -- Create a command to restart all LSP clients
    vim.api.nvim_create_user_command('LspRestart', function()
        vim.lsp.stop_client(vim.lsp.get_active_clients())
        vim.cmd('edit') -- Force buffer reload
        vim.notify("All LSP clients restarted", "info")
    end, {})
    
    -- Log level command
    vim.api.nvim_create_user_command('LspDebug', function()
        vim.lsp.set_log_level("debug")
        vim.notify("LSP log level set to DEBUG", "info")
    end, {})
    
    vim.api.nvim_create_user_command('LspWarn', function()
        vim.lsp.set_log_level("warn")
        vim.notify("LSP log level set to WARN", "info")
    end, {})
end

return M
