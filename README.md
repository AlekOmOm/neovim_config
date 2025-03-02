# Neovim Configuration documentation

Personal neovim config


## init 
```bash
# Install build dependencies
    sudo apt-get install ninja-build gettext cmake unzip curl

# git clone 
    git clone git@github.com:AlekOmOm/neovim_config.git

# init with Script

    ./init_scripts/sync_nvim.sh
```

### Requirements

***important:*** 

- config requires Neovim >= 0.9.0. 


## Peculiarities
- OneDrive sync to AppData/Local/nvim
    - `init.vim` is symlinked to `init.lua` for easier configuration

## Directory Structure
```
~/.config/nvim/
├── init.lua
└── lua/
    ├── core/
    │   ├── init.lua
    │   ├── options.lua
    │   ├── keymaps.lua
    │   └── autocmds.lua
    ├── plugins/
    │   ├── init.lua
    │   ├── theme.lua
    │   ├── copilot.lua
    │   ├── completion.lua
    │   └── lsp/
    │       ├── init.lua
    │       ├── mason.lua
    │       └── servers.lua
    └── utils/  (not yet implemented)
```

## Complete list of both plugins and core configurations

1. Core Settings:
   - Line numbers: relative + absolute
   - Indentation: 4 spaces, autoindent
   - Leader key: spacebar
   - File running (F5): python, java, cs, lua, javascript, typescript, rust
   - Basic keymaps: custom refactoring and language-specific commands

2. Plugin Manager:
   - `wbthomason/packer.nvim`

3. Theme:
   - `projekt0n/github-nvim-theme`
   - Black background override
   - True colors enabled

4. LSP Setup:
   - `neovim/nvim-lspconfig`
   - `williamboman/mason.nvim`
   - `williamboman/mason-lspconfig.nvim`
   - Configured servers:
     - pyright (Python)
     - dockerls (Docker)
     - docker_compose_language_service
     - rust_analyzer (with clippy integration)

5. Code Completion:
   - `hrsh7th/nvim-cmp`
   - `hrsh7th/cmp-nvim-lsp`
   - `L3MON4D3/LuaSnip`
   - `saadparwaiz1/cmp_luasnip`
   - Mappings: Ctrl+Space (complete), Enter (confirm)

6. AI Assistance:
   - `github/copilot.vim`
   - Configured with Ctrl+J to accept

7. Syntax and Utils:
   - `nvim-treesitter/nvim-treesitter`
   - `nvim-lua/plenary.nvim`

8. Refactoring Tools:
   - `ThePrimeagen/refactoring.nvim`
   - `smjonas/inc-rename.nvim`
   - Keymaps:
     - Space+rn: rename
     - Space+re: extract code
     - Space+rf: extract to file
