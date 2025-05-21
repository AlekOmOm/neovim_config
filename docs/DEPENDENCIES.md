# External Dependencies for Neovim Configuration

This document outlines the external dependencies required for this Neovim configuration to function fully, including core tools, LSPs, and plugin-specific requirements.

An automatic dependency checker runs on startup (if integrated) to notify you of missing or problematic dependencies. See `lua/utils/dependency_checker.lua` and `lua/utils/dependency_notifier.lua`.

## Core System Tools

These tools are generally expected to be installed manually on your system.

1.  **Git**
    *   **Required By**: Packer (plugin manager), Mason (LSP/tool installer), nvim-treesitter (parser installation), iamcco/markdown-preview.nvim (plugin cloning).
    *   **Version**: Any recent version should suffice.
    *   **Installation**:
        *   **Linux (apt)**: `sudo apt install git`
        *   **Linux (yum/dnf)**: `sudo yum install git` or `sudo dnf install git`
        *   **macOS (Homebrew)**: `brew install git` (often comes with Xcode Command Line Tools)
        *   **Windows**: Download from [git-scm.com](https://git-scm.com/download/win)
    *   **Verification**: `git --version`

2.  **Node.js & npm**
    *   **Required By**: `iamcco/markdown-preview.nvim` (build and runtime), many LSP servers (e.g., `tsserver`, `html`, `cssls`, `jsonls`, `yamlls`, `dockerls`, `bashls`, `eslint`, `vimls`).
    *   **Version**: Node.js >= 16.0.0 recommended (check specific LSP needs if issues arise). npm is usually bundled with Node.js.
    *   **Installation**:
        *   Use a version manager like [nvm](https://github.com/nvm-sh/nvm) (Linux/macOS) or [nvm-windows](https://github.com/coreybutler/nvm-windows).
            *   `nvm install --lts` (to get the latest LTS version)
            *   `nvm use --lts`
        *   Direct download from [nodejs.org](https://nodejs.org/).
    *   **Verification**: `node --version`, `npm --version`
    *   **Troubleshooting**: Ensure `node` and `npm` are in your system's PATH.

3.  **Python**
    *   **Required By**: `pyright` (Python LSP).
    *   **Version**: Python >= 3.7 recommended for Pyright.
    *   **Installation**:
        *   Use a version manager like [pyenv](https://github.com/pyenv/pyenv).
        *   Direct download from [python.org](https://www.python.org/).
        *   **Linux (apt)**: `sudo apt install python3 python3-pip`
        *   **macOS (Homebrew)**: `brew install python`
        *   **Windows**: Download from [python.org](https://www.python.org/) (ensure "Add Python to PATH" is checked).
    *   **Verification**: `python3 --version` or `python --version`. The config also checks `vim.env.NVIM_PYTHON_EXE`.
    *   **Troubleshooting**: Ensure the correct Python executable (python or python3) is in your PATH.

4.  **C Compiler (GCC or Clang)**
    *   **Required By**: `nvim-telescope/telescope-fzf-native.nvim` (build), `nvim-treesitter` (to compile language parsers).
    *   **Version**: Any recent C compiler.
    *   **Installation**:
        *   **Linux (apt)**: `sudo apt install build-essential` (installs gcc, make, etc.)
        *   **Linux (yum/dnf)**: `sudo yum groupinstall "Development Tools"` or `sudo dnf groupinstall "Development Tools"`
        *   **macOS**: Install Xcode Command Line Tools: `xcode-select --install`
        *   **Windows**: Options include MinGW-w64 (for GCC) or Visual Studio Build Tools (for MSVC, though GCC via MinGW is often easier for cross-platform tools).
    *   **Verification**: `gcc --version` or `clang --version`.
    *   **Troubleshooting**: Ensure the compiler is in your PATH. For Windows, setting up a proper build environment can be complex; WSL (Windows Subsystem for Linux) is often a simpler alternative for development tools.

5.  **Make**
    *   **Required By**: `nvim-telescope/telescope-fzf-native.nvim` (build).
    *   **Version**: Any recent version.
    *   **Installation**:
        *   Usually part of `build-essential` or "Development Tools" (see C Compiler section).
        *   **macOS**: Comes with Xcode Command Line Tools.
        *   **Windows**: Can be obtained via MinGW, Chocolatey (`choco install make`), or within WSL.
    *   **Verification**: `make --version`

## LSP Servers & Tools (Managed by Mason)

The following Language Servers, Linters, and Formatters are configured to be installed and managed by `mason.nvim`. Mason will attempt to install them automatically. If issues occur, you might need to ensure their underlying dependencies (listed below) are met, or install them manually via Mason's UI (`:Mason`).

*   **`lua_ls` (Lua Language Server)**
    *   Underlying Deps: Usually self-contained or handled by Mason.
*   **`pyright` (Python LSP)**
    *   Underlying Deps: Python (see Core System Tools).
*   **`tsserver` / `ts_ls` (TypeScript/JavaScript LSP)**
    *   Underlying Deps: Node.js & npm (see Core System Tools).
*   **`html` (HTML LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`cssls` (CSS LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`jsonls` (JSON LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`rust_analyzer` (Rust LSP)**
    *   Underlying Deps: Rust toolchain (rustc, cargo). Install from [rustup.rs](https://rustup.rs/).
*   **`yamlls` (YAML LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`dockerls` (Dockerfile LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`docker_compose_language_service` (Docker Compose LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`vimls` (VimL LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`bashls` (Bash LSP)**
    *   Underlying Deps: Node.js & npm.
*   **`eslint` (ESLint Linter/Formatter)**
    *   Underlying Deps: Node.js & npm. May also require project-local ESLint configuration (`.eslintrc.js`, etc.) and plugins.
*   **`markdown_oxide` (Markdown Tool)**
    *   Underlying Deps: Likely Rust toolchain (if Rust-based). Mason manages this.

**Troubleshooting Mason Installations:**
*   Run `:Mason` to open the Mason UI and check the status of packages.
*   You can manually trigger installation or view logs from the Mason UI.
*   Ensure `git` and potentially `curl`/`wget` are available for Mason to fetch package information and binaries.

## Plugin-Specific Build Steps

Some plugins have build steps defined in their configuration, which also rely on external tools:

1.  **`iamcco/markdown-preview.nvim`**
    *   Build Command: `cd app && npm install` (runs automatically via Packer).
    *   Requires: `node`, `npm` (see Core System Tools).
    *   Troubleshooting: If preview doesn't work, ensure `node` and `npm` are installed and check for errors during Packer's `run` step (visible during `:PackerSync` or in logs).

2.  **`nvim-telescope/telescope-fzf-native.nvim`**
    *   Build Command: `make` (runs automatically via Packer).
    *   Requires: `make` and a C Compiler (see Core System Tools).
    *   Troubleshooting: If Telescope has performance issues or errors related to fzf-native, ensure `make` and a C compiler are available and the build step completed without errors during `:PackerSync`.

3.  **`nvim-treesitter/nvim-treesitter`**
    *   Build Command: `TSUpdate` (compiles parsers as needed).
    *   Requires: C Compiler and `git` (see Core System Tools).
    *   Troubleshooting: If syntax highlighting is missing or incorrect for some languages, run `:TSUpdate` manually. Check for C compiler errors in the output.

## Automatic Dependency Checking

This configuration includes a utility (`lua/utils/dependency_checker.lua`) that attempts to verify the presence and, in some cases, versions of the core system tools listed above. Notifications (`lua/utils/dependency_notifier.lua`) will appear on startup if issues are detected.

**If the checker reports issues:**
1.  Refer to the installation instructions in this document for the problematic dependency.
2.  Ensure the tool is correctly installed and available in your system's PATH.
3.  For version issues, consider upgrading the tool.

Manual installation is always an option if you prefer not to rely on automated installations or encounter issues with them. 