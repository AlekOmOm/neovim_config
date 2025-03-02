--/.config/nvim/lua/plugins/lsp/platform_fix.lua

local M = {}

-- Function to resolve the correct executable name based on platform
function M.get_executable(server_name)
    local is_windows = vim.fn.has('win32') == 1
    
    local mapping = {
        ["pyright"] = "pyright-langserver",
        ["lua_ls"] = "lua-language-server",
        ["tsserver"] = "typescript-language-server",
        ["html"] = "vscode-html-language-server",
        ["cssls"] = "vscode-css-language-server",
        ["jsonls"] = "vscode-json-language-server",
        ["yamlls"] = "yaml-language-server",
        ["bashls"] = "bash-language-server",
        ["dockerls"] = "docker-langserver",
        ["docker_compose_language_service"] = "docker-compose-langserver",
        ["vimls"] = "vim-language-server",
        ["rust_analyzer"] = "rust-analyzer"
    }
    
    local base_name = mapping[server_name] or server_name
    
    -- Only append .cmd on Windows
    if is_windows then
        return base_name .. ".cmd"
    else
        return base_name
    end
end

return M

