-- OneDrive/../init.lua
-- packer bootstrap setup
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 
      'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.g.mapleader = ' '

vim.cmd('colorscheme github_dark') -- github_dark theme
vim.cmd('highlight Normal guibg=black') -- black background

-- LSP settings
-- - local capabilities set here before requiring cmp_nvim_lsp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').bashls.setup({
    capabilities = capabilities
})

require('lspconfig').yamlls.setup({
    capabilities = capabilities
})

-- plugin manager
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'github/copilot.vim'
    
    -- theme
    use 'projekt0n/github-nvim-theme'
    
    -- LSP Support
    use 'neovim/nvim-lspconfig'
    use 'williamboman/mason.nvim'
    use { 'williamboman/mason-lspconfig.nvim', requires = 'williamboman/mason.nvim' }

    -- completion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'    
    

    -- syntax highlighting
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function() vim.cmd('TSUpdate') end
    }

    -- plenary 
    use 'nvim-lua/plenary.nvim'  -- required by many plugins


    -- markdown preview
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- telescope
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
    }

    -- refactoring
    use {
        'ThePrimeagen/refactoring.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {'nvim-treesitter/nvim-treesitter'}
        }
    }
    use {
        'smjonas/inc-rename.nvim',
        config = function()
            require('inc_rename').setup()
        end
    }
end)

require("mason").setup({
    ensure_installed = {
        "actionlint",
        "prettier",
        "markdownlint",
        "markdown-toc"
    }
})

require('mason-lspconfig').setup({
    ensure_installed = { 
        "pyright",
        "dockerls",
        "docker_compose_language_service",
        "rust_analyzer",
        "bashls",
        "yamlls"
    }
})

-- lspconfig settings
-- - dockerls, docker_compose_language_service, rust_analyzer
require('lspconfig').dockerls.setup({
    capabilities = capabilities
})

require('lspconfig').docker_compose_language_service.setup({
    capabilities = capabilities
})


-- rust_analyzer settings
-- - using clippy for linting ie. when saving the file (hotkey: :w) , clippy will run to check for errors and warnings
require('lspconfig').rust_analyzer.setup({
    capabilities = capabilities,
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = {
                command = "clippy"
            },
        }
    }
})

-- copilot settings
-- - key sequence: <C-J> => hotkeys: ctrl + j, ctrl + k, ctrl + l (for accept, next, previous)
vim.g.copilot_no_tab_map = false
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

-- Refactoring setup
require('refactoring').setup()

-- Keymaps for refactoring
--- keys: <leader>rn, <leader>re, <leader>rf
--- '<leader>' means space key
vim.keymap.set("n", "<leader>rn", ":IncRename ")  -- rename with preview
vim.keymap.set("v", "<leader>re", ":Refactor extract ")  -- extract selected code
vim.keymap.set("v", "<leader>rf", ":Refactor extract_to_file ")  -- extract to file


-- Autocommand to set F5 key mapping based on filetype
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'python', 'java', 'cs', 'lua', 'javascript', 'typescript'},
  callback = function()
    local filetype = vim.bo.filetype
    local cmd = {
      python = ':!python %',
      java = ':!javac % && java %:r',
      cs = ':!dotnet run %',
      lua = ':!lua %',
      javascript = ':!node %',
      typescript = ':!ts-node %',
      rust = ':!cargo run'
    }
    
    if cmd[filetype] then
      vim.keymap.set('n', '<F5>', cmd[filetype] .. '<CR>', { buffer = true })
    end
  end
})


local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    })
})

-- configure LSP
require('lspconfig').pyright.setup({
    capabilities = capabilities
})
