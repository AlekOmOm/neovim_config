-- ~/.config/nvim/lua/core/options.lua
local opt = vim.opt
local g = vim.g
-- Import the paths utility module
local paths = require('utils.paths')

-- 
vim.opt.termguicolors = true  -- Enable 24-bit RGB color in the TUI
vim.opt.background = 'dark'   -- Tell vim that we're using a dark background

-- line wrap
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.showbreak = "↳ "



vim.opt.updatetime = 300  -- Faster completion and diagnostics (when you type something, the completion menu will appear faster)


-- Global options
opt.clipboard = 'unnamedplus'  -- Use the system clipboard fx. for copy paste on windows and linux: "+y, "+p
opt.hidden = true              -- Enable background buffers fx. :hide, this is useful for :e and :b also
opt.ignorecase = true          -- Ignore case when searching

-- shada 
-- Use paths utility to properly handle cross-platform paths
local shada_path
if vim.fn.has('win32') == 1 then
  shada_path = paths.join(paths.NVIM.STATE, 'neovim.shada') 
else
  shada_path = paths.join(paths.NVIM.STATE, 'neovim.shada')
end
vim.opt.shadafile = shada_path  -- save shada file in a custom location 
vim.opt.shada = "'100,<50,s10,h"  -- save more history



-- Basic settings
opt.number = true
opt.relativenumber = true -- Show relative line numbers from current line, useful for jumping to lines

opt.autoindent = true   -- Automatically indent new lines
opt.smartindent = true  -- Smart indenting for new lines
opt.expandtab = true
opt.tabstop = 3         -- Number of spaces that a <Tab> in the file counts for
opt.shiftwidth = 3      -- Number of spaces to use for each step of (auto)indent
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


