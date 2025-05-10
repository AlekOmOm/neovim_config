-- ~/.config/nvim/lua/plugins/init.lua
local packer = require('packer')
local logger = require('utils.logger')

logger.info("plugins.init.lua: packer required")

local paths = require('utils.paths')

-- require('impatient') -- <<<<< CRITICAL: Ensure this is commented out or removed

logger.info("plugins.init.lua: proceeding with packer.startup")
logger.debug("plugins.init.lua: Packer package_root will be based on vim.fn.stdpath('data'): " .. vim.inspect(vim.fn.stdpath('data')))

return packer.startup({
    function(use)
        use 'wbthomason/packer.nvim'
        -- use 'lewis6991/impatient.nvim'
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
            -- event = "InsertEnter",
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
            run = function() vim.cmd('TSUpdate') end,
            event = { "BufReadPost", "BufNewFile" },
            config = function()
                require('nvim-treesitter.configs').setup {
                    highlight = {
                        enable = true,
                    },
                }
            end
        }

        -- Refactoring
        use {
            'ThePrimeagen/refactoring.nvim',
            cmd = { "Refactor" },
            requires = {
                {'nvim-lua/plenary.nvim'},
                {'nvim-treesitter/nvim-treesitter'}
            }
        }

        -- Incremental renaming
        use {
            'smjonas/inc-rename.nvim',
            cmd = "IncRename",
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
        use {
            'tpope/vim-fugitive',
            cmd = { "Git", "G", "Gstatus", "Gblame" }
        }

        -- ### ---------------------------------------------------- ###
        -- ### -- Markdown

            -- markdown-preview
            use({
              "iamcco/markdown-preview.nvim",
              run = "cd app && npm install",
              -- setup = function()
              --     require('plugins.markdown').setup()
              -- end,
              ft = { "markdown" },
            })



        -- ### ---------------------------------------------------- ###





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
    end,
    config = {
        -- Use system-agnostic paths for packer compilation
        compile_path = paths.join(vim.fn.getcwd(), 'plugin', 'packer_compiled.lua'),
        package_root = paths.join(vim.fn.stdpath('data'), 'site', 'pack'),
        display = {
            open_fn = function()
                return require('packer.util').float({ border = 'rounded' })
            end
        },
        -- Ensure proper path handling for git commands
        git = {
            clone_timeout = 300, -- 5 minutes
            -- Use system-agnostic paths for subcommands
            subcommands = {
                update = 'pull --ff-only --progress --rebase=false',
            },
        },
        -- Use system-agnostic paths for Luarocks
        luarocks = {
            -- Use paths.join for system-agnostic path construction
            python_cmd = vim.fn.exepath('python3') or vim.fn.exepath('python'),
        },
        -- Automatically generate compile file on changes
        auto_reload_compiled = true,
    }
})


