-- # ~/.config/nvim/lua/plugins/init.lua

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

-- Load plugin configs first
require('plugins.copilot')
require('plugins.lsp')
require('plugins.completion')
require('plugins.telescope')
require('plugins.treesitter')
require('plugins.theme')

-- Then return packer config
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'github/copilot.vim'
    
    -- LSP Support
    use 'neovim/nvim-lspconfig'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    
    -- Completion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'
    
    -- Theme
    use 'projekt0n/github-nvim-theme'
   

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                run = 'make',  -- This requires make to be installed, see :help telescope-fzf-native
            }
        }
    }
    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function() vim.cmd('TSUpdate') end
    }
    
    -- Refactoring
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
    
    -- Git
    -- - git commands in nvim, i.e. :Gstatus, :Gcommit, etc. 

    use 'tpope/vim-fugitive' 

    -- markdown preview
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })
    
    if packer_bootstrap then
        require('packer').sync()
    end
end)
