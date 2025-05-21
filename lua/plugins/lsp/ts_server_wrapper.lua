-- lua/plugins/lsp/ts_server_wrapper.lua
local M = {}

function M.setup()
  -- Ensure the process.env exists before starting the server
  local env_prepare = [[
  process.setMaxListeners = process.setMaxListeners || function() {};
  require('events').EventEmitter.defaultMaxListeners = 15;
  ]]
  
  return {
    before_init = function(params, config)
      -- Inject our env preparation script before server initialization
      params.initializationOptions = params.initializationOptions or {}
      params.initializationOptions.beforeServerStart = env_prepare
      return params
    end
  }
end

return M