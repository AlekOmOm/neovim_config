-- ~/.config/nvim/lua/plugins/lsp/debug.lua

local M = {}

-- Function to manually start a language server with debug output
function M.start_server(server_name, filetype)
    -- Get Mason path
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local mason_bin = mason_path .. "/bin/"

    -- Mapping of server names to their executable filenames on Windows
    local is_windows = vim.fn.has('win32') == 1
    local mapping = {
        ["pyright"] = is_windows and "pyright-langserver.cmd" or "pyright-langserver",
        ["lua_ls"] = is_windows and "lua-language-server.cmd" or "lua-language-server",
        ["tsserver"] = is_windows and "typescript-language-server.cmd" or "typescript-language-server",
        ["html"] = is_windows and "vscode-html-language-server.cmd" or "vscode-html-language-server",
        ["cssls"] = is_windows and "vscode-css-language-server.cmd" or "vscode-css-language-server",
        ["jsonls"] = is_windows and "vscode-json-language-server.cmd" or "vscode-json-language-server",
        ["yamlls"] = is_windows and "yaml-language-server.cmd" or "yaml-language-server",
        ["bashls"] = is_windows and "bash-language-server.cmd" or "bash-language-server",
        ["dockerls"] = is_windows and "docker-langserver.cmd" or "docker-langserver",
        ["docker_compose_language_service"] = is_windows and "docker-compose-langserver.cmd" or "docker-compose-langserver",
        ["vimls"] = is_windows and "vim-language-server.cmd" or "vim-language-server",
        ["rust_analyzer"] = is_windows and "rust-analyzer.cmd" or "rust-analyzer"
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
    vim.message("Opening LSP log: " .. log_path, "info")
    vim.cmd('split ' .. log_path)
    vim.cmd('setlocal filetype=log')
end

-- List active clients with detailed info
function M.list_clients()
    local clients = vim.lsp.get_clients()
    clients = vim.tbl_filter(function(c) return c.config.filetypes ~= nil end, clients)

    if #clients == 0 then
        vim.notify("No active LSP clients", 0)
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

    vim.notify(output, 0)
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

    local is_windows = vim.fn.has('win32') == 1
    local mapping = {
        ["pyright"] = is_windows and "pyright-langserver.cmd" or "pyright-langserver",
        ["lua_ls"] = is_windows and "lua-language-server.cmd" or "lua-language-server",
        ["tsserver"] = is_windows and "typescript-language-server.cmd" or "typescript-language-server",
        ["html"] = is_windows and "vscode-html-language-server.cmd" or "vscode-html-language-server",
        ["cssls"] = is_windows and "vscode-css-language-server.cmd" or "vscode-css-language-server",
        ["jsonls"] = is_windows and "vscode-json-language-server.cmd" or "vscode-json-language-server",
        ["yamlls"] = is_windows and "yaml-language-server.cmd" or "yaml-language-server",
        ["bashls"] = is_windows and "bash-language-server.cmd" or "bash-language-server",
        ["dockerls"] = is_windows and "docker-langserver.cmd" or "docker-langserver",
        ["docker_compose_language_service"] = is_windows and "docker-compose-langserver.cmd" or "docker-compose-langserver",
        ["vimls"] = is_windows and "vim-language-server.cmd" or "vim-language-server",
        ["rust_analyzer"] = is_windows and "rust-analyzer.cmd" or "rust-analyzer"
    }

    local output = "Mason installation check:\n"
    local all_good = true

    for _, server in ipairs(servers) do

        local executable = mapping[server] or (is_windows and (server .. ".cmd") or server)
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

    vim.notify(output, 1)
end

return M
