-- lua/plugins/lsp/ts_server_wrapper.lua
local M = {}

function M.setup(config)
  config = config or {}
  local max_listeners = config.max_listeners or 15
  
  -- Ensure the process.env exists before starting the server
  local env_prepare = string.format([[
  process.setMaxListeners = process.setMaxListeners || function() {};
  require('events').EventEmitter.defaultMaxListeners = %d;
  ]], max_listeners)
  
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