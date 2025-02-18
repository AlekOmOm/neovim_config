# ~/.config/nvim/lua/plugins/lsp/mason.lua

require("mason").setup({
    ensure_installed = {
        "actionlint",
        "prettier",
        "markdownlint",
        "markdown-toc"
    }
    
    -- required fields Mason Settings 

})

require('mason-lspconfig').setup({
    ensure_installed = {
        "pyright",
        "dockerls",
        "docker_compose_language_service",
        "rust_analyzer",
        "bashls",
        "yamlls",
        "vimls",
        "jsonls",
        "html",
        "cssls",
        "ts_ls",
        "lua_ls"
    }
})
