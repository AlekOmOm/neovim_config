# Neovim Configuration Guide

This guide provides a comprehensive overview of a personal Neovim configuration focused on development efficiency, LSP integration, and quality-of-life improvements.

## Table of Contents
- [Requirements](#requirements)
- [Installation](#installation)
- [Directory Structure](#directory-structure)
- [Key Features](#key-features)
- [Core Configuration](#core-configuration)
- [Language Server Protocol (LSP)](#language-server-protocol-lsp)
- [Plugin Overview](#plugin-overview)
- [Platform-Specific Considerations](#platform-specific-considerations)
- [Key Commands & Shortcuts](#key-commands--shortcuts)
- [Utils: New Files with Directory Creation](#utils-new-files-with-directory-creation)
- [Troubleshooting](#troubleshooting)

## Requirements

- **Neovim >= 0.9.0** (critical requirement)
- For Debian stable users, installation from source is required:
  ```bash
  # Install build dependencies
  sudo apt-get install ninja-build gettext cmake unzip curl

  # Build from source
  cd ~
  mkdir neovim-source && cd neovim-source
  git clone https://github.com/neovim/neovim
  cd neovim
  git checkout stable
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  ```

## Installation

### Option 1: Git Clone and Script
```bash
# Clone the repository
git clone git@github.com:AlekOmOm/neovim_config.git

# Run initialization script
./init_scripts/sync_nvim.sh
```

### Option 2: Manual Setup
1. Clone packer.nvim:
   ```bash
   git clone --depth 1 https://github.com/wbthomason/packer.nvim \
     ~/.local/share/nvim/site/pack/packer/start/packer.nvim
   ```
2. Copy or symlink configurations to `~/.config/nvim/`
3. Start nvim and run `:PackerSync` to install plugins
4. Run `:Mason` to install language servers

## Directory Structure

```
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
│   └── utils/              # Utility functions
       ├── init.lua         # Utils loader
       └── init_file.lua    # File/directory creation
```

## Key Features

1. **Core Settings**
   - Line numbers (relative + absolute)
   - 4-space indentation with autoindent
   - Spacebar as leader key
   - Language-aware file execution (F5)

2. **LSP Integration**
   - Support for multiple languages (Python, Rust, TypeScript, etc.)
   - Cross-platform compatibility (Windows/Linux)
   - Diagnostic commands and debugging tools

3. **Code Completion**
   - nvim-cmp integration
   - GitHub Copilot with custom keybindings

4. **Refactoring Tools**
   - Variable renaming
   - Code extraction
   - File extraction

5. **File Navigation**
   - Telescope integration for fuzzy-finding
   - Buffer management

6. **Utilities**
   - File/directory creation via command-line argument `-i`
   - Automatic directory creation when saving

## Core Configuration

### Editor Options (`options.lua`)
- System clipboard integration
- UTF-8 encoding
- Relative line numbers (improves movement efficiency)
- Syntax-based folding
- Hidden buffers (background files)

### Key Mappings (`keymaps.lua`)
- Telescope: `<leader>ff` for files, `<leader>fg` for git files
- Refactoring: `<leader>rn` for rename, `<leader>re` for extract
- Markdown: `<leader>mp` for preview, `<leader>ms` for compile

### Auto Commands (`autocmds.lua`)
- Language-specific run commands mapped to F5
- Automatic directory creation when saving files to non-existent paths

## Language Server Protocol (LSP)

### Configuration Architecture
The LSP setup uses a layered approach:
1. **Mason** (`mason.lua`) - Package manager for LSP servers
2. **Server Configuration** (`servers.lua`) - Language-specific settings
3. **Core Setup** (`init.lua`) - Attaches LSP to buffers, sets keymaps

### Supported Languages
- Python (pyright)
- Lua (lua_ls)
- TypeScript/JavaScript (tsserver)
- HTML/CSS/JSON
- Rust (with clippy integration)
- Docker and Compose files
- YAML, Bash

### Debugging Tools
- `:LspInfo` - Shows active LSP clients
- `:LspLog` - Opens LSP log file
- `:LspStart <server>` - Manually starts a server
- `:LspCheck` - Verifies Mason installations
- `:LspRestart` - Restarts all LSP clients
- `:LspDebug` - Sets LSP log level to DEBUG

## Plugin Overview

### Plugin Manager
- [packer.nvim](https://github.com/wbthomason/packer.nvim) for plugin management

### Essential Plugins
- **LSP**: nvim-lspconfig, mason.nvim, mason-lspconfig.nvim
- **Completion**: nvim-cmp, LuaSnip
- **Navigation**: Telescope
- **Syntax**: Treesitter
- **AI**: GitHub Copilot
- **Git**: vim-fugitive
- **Markdown**: markdown-preview.nvim (browser-based previewing)
- **Refactoring**: refactoring.nvim, inc-rename.nvim

### Theme
- GitHub Dark theme with black background override
- True colors enabled

## Platform-Specific Considerations

### Windows Support
- Automatically detects Windows and adjusts:
  - Uses `.cmd` extensions for LSP executables
  - Sets appropriate environment variables
  - Adjusts path handling

### Cross-Platform Compatibility
- Helper functions for executable resolution
- Platform-specific path handling
- UTF-8 encoding enforcement

## Key Commands & Shortcuts

### Basic Movement
```
h, j, k, l       left, down, up, right
gg               beginning of file
G                end of file
0, $             move to start / end of line
w, b             beginning of next / prev word
```

### Insertion
```
i, I             enter insert at cursor / beginning of line
a, A             enter insert after cursor / end of the line
o, O             insert a new line below / above current
dd, yy           delete / copy (yank) current line
p, P             paste after / before cursor
u, ctrl+r        undo / redo the last undone change
```

### Search & Replace
```
/text, ?text     search forward / backward for "text"
n, N             repeat the last search forward / backward
:%s/old/new/g    replace all occurrences of "old" with "new"
:%s/old/new/gc   replace all occurrences with confirmation
```

### Running Code
```
F5               run current file (auto-detects language)
:split | terminal open terminal in split window
:!command         run any shell command
```

### Copilot
```
<C-J>            accept suggestion
<C-K>            next suggestion
<C-L>            previous suggestion
<C-H>            dismiss suggestion
<A-J>            accept word (partial completion)
<A-L>            accept line (partial completion)
:CopilotToggle   toggle Copilot on/off
```

## Utils: New Files with Directory Creation

### Using the `-i` Flag
Create new files with full directory paths:

```bash
nvim -i src/vector_db/__init__.py
```

This will:
1. Create all necessary directories (e.g., `src/vector_db/`)
2. Create an empty file (`__init__.py`)
3. Exit vim immediately on success

### Implementation
The feature is implemented in two places:
1. Command-line argument handler in `init.lua`
2. Utility function in `utils/init_file.lua`

## Troubleshooting

### LSP Issues
1. Check if the server is installed: `:Mason`
2. Verify server configuration: `:LspInfo`
3. Check the logs: `:LspLog`
4. Restart the server: `:LspRestart`

### Plugin Problems
1. Update plugins: `:PackerSync`
2. Check for errors: `:messages`
3. Try clean installation: remove `~/.local/share/nvim/site/pack/packer/`

### Cross-Platform Issues
- Windows users may need to adjust path separators
- Ensure correct permissions on Unix systems
- Check if `.cmd` extensions are properly handled
