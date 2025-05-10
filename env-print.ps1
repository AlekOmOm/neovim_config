Write-Output "XDG_CONFIG_HOME: $env:XDG_CONFIG_HOME"
Write-Output "XDG_DATA_HOME: $env:XDG_DATA_HOME"
Write-Output "XDG_CACHE_HOME: $env:XDG_CACHE_HOME"
Write-Output "XDG_STATE_HOME: $env:XDG_STATE_HOME"

Write-Output "nvim app name: $env:NVIM_APPNAME"

Write-Output "nvim packer root path: $env:NVIM_PACKER_ROOT_PATH"
Write-Output "nvim packer install path: $env:NVIM_PACKER_INSTALL_PATH"

# test nvim utils/paths.lua
# In PowerShell, if nvim is in PATH, you can call it directly.
# The -c argument and its value might need to be quoted carefully if they contain spaces or special characters.
# For simple cases, direct translation often works.

nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('config')))"
nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('data')))"
nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('cache')))"
nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('state')))" 

# exit nvim
#ctrl+c

