#! /bin/bash

echo "XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
echo "XDG_DATA_HOME: $XDG_DATA_HOME"
echo "XDG_CACHE_HOME: $XDG_CACHE_HOME"
echo "XDG_STATE_HOME: $XDG_STATE_HOME"

echo "nvim app name: $NVIM_APPNAME"

echo "nvim packer root path: $NVIM_PACKER_ROOT_PATH"
echo "nvim packer install path: $NVIM_PACKER_INSTALL_PATH"

# test nvim utils/paths.lua

nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('config')))"
nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('data')))"
nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('cache')))"
nvim --headless -u init.lua -c "lua print(vim.inspect(vim.fn.stdpath('state')))"
