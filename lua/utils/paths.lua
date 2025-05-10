local uv   = vim.uv or vim.loop
local sep  = package.config:sub(1, 1)
local join = function(...) return table.concat({...}, sep) end

-- xdg roots ------------------------------------------------------------
local HOME = uv.os_homedir()
local XDG  = {
  CONFIG = os.getenv("XDG_CONFIG_HOME") or join(HOME, ".config"),
  DATA   = os.getenv("XDG_DATA_HOME")   or join(HOME, ".local", "share"),
  STATE  = os.getenv("XDG_STATE_HOME")  or join(HOME, ".local", "state"),
  CACHE  = os.getenv("XDG_CACHE_HOME")  or join(HOME, ".cache"),
}

local appname = os.getenv("NVIM_APPNAME") or "nvim"

-- These can be defined early using stdpath, assuming stdpath is stable by now for them
local CONFIG_DIR_main = vim.fn.stdpath('config')
local STATE_DIR_main  = vim.fn.stdpath('state')
local CACHE_DIR_main  = vim.fn.stdpath('cache')
-- DATA_DIR for general use will also use stdpath('data')
local DATA_DIR_main   = vim.fn.stdpath('data')

local NVIM = {
  CONFIG = CONFIG_DIR_main,
  DATA   = DATA_DIR_main, -- General data path
  STATE  = STATE_DIR_main,
  CACHE  = CACHE_DIR_main,
  APP    = appname,
  PACKER = {
    -- Calculate ROOT and INSTALL using a fresh call to stdpath('data') here
    -- to ensure it's the fully initialized version.
    ROOT    = (function()
                local current_data_dir = vim.fn.stdpath('data')
                return os.getenv("NVIM_PACKER_ROOT_PATH")
                       or join(current_data_dir, "site", "pack", "packer")
              end)(),
    INSTALL = (function()
                local dirName = 'neovim_config-data' -- appname + '-data'
                local dataDir = join(XDG.DATA, dirName)  
                return dataDir 
              end)(),
  },
}

local M = {
  config_dir = CONFIG_DIR_main,
  data_dir   = DATA_DIR_main,   -- This will be ...neovim_config-data
  state_dir  = STATE_DIR_main,
  cache_dir  = CACHE_DIR_main,

  HOME      = HOME,
  NVIM      = NVIM,
  path_sep  = sep,
  join      = join,
  XDG_reference = XDG,
}

function M.ensure_dir(path)
  if uv.fs_stat(path) then return true end
  return uv.fs_mkdir(path, 493)          -- 0755, single-level; okay for our use
end

return M
