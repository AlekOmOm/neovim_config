-- ~/.config/nvim/lua/core/options.lua
local opt = vim.opt
local g = vim.g

-- Global options
opt.clipboard = 'unnamedplus'  -- Use the system clipboard fx. for copy paste on windows and linux: "+y, "+p
opt.hidden = true              -- Enable background buffers fx. :hide, this is useful for :e and :b also
opt.ignorecase = true          -- Ignore case when searching

-- shada 
vim.opt.shadafile = vim.fn.expand('~/neovim.shada')  -- move outside onedrive path
vim.opt.shada = "'100,<50,s10,h"  -- save more history


-- Basic settings
opt.number = true
opt.relativenumber = true -- Show relative line numbers from current line, useful for jumping to lines

opt.autoindent = true -- Automatically indent new lines
opt.smartindent = true -- Smart indenting for new lines
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smarttab = true


-- Leader key
g.mapleader = ' '


-- treesitter
-- Folding settings (Treesitter-based)


-- Global folding settings
vim.opt.foldmethod = 'syntax'  -- Use syntax-based folding
vim.opt.foldlevel = 1          -- Initial fold level
vim.opt.foldlevelstart = 99    -- Start with all folds open
vim.opt.foldenable = true      -- Enable folding


-- Set UTF-8 encoding explicitly
vim.opt.fileencoding = "utf-8"

-- Set locale-related environment variables
if vim.fn.has('win32') == 1 then
    -- Set environment variables for Windows
    vim.env.LANG = "en_US.UTF-8"
    vim.env.LC_CTYPE = "en_US.UTF-8"
end
