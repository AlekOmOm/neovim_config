# ~/.config/nvim/lua/core/options.lua
local opt = vim.opt
local g = vim.g


-- Basic settings
opt.number = true
opt.relativenumber = true
opt.autoindent = true
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smarttab = true
opt.smartindent = true

-- Leader key
g.mapleader = ' '

