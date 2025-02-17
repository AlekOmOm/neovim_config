-- ~/.config/nvim/init.lua
-- Machine-specific pointer file
-- Points to shared OneDrive config

-- Windows example
vim.opt.runtimepath:prepend("$HOME/OneDrive/01_Software/neovim/config")
dofile("C:/Users/HP/OneDrive/01_Software/neovim/config/init.lua")

-- Linux example (Raspberry Pi)
-- vim.opt.runtimepath:prepend("/path/to/synced/onedrive/neovim/config")
-- dofile("/path/to/synced/onedrive/neovim/config/init.lua")
