-- ~/.config/nvim/init.lua
-- Machine-specific pointer file
-- Points to shared OneDrive config

-- Windows example
vim.opt.runtimepath:prepend("C:/Users/USERNAME/OneDrive/01_Software/neovim/config")
dofile("C:/Users/USERNAME/OneDrive/01_Software/neovim/config/init.lua")

-- Linux example (Raspberry Pi)
-- vim.opt.runtimepath:prepend("/path/to/synced/onedrive/neovim/config")
-- dofile("/path/to/synced/onedrive/neovim/config/init.lua")
