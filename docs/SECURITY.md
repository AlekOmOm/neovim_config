# Security Features in Neovim Configuration

This document explains the security features implemented in this Neovim configuration, how they work, and how to configure them for your specific security needs.

## Overview

The configuration has been enhanced with several security features to protect sensitive information and reduce security risks:

1. **Environment Variable Management**: Store sensitive information in `.env` files instead of in the configuration files
2. **Secure File Operations**: Protection against operations outside of allowed directories  
3. **Safe Command Execution**: Validation of external commands against an allowlist
4. **Personal Information Protection**: Redaction of sensitive information in logs and outputs
5. **Path Security**: Protection against path traversal and unsafe file access

## Environment Variables (`.env` File)

Instead of hardcoding sensitive information like specific machine paths, hostnames, and credentials, the configuration now uses environment variables loaded from a local `.env` file.

### How to Use

1. Copy the `.env.example` file to `.env` in your Neovim configuration directory:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file to add your specific information:
   ```
   # System Information
   NVIM_HOSTNAME="your-actual-machine-name"
   NVIM_MAIN_LAPTOP="DESKTOP-V2L884C"
   NVIM_STATIONARY="DESKTOP-19QVLUP"
   
   # Path Information (these are examples, set your actual paths)
   NVIM_LAPTOP_PROJECTS_PATH="D:/dev/projects" 
   ```

3. The `.env` file is automatically loaded at Neovim startup and the values are made available to the configuration.

4. The `.env` file is listed in `.gitignore` to ensure it's never committed to version control.

### Available Environment Variables

See `.env.example` for a complete list of supported environment variables.

## Secure File Operations

The `security.lua` module provides functions to handle file operations securely:

### Allowed Directories

By default, the configuration only allows file operations within specific directories:

- Neovim configuration directory (`~/.config/nvim` or equivalent)
- Neovim data directory (`~/.local/share/nvim` or equivalent)
- Neovim state directory (`~/.local/state/nvim` or equivalent)
- Neovim cache directory (`~/.cache/nvim` or equivalent)

You can add additional allowed directories via the environment variable:

```
NVIM_SECURITY_ALLOWED_DIRS="/path/to/projects,/another/safe/path"
```

### Secure File Reading and Writing

The module provides secure alternatives to standard file operations:

- `security.safe_read(filepath, force)`: Reads a file only if it's in an allowed directory
- `security.safe_write(filepath, content, force)`: Writes to a file only if it's in an allowed directory
- `security.might_contain_sensitive_data(filepath)`: Checks if a file contains potentially sensitive information

### Sensitive Data Detection

The configuration can detect potentially sensitive information in files and prompt for confirmation before operations:

```lua
-- These patterns are checked when reading/writing files
M.sensitive_patterns = {
  "token", "key", "secret", "password", "credential", "auth", "apikey"
}
```

You can add additional patterns via the environment variable:

```
NVIM_SECURITY_SENSITIVE_PATTERNS="apitoken,private_key,confidential"
```

## Safe Command Execution

External commands can be a security risk if not properly validated.

### Allowed Commands

By default, only certain commands are allowed to be executed:

```lua
M.allowed_commands = {
  "git", "nvim", "npm", "node", "python", "python3", "lua", "make", "gcc",
  "clang", "cp", "mv", "mkdir", "ls", "find", "grep", "sed", "awk"
}
```

You can customize the allowed commands via the environment variable:

```
NVIM_SECURITY_ALLOWED_COMMANDS="git,nvim,npm,node,python,python3,lua,make,gcc"
```

### Secure Command Execution

The module provides a secure alternative to `vim.fn.system()`:

```lua
security.safe_execute(cmd, force)
```

This function:
1. Checks if the command starts with an allowed program
2. Prompts for confirmation if it doesn't
3. Executes the command if confirmed or if `force` is `true`

## Personal Information Protection

The configuration includes features to protect personal information from being exposed in logs and outputs.

### Information Redaction

The `security.redact_personal_info(content)` function can be used to remove personal information from strings:

- Replaces the home directory path with `~`
- Replaces the username with `<USERNAME>`
- Replaces known hostnames with `<HOSTNAME>`

### Implementation

This function is applied to outputs that might contain sensitive information, for example:

- Log messages
- Error reports
- Debug information

## Override and Configuration

### Disabling Confirmations

For testing or trusted environments, you can disable security confirmations:

```
NVIM_SECURITY_DISABLE_CONFIRMATIONS=true
```

This will make all security functions operate without asking for confirmation, though they will still log warnings.

### Force Parameter

Most security functions accept a `force` parameter which, when set to `true`, will bypass the confirmation dialog:

```lua
security.safe_write(path, content, true) -- No confirmation dialog
```

## Implementation Details

The security features are implemented in two main modules:

1. `lua/utils/env.lua`: Handles loading and accessing environment variables
2. `lua/utils/security.lua`: Provides security-related functions and utilities

These modules are loaded early in the Neovim startup process (in `init.lua`) to ensure security features are available throughout the configuration.

## Best Practices

1. **Always use the `.env` file** for sensitive information, never commit actual values to the repository
2. **Add project-specific directories** to `NVIM_SECURITY_ALLOWED_DIRS` rather than disabling security features
3. **Be cautious with `force` flags** and only use them when absolutely necessary
4. **Review security warnings** as they may indicate potential security risks
5. **Keep the `.env.example` file up-to-date** with all supported environment variables (but without actual values)

## Troubleshooting

### Security Warning Dialogs

If you're seeing many security warning dialogs, there are several options:

1. Add the relevant directories to `NVIM_SECURITY_ALLOWED_DIRS`
2. Add the commands you're using to `NVIM_SECURITY_ALLOWED_COMMANDS`
3. Use the `force` parameter for specific function calls where appropriate
4. Set `NVIM_SECURITY_DISABLE_CONFIRMATIONS=true` (only in trusted environments)

### Missing Environment Variables

If environment variables are not being loaded:

1. Ensure the `.env` file exists in your Neovim configuration directory
2. Check that it has the correct format (KEY=VALUE, one per line)
3. Verify that the variables are being loaded by running:
   ```lua
   :lua print(vim.inspect(vim.env.NVIM_HOSTNAME or "Not set"))
   ```

### File Access Issues

If you're having trouble accessing specific files:

1. Check that the directory is in the allowed directories list
2. Use `security.safe_read()` and `security.safe_write()` instead of basic Lua I/O functions
3. Add the directory to `NVIM_SECURITY_ALLOWED_DIRS` if needed
