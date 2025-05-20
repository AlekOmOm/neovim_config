-- ~/.config/nvim/init.lua ------------------------------------------------------
-- single‑source paths + cleaner separator‑agnostic joins

local paths = require('utils.paths')
local logger = require('utils.logger') -- Added logger
local fn    = vim.fn

logger.set_level('ERROR')  -- <-

--- windows quirk helpers ------------------------------------------------------
local is_windows = fn.has('win32') == 1
local function exe(name)        -- append .cmd on windows
  return is_windows and (name .. '.cmd') or name
end

--- locale ---------------------------------------------------------------------
if is_windows == 1 then vim.cmd('language en_US.UTF-8') end

-- Print the exact path ensure_packer will use
logger.debug("INIT.LUA: paths.NVIM.PACKER.INSTALL right before ensure_packer(): " .. vim.inspect(paths.NVIM.PACKER.INSTALL))

--- bootstrap packer -----------------------------------------------------------
local function ensure_packer()
  local install_path = paths.NVIM.PACKER.INSTALL          -- …/start/packer.nvim
  local start_dir    = paths.join(paths.NVIM.PACKER.ROOT, 'start')


  -- clone only if the directory is absent / empty
  if fn.empty(fn.glob(install_path)) > 0 then
    paths.ensure_dir(start_dir)                           -- mkdir -p …/start
    logger.info("Packer not found. Cloning packer.nvim...") -- Added logger.info
    fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim',
      install_path,
    })
    return true                                           -- freshly installed
  end

  return false
end

local packer_boot = ensure_packer()

if packer_boot then -- Packer was freshly installed
  vim.cmd('packadd packer.nvim') -- Make packer.nvim available to the current session
  local packer_ok, packer_module = pcall(require, 'packer')
  if not packer_ok then
    logger.error('Critical: packer.nvim installed but failed to require. Error: ' .. tostring(packer_module)) -- Changed to logger.error
    vim.notify('Critical: packer.nvim installed but failed to require. Error: ' .. tostring(packer_module), vim.log.levels.ERROR)
    return -- Can't continue without packer
  end
  -- Initialize Packer for itself (minimal setup)
  packer_module.startup(function(use)
    use 'wbthomason/packer.nvim'
  end)
  logger.warn('packer.nvim installed. Please RESTART Neovim and then run :PackerSync') -- Changed to logger.warn
  vim.notify('packer.nvim installed. Please RESTART Neovim and then run :PackerSync', vim.log.levels.WARN)
  return
end

--- optional profiling ---------------------------------------------------------
local profiling = false
if profiling then
  local log_dir = paths.join(paths.config_dir, 'logs', 'profile-logs')
  paths.ensure_dir(log_dir)
  local file = paths.join(log_dir, 'profile_' .. os.date('%Y-%m-%d_%H-%M-%S') .. '.log')
  vim.cmd('profile start ' .. file)
  vim.cmd('profile func *')
  vim.cmd('profile file *')
  vim.g._profile_file = file
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      local dur = vim.fn.reltimefloat(vim.fn.reltime())
      local msg = string.format('startup: %.3fs', dur)
      logger.info(msg) -- Changed to logger.info
      local f = io.open(file, 'a'); if f then f:write('\n' .. msg .. '\n'); f:close() end
    end,
  })
  logger.info("profiling done") -- Changed to logger.info
end

--- lazy‑load core config -------------------------------------------------------
if not packer_boot then
  logger.info("init.lua: Running core and plugin loading") -- Changed to logger.info (and simplified message)
  local ok_sys, sys = pcall(require, 'core.system_specific')
  if ok_sys then
    sys.apply_system_settings()
  else
    logger.error("Error loading core.system_specific: " .. tostring(sys)) -- Changed to logger.error
    vim.notify("Error loading core.system_specific: " .. tostring(sys), vim.log.levels.ERROR)
  end

  local core_ok, core_module = pcall(require, 'core')
  if not core_ok then
    logger.error("Error loading core: " .. tostring(core_module)) -- Changed to logger.error
    vim.notify("Error loading core: " .. tostring(core_module), vim.log.levels.ERROR)
    return -- Can't proceed without core typically
  end

  -- Manually add packer path to Lua's package path
  local packer_install_path = require('utils.paths').NVIM.PACKER.INSTALL
  local packer_lua_path = packer_install_path .. '/lua/?.lua'
  local packer_lua_init_path = packer_install_path .. '/lua/?/init.lua'
  package.path = package.path .. ';' .. packer_lua_path .. ';' .. packer_lua_init_path
  logger.debug("init.lua: Manually updated package.path for packer: " .. package.path) -- Changed to logger.debug

  local plugins_ok, plug_err = pcall(require, 'plugins')
  if not plugins_ok then
    logger.error('init.lua: failed to load plugins: ' .. tostring(plug_err)) -- Changed to logger.error
    vim.notify('init.lua: failed to load plugins: ' .. tostring(plug_err), vim.log.levels.ERROR)
  else
    logger.info("init.lua: plugins loaded successfully") -- Changed to logger.info
  end
end

--- handle custom -i flag (instant file) ---------------------------------------
local function handle_args()
  for i, arg in ipairs(vim.v.argv) do
    if arg == '-i' and vim.v.argv[i+1] then
      local file  = fn.fnamemodify(vim.v.argv[i+1], ':p')
      local dir   = fn.fnamemodify(file, ':h')
      paths.ensure_dir(dir)
      if fn.filereadable(file) == 0 then io.open(file, 'w'):close() end
      vim.schedule(function() vim.cmd('quit') end)
    end
  end
end
handle_args()

--- lsp setup ------------------------------------------------------------------
local function setup_lsp()
  if vim.g._lsp_init then return end; vim.g._lsp_init = true

  local ok_cfg, lspconfig = pcall(require, 'lspconfig'); if not ok_cfg then return end
  local ok_cmp, cmp       = pcall(require, 'cmp_nvim_lsp')
  local caps = vim.lsp.protocol.make_client_capabilities()
  if ok_cmp then caps = cmp.default_capabilities(caps) end

  local mason_bin = paths.join(paths.data_dir, 'mason', 'bin')
  local servers = {
    pyright        = exe('pyright-langserver'),
    lua_ls         = exe('lua-language-server'),
    ts_ls          = exe('typescript-language-server'),
    html           = exe('vscode-html-language-server'),
    cssls          = exe('vscode-css-language-server'),
    jsonls         = exe('vscode-json-language-server'),
    rust_analyzer  = exe('rust-analyzer'),
  }

  local function on_attach(client, bufnr)
    local map = function(m, lhs, rhs) vim.keymap.set(m, lhs, rhs, {buffer = bufnr, silent=true}) end
    map('n', 'gd', vim.lsp.buf.definition)
    map('n', 'K',  vim.lsp.buf.hover)
    map('n', '<space>ca', vim.lsp.buf.code_action)
  end

  for name, bin in pairs(servers) do
    local cmd = paths.join(mason_bin, bin)
    if fn.filereadable(cmd) == 1 then
      lspconfig[name].setup {
        cmd  = {cmd, '--stdio'},
        on_attach = on_attach,
        capabilities = caps,
        flags = {debounce_text_changes = 150},
      }
    end
  end
end
setup_lsp()

-- Load the compiled packer file if it exists
local packer_compiled = vim.fn.stdpath('data') .. '/site/lua/packer_compiled.lua'
if vim.fn.filereadable(packer_compiled) == 1 then
  vim.cmd('luafile ' .. packer_compiled)
end

-- Add after setup_lsp() in init.lua
vim.defer_fn(function()
  -- Only try to initialize Mason directly if the command doesn't exist
  if not vim.fn.exists(":Mason") then
    local mason_direct_ok, mason_direct = pcall(require, 'plugins.mason_direct')
    if mason_direct_ok and mason_direct.setup() then
      vim.notify("Mason initialized via fallback", vim.log.levels.INFO)
    end
  end
end, 200)  -- Small delay to ensure other initialization is complete

--- misc debug helpers ---------------------------------------------------------
vim.lsp.set_log_level('ERROR')
_G.LspLog = function() vim.cmd('vsplit ' .. vim.lsp.get_log_path()) end
_G.LspInfo = function()
  for _, c in ipairs(vim.lsp.get_clients()) do
    logger.debug(string.format('• %s (%d) %s', c.name, c.id, table.concat(c.config.cmd, ' '))) -- Changed to logger.debug
  end
end
_G.LspDebugPath = function()
  local mason_bin = paths.join(paths.data_dir, 'mason', 'bin')
  for _, f in ipairs(fn.glob(paths.join(mason_bin, '*'), 0, 1)) do logger.debug('  - ' .. f) end -- Changed to logger.debug
end


-- Add near your debug helpers in init.lua
_G.CheckMasonInstall = function()
  local mason_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/mason.nvim'
  if vim.fn.isdirectory(mason_path) == 1 then
    print("Mason found at: " .. mason_path)
  else
    print("Mason NOT found at: " .. mason_path)
    -- Check alternative locations
    local alt_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/mason.nvim'
    if vim.fn.isdirectory(alt_path) == 1 then
      print("Mason found in opt directory")
    end
  end
end

-- shada cleanup of tmp files ------------------------------------------------
-- shada cleanup of tmp files ------------------------------------------------
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local paths = require('utils.paths')
    
    -- 1. locate nvim data dir - use state_dir where shada is stored, not data_dir
    local state_dir = paths.state_dir
    
    -- 2. find all shada tmp files
    local pattern = "*.shada.tmp.*"
    local files = vim.fn.globpath(state_dir, pattern, 0, 1)

    if #files == 0 then
      return
    end

    local config_dir = paths.config_dir
    local log_file = paths.join(config_dir, 'log.shada-cleanup.txt')

    local file = io.open(log_file, 'a')
    if file then
      file:write(os.date("%Y-%m-%d %H:%M:%S") .. " Shada cleanup started\n")
      file:write("State dir: " .. state_dir .. "\n")
      file:write("Found " .. #files .. " temp files\n")
      if #files > 0 then file:write("Files: " .. vim.inspect(files) .. "\n") end
      file:close()
    end

    -- 3. delete each, logging both success and failures
    local deleted = 0
    for _, f in ipairs(files) do
      local success = vim.fn.delete(f)
      if success == 0 then
        deleted = deleted + 1
      else
        vim.notify(
          "Failed to delete shada tmp file: " .. f,
          vim.log.levels.ERROR
        )

        file = io.open(log_file, 'a')
        if file then
          file:write("Error deleting: " .. f .. "\n")
          file:close()
        end
      end
    end

    file = io.open(log_file, 'a')
    if file then
      file:write("Deleted " .. deleted .. "/" .. #files .. " temp files\n")
      file:write("Cleanup finished\n\n")
      file:close()
    end
  end,
})
