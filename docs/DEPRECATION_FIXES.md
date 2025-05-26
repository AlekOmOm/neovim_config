# Neovim Deprecation Warning Fixes

This branch contains fixes for deprecation warnings in Neovim:

1. `vim.lsp.start_client()` - Deprecated in favor of `vim.lsp.start()`
2. `vim.tbl_islist` - Deprecated in favor of `vim.islist`
3. `vim.validate` - Deprecated in favor of a different `vim.validate` with changed signature

## Changes

### 1. Copilot Deprecation Fix

Added a patch file in `after/plugin/fix_copilot_deprecation.lua` that:
- Monkey-patches the `_copilot` module's `start` function
- Uses `vim.lsp.start()` instead of the deprecated `vim.lsp.start_client()`
- Falls back to the original function for compatibility

### 2. `vim.tbl_islist` Deprecation Fix

Added a utility module in `lua/plugins/packer_update.lua` that:
- Monkey-patches `vim.tbl_islist` to use `vim.islist` when available
- Creates a user command `:FixDeprecationWarnings` to update plugins
- Detects Neovim version and displays appropriate warnings

### 3. `vim.validate` Deprecation Fix

This warning comes from the `nvim-notify` plugin. The solution is to update the plugin to the latest version using Packer:

```
:PackerUpdate rcarriga/nvim-notify
```

## How to Use

- The fixes are applied automatically on startup
- Run `:FixDeprecationWarnings` to update Packer and Copilot plugins
- After updating plugins, restart Neovim and run `:PackerSync`

## Compatibility

These fixes maintain compatibility with older Neovim versions while preparing for future versions (0.12, 0.13) where the deprecated functions will be removed.