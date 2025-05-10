# Neovim Configuration

This repository contains a cross-platform Neovim configuration designed to work seamlessly across Windows, macOS, and Linux environments.

## Path Handling in Neovim Configuration

### Packer Compiled Output

The configuration uses [packer.nvim](https://github.com/wbthomason/packer.nvim) for plugin management. One key aspect of ensuring cross-platform compatibility is handling the `packer_compiled.lua` file correctly.

#### Important Notes

1. **System-Specific Paths**: The `packer_compiled.lua` file contains system-specific paths that should not be committed to version control.
   - It is already added to `.gitignore` to prevent committing system-specific compiled files.
   - Patterns added: `packer_compiled.lua` and `**/plugin/packer_compiled.lua`

2. **Path Resolution**: The Packer configuration in `lua/plugins/init.lua` uses system-agnostic path handling:
   ```lua
   config = {
       compile_path = paths.join(vim.fn.stdpath('config'), 'plugin', 'packer_compiled.lua'),
       package_root = paths.join(vim.fn.stdpath('data'), 'site', 'pack'),
       -- other configuration options...
   }
   ```

3. **Neovim Standard Paths**: The configuration uses Neovim's standard path functions:
   - `vim.fn.stdpath('config')`: For configuration files
   - `vim.fn.stdpath('data')`: For data files
   - The `paths` utility module (`lua/utils/paths.lua`) provides cross-platform path handling

4. **First-Time Setup**: When setting up on a new system:
   - Run `:PackerSync` to install plugins and generate a new `packer_compiled.lua` file for your system
   - This will create the file in the correct location with proper paths for your system

5. **Multiple Neovim Configurations**: If you use multiple Neovim configurations:
   - Be aware that `vim.fn.stdpath('config')` points to your primary Neovim configuration directory
   - For development/testing of this configuration, consider using environment variables to override paths

## Cross-Platform Compatibility

This configuration uses several techniques to ensure cross-platform compatibility:

1. **Path Separator Handling**: The `paths.path_sep` variable is set based on the operating system to use the correct path separator (`\` for Windows, `/` for Unix-like systems).

2. **Path Joining**: The `paths.join()` function is used to construct paths with the correct separator for the current system.

3. **System Detection**: The configuration detects the operating system using `vim.loop.os_uname().sysname` to apply system-specific settings when necessary.

4. **LSP Executable Names**: For language servers, the configuration handles the `.cmd` extension for Windows executables.

5. **System-Specific Configuration**: The `lua/core/system_specific.lua` module provides hostname and OS detection to apply machine-specific settings. Configuration modules in `lua/conf/machines/` are loaded based on hostname.

## System-Specific Configuration

The configuration includes a system for applying different settings based on the machine's hostname or operating system:

1. **Hostname Detection**: Automatically detects the current machine and applies appropriate settings.
   - Specifically configured for known machines like main laptop and stationary desktop
   - Can be extended for additional machines by creating new configuration files

2. **OS Detection**: Detects Windows, Linux, and macOS to apply OS-specific settings.

3. **Testing System**: A testing utility allows simulating different environments:
   ```lua
   :luafile lua/core/test_system_specific.lua
   ```

4. **Override for Testing**: You can force a specific configuration by setting an override:
   ```lua
   -- Add to init.lua before the system_specific module is loaded
   vim.g.system_override = { hostname = "DESKTOP-19QVLUP" }
   ```

## External Dependencies

This Neovim configuration relies on several external tools and programs to provide its full range of features, including LSP servers, linters, formatters, and plugin-specific functionality.

For a detailed list of required dependencies, their versions, installation instructions, and troubleshooting tips, please refer to the [DEPENDENCIES.md](DEPENDENCIES.md) file.

### Automatic Dependency Checking

To help manage these external requirements, the configuration includes an automatic dependency checker that runs when Neovim starts (once integrated into the startup sequence). This checker will notify you of:

- Missing critical executables (e.g., `git`, `node`, `python`, a C compiler).
- Executables that are found but whose versions are below the recommended minimum.
- Issues with underlying dependencies for Language Servers managed by Mason.

The notifications will attempt to guide you on how to resolve these issues, often by referring you to the `DEPENDENCIES.md` document.

If you prefer to manage dependencies manually or encounter issues with the automatic checker, you can always refer to `DEPENDENCIES.md` for manual installation guidance.

## Troubleshooting

If you encounter path-related issues:

1. **Check Packer Compiled Path**: Verify where `packer_compiled.lua` is being generated:
   ```lua
   :lua print(require('packer.config').options.compile_path)
   ```

2. **Check Neovim Standard Paths**: Verify the paths Neovim is using:
   ```lua
   :lua print(vim.fn.stdpath('config'))
   :lua print(vim.fn.stdpath('data'))
   ```

3. **Regenerate Packer Compiled File**: If you encounter issues, try regenerating the file:
   ```
   :PackerClean
   :PackerSync
   ```

4. **Path Utility Functions**: Check that the path utility is working correctly:
   ```lua
   :lua print(require('utils.paths').path_sep)
   :lua print(require('utils.paths').join(vim.fn.stdpath('config'), 'plugin'))
   ``` 