-- # plugins/treesitter.lua

-- Load the treesitter plugin
-- this file loaded to the plugin.lua file 

require('nvim-treesitter.configs').setup({
    -- Automatically install missing parsers when entering buffer
    ensure_installed = {
        "lua",
        "vim",
        "python",
        "javascript",
        "typescript",
        "markdown",
        "json",
        "yaml",
        "rust"
    },
    
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
    
    -- Automatically install missing parsers when entering buffer
    auto_install = true,
    
    highlight = {
        -- Enable syntax highlighting
        enable = true,
        
        -- Disable slow treesitter highlight for large files
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
        
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        additional_vim_regex_highlighting = false,
    },
    
    -- Enable indentation
    indent = { enable = true },
    
    -- Enable incremental selection
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
})
