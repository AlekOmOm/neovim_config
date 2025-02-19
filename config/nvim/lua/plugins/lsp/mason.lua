-- Enhanced mason configuration with better organization and additional features
local status_ok, mason = pcall(require, "mason")
if not status_ok then
    return
end

-- Core tool categories
local FORMATTERS = {
    "prettier",
    "stylua",
    "black",
    "rustfmt",
}

local LINTERS = {
    "actionlint",
    "markdownlint",
    "shellcheck",
    "eslint_d",
}

local DOC_TOOLS = {
    "markdown-toc",
    "vale",
}

-- Language servers by domain
local WEB_SERVERS = {
    "html",
    "cssls",
    "tsserver",
    "jsonls",
}

local SYSTEM_SERVERS = {
    "dockerls",
    "docker_compose_language_service",
    "bashls",
}

local PROG_SERVERS = {
    "pyright",
    "rust_analyzer",
    "lua_ls",
}

local CONFIG_SERVERS = {
    "yamlls",
    "vimls",
}

-- Base mason setup with extended configuration
mason.setup({
    ui = {
        border = "rounded",
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    },
    max_concurrent_installers = 4,
    ensure_installed = vim.tbl_flatten({
        FORMATTERS,
        LINTERS,
        DOC_TOOLS,
    })
})

-- LSP configuration with grouped servers
require('mason-lspconfig').setup({
    ensure_installed = vim.tbl_flatten({
        WEB_SERVERS,
        SYSTEM_SERVERS,
        PROG_SERVERS,
        CONFIG_SERVERS,
    }),
    automatic_installation = true,
})

-- Auto-installation hook
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        local ft = vim.bo.filetype
        -- Add automatic server installation logic here
    end,
})

-- Optional: Integration with null-ls for formatting
local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if null_ls_status_ok then
    null_ls.setup({
        sources = {
            -- Add null-ls formatting sources here
        }
    })
end
