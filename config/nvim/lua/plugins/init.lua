-- ~/.config/nvim/lua/plugins/init.lua



local packer_bootstrap = require('packer').bootstrap

local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'github/copilot.vim'


    -- ### ---------------------------------------------------- ###

    -- notifications

    use {
      "rcarriga/nvim-notify",
      config = function()
        vim.notify = require("notify")
        require("notify").setup({
          timeout = 3000,
          max_width = 80,
          max_height = 20,
        })
      end
    }



    ------------------------------------

    -- LSP Support

    use 'neovim/nvim-lspconfig'
    use {
        'williamboman/mason.nvim',
        config = function()

            require('mason').setup()
        end
    }

    use {
        'williamboman/mason-lspconfig.nvim',
        after = 'mason.nvim',
        config = function()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    -- languages
                    'lua_ls',
                    'pyright',
                    'ts_ls',
                    'html',
                    'cssls',
                    'jsonls',
                    'rust_analyzer',

                    -- workflows
                    'yamlls',
                    'dockerls',
                    'docker_compose_language_service',

                    -- terminals 
                    'vimls',
                    'bashls',

                    -- visualization
                    'eslint',

                    -- .markdown
                    'markdown_oxide',

                    -- testing
                },
                automatic_installation = true,
            })
        end
    }


    -- Completion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-emoji'
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                })
            })
        end,
    }

    -- Theme
    use 'projekt0n/github-nvim-theme'

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                run = 'make'
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

    -- Incremental renaming
    use {
        'smjonas/inc-rename.nvim',
        config = function()
            status_ok, inc_rename = pcall(require, "inc_rename")
            if not status_ok then
                return
            end
            inc_rename.setup({
                keymaps = {
                    "i",
                    "n",
                    "x",
                }
            })
        end
    }

    -- Git
    use 'tpope/vim-fugitive'

    -- ### ---------------------------------------------------- ###
    -- ### -- Markdown

        -- markdown-preview
        use({
          "iamcco/markdown-preview.nvim",
          run = "cd app && npm install",
          setup = function() 
            vim.g.mkdp_filetypes = { "markdown" }
          end,
          ft = { "markdown" },
        })

        -- Markdown emoji 
        use 'junegunn/vim-emoji'        -- general emoji support


    -- ### ---------------------------------------------------- ###
    
    -- prettier linting

    use {
        'prettier/vim-prettier',
        run = 'yarn install',
        ft = { 'javascript', 'typescript', 'css', 'scss', 'json', 'html', 'vue', 'yaml', 'markdown' }
    }




    -- ### ---------------------------------------------------- ###

    -- packer bootstrap
    if packer_bootstrap then
        require('packer').sync()
    else
        -- Only load plugin configs after plugins are installed
        vim.cmd([[
            augroup packer_load_config
            autocmd!
            autocmd User PackerComplete ++once lua require('plugins.setup')
            augroup end
        ]])
    end
end)


