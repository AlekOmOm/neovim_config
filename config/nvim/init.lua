-- ~/.config/nvim/init.lua

-- Bootstrap packer first
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        print "Installing packer... Please restart Neovim after installation."
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- Check if packer is available
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Initialize packer
packer.startup(function(use)
    use 'wbthomason/packer.nvim'
    
    if packer_bootstrap then
        packer.sync()
        return  -- Don't load configs if we're bootstrapping
    end
end)

-- Only load configurations if not bootstrapping
if not packer_bootstrap then
    require('core')
    require('plugins')
end
