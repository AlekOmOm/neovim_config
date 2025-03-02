-- ~/.config/nvim/lua/plugins/lsp/debug.lua

local M = {}

-- Function to manually start a language server with debug output
function M.start_server(server_name, filetype)
    -- Get Mason path
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local mason_bin = mason_path .. "/bin/"
    
    -- Mapping of server names to their executable filenames on Windows
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
    
    -- Get the correct executable name
    local executable = mapping[server_name] or (server_name .. ".cmd")
    local cmd_path = mason_bin .. executable
    
    -- Check if the executable exists
    local exists = vim.fn.filereadable(cmd_path) == 1
    if not exists then
        vim.notify("LSP executable not found: " .. cmd_path, "error")
        return
    end
    
    -- Set high log level for debugging
    vim.lsp.set_log_level("debug")
    
    -- Open a file with the correct filetype
    if filetype then
        vim.cmd('e test.' .. filetype)
    end
    
    -- Start the server manually
    local cmd_args = {}
    if server_name == "pyright" then
        cmd_args = {"--stdio"}
    elseif server_name == "tsserver" then
        cmd_args = {"--stdio"}
    elseif server_name == "lua_ls" then
        -- Nothing extra needed
    end
    
    -- Construct the full command array
    local cmd = {cmd_path}
    for _, arg in ipairs(cmd_args) do
        table.insert(cmd, arg)
    end
    
    -- Print debug info
    vim.notify("Starting LSP: " .. server_name .. " with cmd: " .. vim.inspect(cmd), "info")
    
    -- Try to start the server
    local client_id = vim.lsp.start({
        name = server_name,
        cmd = cmd,
        root_dir = vim.fn.getcwd(),
    })
    
    if client_id then
        vim.notify("LSP started with client ID: " .. client_id, "info")
    else
        vim.notify("Failed to start LSP: " .. server_name, "error")
    end
    
    return client_id
end

-- Show the LSP log with proper formatting
function M.show_lsp_log()
    local log_path = vim.lsp.get_log_path()
    vim.notify("Opening LSP log: " .. log_path, "info")
    vim.cmd('split ' .. log_path)
    vim.cmd('setlocal filetype=log')
end

-- List active clients with detailed info
function M.list_clients()
    local clients = vim.lsp.get_active_clients()
    
    if #clients == 0 then
        vim.notify("No active LSP clients", "warn")
        return
    end
    
    local output = "Active LSP clients:\n"
    for _, client in ipairs(clients) do
        output = output .. string.format(
            "\n• %s (id: %d)\n  - root: %s\n  - cmd: %s\n  - filetypes: %s\n",
            client.name,
            client.id,
            client.root_dir or "nil",
            vim.inspect(client.config.cmd),
            vim.inspect(client.config.filetypes)
        )
    end
    
    vim.notify(output, "info")
end

-- Helper to verify all Mason installations
function M.verify_mason()
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local mason_bin = mason_path .. "/bin/"
    
    -- Common LSP servers to check
    local servers = {
        "pyright", "lua_ls", "tsserver", "html", "cssls", "jsonls",
        "yamlls", "bashls", "dockerls", "vimls", "rust_analyzer"
    }
    
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
        ["vimls"] = "vim-language-server.cmd",
        ["rust_analyzer"] = "rust-analyzer.cmd"
    }
    
    local output = "Mason installation check:\n"
    local all_good = true
    
    for _, server in ipairs(servers) do
        local executable = mapping[server] or (server .. ".cmd")
        local path = mason_bin .. executable
        local exists = vim.fn.filereadable(path) == 1
        
        if exists then
            output = output .. "✓ " .. server .. " (" .. path .. ")\n"
        else
            output = output .. "✗ " .. server .. " (" .. path .. ") - MISSING\n"
            all_good = false
        end
    end
    
    if all_good then
        output = output .. "\nAll LSP servers found correctly in Mason bin directory."
    else
        output = output .. "\nSome LSP servers are missing! Run :Mason to install them."
    end
    
    vim.notify(output, all_good and "info" or "warn")
end

return M
