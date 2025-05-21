~/.config/nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── core/               # Core vim settings
│   │   ├── init.lua        # Loads all core modules
│   │   ├── options.lua     # Vim options
│   │   ├── keymaps.lua     # Key mappings
│   │   └── autocmds.lua    # Autocommands
│   │
│   ├── plugins/            # Plugin configurations
│   │   ├── init.lua        # Plugin loader (packer)
│   │   ├── setup.lua       # Plugin setup orchestrator
│   │   ├── lsp/           # LSP configurations
│   │   │   ├── init.lua   # LSP loader
│   │   │   ├── servers.lua # Server configs
│   │   │   └── mason.lua  # Mason setup
│   │   │
│   │   ├── completion.lua  # Completion (nvim-cmp)
│   │   ├── copilot.lua     # GitHub Copilot config
│   │   ├── telescope.lua   # Telescope setup
│   │   ├── treesitter.lua  # Treesitter config
│   │   └── theme.lua       # Theme settings
│   │
│   └── utils/              # Utility functions (not yet implemented)
       └── init.lua         # Utility functions