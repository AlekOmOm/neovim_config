# Neovim Configuration File Index

This file helps in navigating the Lua configuration for Neovim.

## Main Configuration Directories

*   `lua/` - Root directory for all Lua configuration.
    *   `init.lua` - Main entry point for Neovim configuration. Handles Packer setup, LSP, and global settings.
*   `lua/core/` - Core Neovim settings (options, keymaps, autocommands).
    *   `options.lua` - General Neovim options.
    *   `keymaps.lua` - Global and plugin-specific keymappings.
    *   `autocmds.lua` - Custom autocommands.
*   `lua/plugins/` - Plugin configurations, managed by Packer.
    *   `init.lua` - Packer plugin declarations and general plugin setup logic.
    *   Individual `[plugin_name].lua` files - Specific configurations for each plugin (e.g., `telescope.lua`, `treesitter.lua`).
    *   `lsp/` - LSP-related plugin configurations.
        *   `init.lua` - Main setup for LSP integrations.
        *   `mason.lua` - Configuration for `mason.nvim` (LSP installer).
        *   `servers.lua` - Configurations for individual language servers.
        *   `debug.lua` - LSP debugging utilities and commands.
*   `lua/utils/` - Utility modules.
    *   `paths.lua` - Utility functions for platform-agnostic path manipulation.

## Key Files

*   `init.lua` (root): The primary starting point of the Neovim configuration.
*   `lua/plugins/init.lua`: Manages plugin declarations for Packer.
*   `lua/utils/paths.lua`: Crucial for ensuring cross-platform path compatibility.

---
*This index can be expanded as needed.* 