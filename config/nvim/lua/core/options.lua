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


-- Best practices for nvim options (https://www.reddit.com/r/neovim/comments/8w7n6h/best_practices_for_nvim_options/)
-- best options to set (in structure: def, explanation (usefulness), example (workflow), optional settings): 
-- 1. hidden
-- - def: this allows you to switch between buffers without saving them.
-- - explanation: useful since buffers is not saved when switching between them.
-- - example: :hide or :e

-- 2. clipboard
-- - def: allows you to copy and paste from the system clipboard.
-- - explanation: useful since not all systems have the same clipboard, and this allows you to copy and paste between them.
-- - example: "+y, "+p (copy and paste)    note: not ctrl+c, ctrl+v, but workflow: in file, v, select, "+y, in file, "+p 
-- - optional settings: unnamedplus, unnamed, autoselect, exclude:.* (exclude all files), exclude:terminal (exclude terminal)

-- 3. ignorecase
-- - def: ignore case when searching.
-- - explanation: useful since you don't have to worry about case when searching.
-- - example: /search
-- 4. number
-- - def: show line numbers.
-- - explanation: useful for debugging and navigating.