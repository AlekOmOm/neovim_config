# Linux Setup Guide for Neovim Configuration

This document provides a step-by-step guide for setting up this Neovim configuration on Linux systems.

## Prerequisites

1. **Neovim**: Version 0.7.0 or later
   ```bash
   # Ubuntu/Debian
   sudo apt-get install neovim
   
   # Arch Linux
   sudo pacman -S neovim
   
   # Fedora
   sudo dnf install neovim
   
   # For the latest version, consider using the AppImage or building from source
   # https://github.com/neovim/neovim/releases
   ```

2. **Git**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install git
   
   # Arch Linux
   sudo pacman -S git
   
   # Fedora
   sudo dnf install git
   ```

3. **Python 3** and **pynvim**:
   ```bash
   # Install Python 3
   sudo apt-get install python3 python3-pip
   
   # Install pynvim
   pip3 install pynvim
   ```

4. **Node.js** and **npm** (for LSP servers):
   ```bash
   # Using the official NodeSource repository
   curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Or use your distribution's package manager
   # sudo apt-get install nodejs npm
   ```

5. **Ripgrep** (for telescope.nvim):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install ripgrep
   
   # Arch Linux
   sudo pacman -S ripgrep
   
   # Fedora
   sudo dnf install ripgrep
   ```

## Installation

1. **Clone the repository to your Neovim config directory**:
   ```bash
   # Backup your existing config if needed
   mv ~/.config/nvim ~/.config/nvim.bak
   
   # Clone this repository
   git clone https://github.com/AlekOmOm/neovim_config.git ~/.config/nvim
   ```

2. **Set up environment variables**:
   ```bash
   # Add to your .bashrc or .zshrc
   echo 'export NVIM_PYTHON_EXE=$(which python3)' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **First launch**:
   ```bash
   nvim
   ```
   
   The first time you start Neovim, Packer will automatically install. Restart Neovim after the installation, then run `:PackerSync` to install all plugins.

4. **Install LSP servers and tools**:
   After plugins are installed, you can install language servers using Mason:
   ```
   :MasonInstall pyright-langserver lua-language-server typescript-language-server
   ```

## Verifying Linux Compatibility

Run the included Linux compatibility test script to verify your setup:

```bash
nvim --headless -c "luafile scripts/linux_compatibility_test.lua" -c q
```

This will generate a log file at `~/.local/state/nvim/linux_compat_test.log` (or similar path depending on your Neovim version).

## Troubleshooting

### Mason Installed Executables

LSP servers installed via Mason should be detected automatically. If you encounter issues:

1. Check that Mason has installed the servers:
   ```
   :Mason
   ```

2. Verify the executable paths:
   ```
   ls -la ~/.local/share/nvim/mason/bin/
   ```

3. Ensure executables have proper permissions:
   ```bash
   chmod +x ~/.local/share/nvim/mason/bin/*
   ```

### Python Provider Issues

If you encounter Python-related errors:

1. Verify that pynvim is installed for the correct Python executable:
   ```bash
   python3 -m pip install pynvim
   ```

2. Check Neovim's Python provider status:
   ```
   :checkhealth provider
   ```

3. Set the NVIM_PYTHON_EXE environment variable to point to the correct Python executable:
   ```bash
   export NVIM_PYTHON_EXE=$(which python3)
   ```

### Path-Related Issues

If you encounter path-related errors:

1. Check that the paths utility is working correctly:
   ```
   :lua print(require('utils.paths').path_sep)
   ```
   This should print `/` on Linux systems.

2. Verify the shada file path:
   ```
   :lua print(vim.opt.shadafile:get())
   ```

## Known Linux-Specific Differences

- Path separators: Linux uses `/` instead of `\`.
- Executable extensions: Linux executables do not use the `.cmd` extension that Windows requires.
- Shada file location: On Linux, the shada file is stored in `~/.local/share/nvim/shada/main.shada`.

## Support

If you encounter issues specific to Linux:

1. Create an issue on the GitHub repository.
2. Include the output of the Linux compatibility test script.
3. Specify your Linux distribution and version.

---

Last updated: 2023-07-13 