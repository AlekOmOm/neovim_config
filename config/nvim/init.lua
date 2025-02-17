-- AppData/Local/nvim 

-- ~/.config/nvim/init.lua
-- Machine-specific pointer file
-- Points to shared OneDrive config

-- Windows
--

local HOME = vim.fn.expand("$HOME")
local ONEDRIVE_CONFIG = HOME .. "/OneDrive/01_Software/neovim/config"

vim.opt.runtimepath:prepend(ONEDRIVE_CONFIG)

dofile(ONEDRIVE_CONFIG .. "/init.lua")

-- Linux example (Raspberry Pi)
-- vim.opt.runtimepath:prepend("/path/to/synced/onedrive/neovim/config")
-- dofile("/path/to/synced/onedrive/neovim/config/init.lua")
