# System-Specific Configuration

This directory contains machine-specific configurations that are loaded based on the hostname of the system.

## How It Works

1. The `system_specific.lua` module detects the current system's hostname and OS.
2. It then attempts to load a matching configuration from `lua/conf/machines/{hostname}.lua` 
   (with hostname converted to lowercase and dashes replaced by underscores).
3. If a matching configuration exists, its `setup()` function is called to apply machine-specific settings.

## Available Machine Configurations

- `desktop_v2l884c.lua`: Configuration for the main laptop (DESKTOP-V2L884C) with devdrive
- `desktop_19qvlup.lua`: Configuration for the stationary desktop (DESKTOP-19QVLUP)

## Adding New Machine Configurations

To add configuration for a new machine:

1. Create a new file in this directory named after the hostname (lowercase, replace dashes with underscores)
2. Implement a module with a `setup()` function that applies your machine-specific settings
3. The file will be automatically loaded when Neovim runs on that machine

## Example Template

```lua
local M = {}

function M.setup()
  -- Define machine-specific settings here
  vim.opt.guifont = "YourFont:h12"
  
  -- Set machine-specific variables
  vim.g.my_machine_paths = {
    projects = "/path/to/projects",
  }
  
  -- Add machine-specific key mappings
  -- vim.keymap.set(...)
  
  print("Applied settings for [YOUR_HOSTNAME]")
end

return M
```

## Global Variables

Machine-specific configurations can expose values through global variables:

- `vim.g.dev_paths`: Paths specific to the main laptop with devdrive
- `vim.g.desktop_paths`: Paths specific to the stationary desktop 